package asgl.utils.spine {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.events.ASGLEvent;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshHelper;
	import asgl.materials.Material;
	import asgl.materials.MaterialProperty;
	import asgl.materials.TextureRegion;
	import asgl.math.Matrix4x4;
	import asgl.renderables.BaseRenderable;
	import asgl.renderers.AbstractStaticRenderData;
	import asgl.renderers.BaseRenderContext;
	import asgl.renderers.BaseRenderer;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.AbstractTextureData;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.system.IndexBufferData;
	import asgl.system.ProgramData;
	import asgl.system.VertexBufferData;
	
	use namespace asgl_protected;
	
	public class SpineRenderer extends BaseRenderer {
		public static const BATCH_DATA_BUFFER0:String = 'dataBuffer0';
		public static const BATCH_DATA_BUFFER1:String = 'dataBuffer1';
		public static const BATCH_DATA_BUFFER2:String = 'dataBuffer2';
		
		private var _vertexBatchData1Vector:Vector.<Number>;
		private var _vertexBatchData2Vector:Vector.<Number>;
		private var _vertexBatchData3Vector:Vector.<Number>;
		private var _vertexBatchIndexVector:Vector.<uint>;
		private var _vertexBatchData1Buffer:VertexBufferData;
		private var _vertexBatchData2Buffer:VertexBufferData;
		private var _vertexBatchData3Buffer:VertexBufferData;
		private var _vertexBatchIndexBuffer:IndexBufferData;
		private var _vertexBatchMaterial:Material;
		private var _vertexBatchTexFormat:String;
		private var _vertexBatchVertexBuffers:Object;
		private var _vertexBatchTriangleNum:int;
		
		private var _device:Device3D;
		
		private var _renderables:Vector.<BaseRenderable>;
		private var _numRenderables:int;
		
		private var _texID:uint;
		private var _texSampleState:uint;
		private var _numTriangles:int;
		private var _blendFactors:BlendFactorsData;
		private var _scissorRectangle:Rectangle;
		private var _shaderID:uint;
		private var _material:Material;
		private var _materialProperty:MaterialProperty;
		
		private var _staticMap:Object;
		
		public function SpineRenderer(device:Device3D) {
			_device = device;
			
			_staticMap = {};
			
			_renderables = new Vector.<BaseRenderable>(512);
			//================================
			_vertexBatchTriangleNum = 128;
			_vertexBatchVertexBuffers = {};
			
			_vertexBatchMaterial = new Material();
			
			_device.addEventListener(ASGLEvent.RECOVERY, _deviceRecoveryHandler, false, 0, true);
			
			_deviceRecoveryHandler(null);
		}
		public override function dispose():void {
			if (_device != null) {
				_device.removeEventListener(ASGLEvent.RECOVERY, _deviceRecoveryHandler);
				_device = null;
				
				_vertexBatchMaterial.shader.dispose();
				_vertexBatchMaterial = null;
				
				_vertexBatchData2Buffer.dispose();
				_vertexBatchData2Buffer = null;
				_vertexBatchData2Vector = null;
				_vertexBatchData1Buffer.dispose();
				_vertexBatchData1Buffer = null;
				_vertexBatchData2Buffer.dispose();
				_vertexBatchData2Buffer = null;
				_vertexBatchData1Vector = null;
				_vertexBatchIndexBuffer.dispose();
				_vertexBatchIndexBuffer = null;
				_vertexBatchIndexVector = null;
				_vertexBatchVertexBuffers = null;
			}
			
			var keys:Vector.<uint> = new Vector.<uint>();
			var num:int = 0;
			for (var key:uint in _staticMap) {
				keys[num++] = key;
			}
			
			for (var i:int = 0; i < num; i++) {
				destroyStatic(keys[i]);
			}
		}
		public override function postRender(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			_numTriangles = 0;
			_scissorRectangle = null;
			_material = null;
			_materialProperty = null;
			
			delete _vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX];
		}
		public override function pushCheck(renderable:BaseRenderable, material:Material):Boolean {
			if (renderable._material == null) {
				return false;
			} else {
				renderable.updateShaderProgram();
				
				return renderable._meshAsset != null;
			}
		}
		public override function pushRenderable(renderable:BaseRenderable, device:Device3D, camera:Camera3D, material:Material, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			var mat:Material = renderable._material;
			
			var tex:AbstractTextureData = mat._textures[ShaderPropertyType.DIFFUSE_TEX];
			if (tex != null) {
				var blendFactors:BlendFactorsData;
				if (renderable._object3D._multipliedAlpha < 1) {
					blendFactors = renderable._transparentBlendFactors == null ? renderable._blendFactors : renderable._transparentBlendFactors;
				} else {
					blendFactors = renderable._blendFactors;
				}
				
				if (mat._shader != null) renderable.updateShaderProgram();
				
				var isBreak:Boolean = true;
				
				var vertices:MeshElement = renderable._meshAsset.elements[MeshElementType.VERTEX];
				var numTriangles:int = renderable._meshAsset.triangleIndices.length / 3;
				
				if (renderable._shaderID == 0) {
					if (_shaderID != 0) {
						_renderCustom(device, staticRenderData);
						
						_shaderID = 0;
						
						isBreak = false;
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numTriangles = numTriangles;
						
						_numRenderables = 0;
					} else if (_blendFactors == null) {
						isBreak = false;
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numTriangles = numTriangles;
					} else if (_texID == tex._rootInstancID && 
						_blendFactors._blendFactorsID == blendFactors._blendFactorsID && 
						_scissorRectangle == renderable.scissorRectangle &&
						_texSampleState == tex._samplerStateData._samplerStateValue) {
						isBreak = false;
						
						_numTriangles += numTriangles;
					}
					
					if (isBreak) {
						if (_numRenderables > 0) {
							_renderVertexBatch(device, staticRenderData);
							
							_numRenderables = 0;
						}
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_numTriangles = numTriangles;
						_scissorRectangle = renderable.scissorRectangle;
					}
					
					_renderables[_numRenderables++] = renderable;
				} else {
					if (_shaderID == 0) {
						isBreak = false;
						
						if (_numRenderables > 0) {
							_renderVertexBatch(device, staticRenderData);
							
							_numRenderables = 0;
						}
						
						_shaderID = renderable._shaderID;
						_material = renderable._material;
						_materialProperty = renderable._materialProperty;
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numTriangles = numTriangles;
					} else if (_shaderID == renderable._shaderID && _material == renderable._material && _materialProperty == renderable._materialProperty && 
						_texID == tex._rootInstancID && _blendFactors._blendFactorsID == blendFactors._blendFactorsID && 
						_scissorRectangle == renderable.scissorRectangle &&
						_texSampleState == tex._samplerStateData._samplerStateValue) {
						isBreak = false;
						
						_numTriangles += numTriangles;
					}
					
					if (isBreak) {
						_renderCustom(device, staticRenderData);
						
						_numRenderables = 0;
						
						_shaderID = renderable._shaderID;
						_material = renderable._material
						_materialProperty = renderable._materialProperty;
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numTriangles = numTriangles;
					}
					
					_renderables[_numRenderables++] = renderable;
				}
			}
		}
		public override function render(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (_numRenderables > 0) {
				if (_shaderID == 0) {
					_renderVertexBatch(device, staticRenderData);
				} else {
					_renderCustom(device, staticRenderData);
					
					_shaderID = 0;
				}
				
				_blendFactors = null;
				_numRenderables = 0;
			}
		}
		public override function renderStatic(device:Device3D, renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				var pd:ProgramData;
				
				if (sd.shaderID == -1) {
					_vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX] = sd.texture;
					if (_vertexBatchTexFormat != sd.texture._format) {
						_vertexBatchTexFormat = sd.texture._format;
						_vertexBatchMaterial._shaderProgram = _vertexBatchMaterial._shaderCell.getShaderProgram(_vertexBatchMaterial._textures);
					}
					pd = _vertexBatchMaterial._shaderProgram;
				} else {
					pd = Shader3D._shaderPrograms[_shaderID];
				}
				
				device.setBlendFactorsFormData(sd.blendFactors);
				device.setScissorRectangle(sd.scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(pd, sd.material, sd.materialProperty, sd.buffers);
				device._vertexBufferManager.deactiveUnoccupiedVertexBuffers();
				device._textureManager.deactiveUnoccupiedTextures();
				
				sd.indexBuffer.draw();
			}
		}
		public override function destroyStatic(renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				sd.dispose();
				delete _staticMap[renderID];
			}
		}
		private function _renderCustom(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				if (_vertexBatchTriangleNum < _numTriangles) _dilatationVertexBatch(device, _numTriangles);
				
				var index1:int = 0;
				var index2:int = 0;
				var index3:int = 0;
				var numIndex:int = 0;
				var numVertex:int = 0;
				var renderable:BaseRenderable;
				var tex:AbstractTextureData;
				
				for (var i:int = 0; i < _numRenderables; i++) {
					renderable = _renderables[i];
					_renderables[i] = null;
					
					tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
					var region0:Rectangle = tex._region;
					
					var region1:TextureRegion = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
					
					var regionX:Number = region0.x;
					var regionY:Number = region0.y;
					var regionWidth:Number = region0.width;
					var regionHeight:Number = region0.height;
					
					var m00:Number = 1;
					var m01:Number = 0;
					var m10:Number = 0;
					var m11:Number = 1;
					var m30:Number = 0;
					var m31:Number = 0;
					if (region1 != null) {
						regionX += region0.width * region1.x;
						regionY += region0.height * region1.y;
						regionWidth *= region1.width;
						regionHeight *= region1.height;
						
						if (region1.rotate == 0) {
							m00 = regionWidth;
							m11 = regionHeight;
						} else {
							m30 = -0.5;
							m31 = -0.5;
							
							var radian:Number;
							if (region1.rotate == 1) {
								radian = -Math.PI * 0.5;
							} else if (region1.rotate == -1) {
								radian = Math.PI * 0.5;
							} else {
								radian = 0;
							}
							
							var sin:Number = Math.sin(radian);
							var cos:Number = Math.cos(radian);
							m00 = cos;
							m10 = -sin;
							m01 = sin;
							m11 = cos;
							m30 = 0.5 * (sin - cos);
							m31 = -0.5 * (sin + cos);
							
							m30 += 0.5;
							m31 += 0.5;
							
							m00 *= regionWidth;
							m10 *= regionWidth;
							m01 *= regionHeight;
							m11 *= regionHeight;
						}
						
						m30 = m30 * regionWidth + regionX;
						m31 = m31 * regionHeight + regionY;
					}
					
					
					var obj:Object3D = renderable._object3D;
					obj.updateWorldMatrix();
					var l2w:Matrix4x4 = obj._worldMatrix;
					
					var meshAsset:MeshAsset = renderable._meshAsset;
					
					var indices:Vector.<uint> = meshAsset.triangleIndices;
					var len:int = indices.length;
					for (var j:int = 0; j < len; j++) {
						_vertexBatchIndexVector[numIndex++] = numVertex + indices[j];
					}
					
					var elements:Object = meshAsset.elements;
					var vertices:MeshElement = elements[MeshElementType.VERTEX];
					var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
					var color:MeshElement = elements[MeshElementType.COLOR0];
					
					var r:Number;
					var g:Number;
					var b:Number;
					var a:Number;
					if (color == null) {
						r = 1;
						g = 1;
						b = 1;
						a = 1;
					} else {
						var colorValues:Vector.<Number> = color.values;
						r = colorValues[0];
						g = colorValues[1];
						b = colorValues[2];
						a = colorValues[3];
					}
					
					len = vertices.values.length / 2;
					
					numVertex += len;
					
					for (j = 0; j < len; j++) {
						var k:int = j + j;
						
						var x:Number = vertices.values[k++];
						var y:Number = vertices.values[k];
						
						_vertexBatchData1Vector[index1++] = x * l2w.m00 + y * l2w.m10 + l2w.m30;
						_vertexBatchData1Vector[index1++] = x * l2w.m01 + y * l2w.m11 + l2w.m31;
						_vertexBatchData1Vector[index1++] = x * l2w.m02 + y * l2w.m12 + l2w.m32;
						
						k = j + j;
						
						var u:Number = texCoords.values[k++];
						var v:Number = texCoords.values[k];
						
						_vertexBatchData2Vector[index2++] = u * m00 + v * m10 + m30;
						_vertexBatchData2Vector[index2++] = u * m01 + v * m11 + m31;
						
						_vertexBatchData3Vector[index3++] = r;
						_vertexBatchData3Vector[index3++] = g;
						_vertexBatchData3Vector[index3++] = b;
						_vertexBatchData3Vector[index3++] = a * obj._multipliedAlpha;
					}
				}
				
				_vertexBatchData1Buffer.uploadFromVector(_vertexBatchData1Vector);
				_vertexBatchData2Buffer.uploadFromVector(_vertexBatchData2Vector);
				_vertexBatchData3Buffer.uploadFromVector(_vertexBatchData3Vector);
				
				_vertexBatchIndexBuffer.uploadFromVector(_vertexBatchIndexVector);
				
				device.setBlendFactorsFormData(_blendFactors);
				device.setScissorRectangle(_scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(Shader3D._shaderPrograms[_shaderID], _material, _materialProperty, _vertexBatchVertexBuffers);
				device._vertexBufferManager.deactiveUnoccupiedVertexBuffers();
				device._textureManager.deactiveUnoccupiedTextures();
				
				_vertexBatchIndexBuffer.draw(0, _numTriangles);
			} else {
				var sd:StaticData = _createStaticBatch(device);
				sd.material = _material;
				sd.materialProperty = _materialProperty;
				sd.shaderID = _shaderID;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		private function _renderVertexBatch(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				if (_vertexBatchTriangleNum < _numTriangles) _dilatationVertexBatch(device, _numTriangles);
				
				var index1:int = 0;
				var index2:int = 0;
				var index3:int = 0;
				var numIndex:int = 0;
				var numVertex:int = 0;
				var renderable:BaseRenderable;
				var tex:AbstractTextureData;
				
				for (var i:int = 0; i < _numRenderables; i++) {
					renderable = _renderables[i];
					_renderables[i] = null;
					
					tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
					var region0:Rectangle = tex._region;
					
					var region1:TextureRegion = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
					
					var regionX:Number = region0.x;
					var regionY:Number = region0.y;
					var regionWidth:Number = region0.width;
					var regionHeight:Number = region0.height;
					
					var m00:Number = 1;
					var m01:Number = 0;
					var m10:Number = 0;
					var m11:Number = 1;
					var m30:Number = 0;
					var m31:Number = 0;
					if (region1 != null) {
						regionX += region0.width * region1.x;
						regionY += region0.height * region1.y;
						regionWidth *= region1.width;
						regionHeight *= region1.height;
						
						if (region1.rotate == 0) {
							m00 = regionWidth;
							m11 = regionHeight;
						} else {
							var sin:Number;
							var cos:Number;
							if (region1.rotate == 1) {
								sin = -1;
								cos = 0;
								
								m31 = 1;
							} else if (region1.rotate == -1) {
								sin = 1;
								cos = 0;
								
								m30 = 1;
							} else {
								sin = 0;
								cos = 1;
							}
							
							m00 = cos;
							m10 = -sin;
							m01 = sin;
							m11 = cos;
							
							m00 *= regionWidth;
							m10 *= regionWidth;
							m01 *= regionHeight;
							m11 *= regionHeight;
						}
						
						m30 = m30 * regionWidth + regionX;
						m31 = m31 * regionHeight + regionY;
					}
					
					var obj:Object3D = renderable._object3D;
					obj.updateWorldMatrix();
					var l2w:Matrix4x4 = obj._worldMatrix;
					
					var meshAsset:MeshAsset = renderable._meshAsset;
					
					var indices:Vector.<uint> = meshAsset.triangleIndices;
					var len:int = indices.length;
					for (var j:int = 0; j < len; j++) {
						_vertexBatchIndexVector[numIndex++] = numVertex + indices[j];
					}
					
					var elements:Object = meshAsset.elements;
					var vertices:MeshElement = elements[MeshElementType.VERTEX];
					var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
					var color:MeshElement = elements[MeshElementType.COLOR0];
					
					var r:Number;
					var g:Number;
					var b:Number;
					var a:Number;
					if (color == null) {
						r = 1;
						g = 1;
						b = 1;
						a = 1;
					} else {
						var colorValues:Vector.<Number> = color.values;
						r = colorValues[0];
						g = colorValues[1];
						b = colorValues[2];
						a = colorValues[3];
					}
					
					len = vertices.values.length / 2;
					
					numVertex += len;
					
					for (j = 0; j < len; j++) {
						var k:int = j + j;
						
						var x:Number = vertices.values[k++];
						var y:Number = vertices.values[k];
						
						_vertexBatchData1Vector[index1++] = x * l2w.m00 + y * l2w.m10 + l2w.m30;
						_vertexBatchData1Vector[index1++] = x * l2w.m01 + y * l2w.m11 + l2w.m31;
						_vertexBatchData1Vector[index1++] = x * l2w.m02 + y * l2w.m12 + l2w.m32;
						
						k = j + j;
						
						var u:Number = texCoords.values[k++];
						var v:Number = texCoords.values[k];
						
						_vertexBatchData2Vector[index2++] = u * m00 + v * m10 + m30;
						_vertexBatchData2Vector[index2++] = u * m01 + v * m11 + m31;
						
						_vertexBatchData3Vector[index3++] = r;
						_vertexBatchData3Vector[index3++] = g;
						_vertexBatchData3Vector[index3++] = b;
						_vertexBatchData3Vector[index3++] = a * obj._multipliedAlpha;
					}
				}
				
				_vertexBatchData1Buffer.uploadFromVector(_vertexBatchData1Vector);
				_vertexBatchData2Buffer.uploadFromVector(_vertexBatchData2Vector);
				_vertexBatchData3Buffer.uploadFromVector(_vertexBatchData3Vector);
				
				_vertexBatchIndexBuffer.uploadFromVector(_vertexBatchIndexVector);
				
				_vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX] = tex;
				if (_vertexBatchTexFormat != tex._format) {
					_vertexBatchTexFormat = tex._format;
					_vertexBatchMaterial._shaderProgram = _vertexBatchMaterial._shaderCell.getShaderProgram(_vertexBatchMaterial._textures);
				}
				
				device.setBlendFactorsFormData(_blendFactors);
				device.setScissorRectangle(_scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(_vertexBatchMaterial._shaderProgram, _vertexBatchMaterial, null, _vertexBatchVertexBuffers);
				device._vertexBufferManager.deactiveUnoccupiedVertexBuffers();
				device._textureManager.deactiveUnoccupiedTextures();
				
				_vertexBatchIndexBuffer.draw(0, _numTriangles);
			} else {
				var sd:StaticData = _createStaticBatch(device);
				sd.material = _vertexBatchMaterial;
				sd.shaderID = -1;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		private function _createStaticBatch(device:Device3D):StaticData {
			var index1:int = 0;
			var index2:int = 0;
			var renderable:BaseRenderable;
			var tex:AbstractTextureData;
			
			var vertexBatchData0:Vector.<Number> = new Vector.<Number>(_numTriangles * 12);
			var vertexBatchData1:Vector.<Number> = new Vector.<Number>(_numTriangles * 12);
			
			for (var i:int = 0; i < _numRenderables; i++) {
				renderable = _renderables[i];
				_renderables[i] = null;
				
				tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
				var region0:Rectangle = tex._region;
				
				var region1:TextureRegion = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
				
				var regionX:Number = region0.x;
				var regionY:Number = region0.y;
				var regionWidth:Number = region0.width;
				var regionHeight:Number = region0.height;
				
				var m00:Number = 1;
				var m01:Number = 0;
				var m10:Number = 0;
				var m11:Number = 1;
				var m30:Number = 0;
				var m31:Number = 0;
				if (region1 != null) {
					regionX += region0.width * region1.x;
					regionY += region0.height * region1.y;
					regionWidth *= region1.width;
					regionHeight *= region1.height;
					
					if (region1.rotate == 0) {
						m00 = regionWidth;
						m11 = regionHeight;
					} else {
						m30 = -0.5;
						m31 = -0.5;
						
						var radian:Number;
						if (region1.rotate == 1) {
							radian = -Math.PI * 0.5;
						} else if (region1.rotate == -1) {
							radian = Math.PI * 0.5;
						} else {
							radian = 0;
						}
						
						var sin:Number = Math.sin(radian);
						var cos:Number = Math.cos(radian);
						m00 = cos;
						m10 = -sin;
						m01 = sin;
						m11 = cos;
						m30 = 0.5 * (sin - cos);
						m31 = -0.5 * (sin + cos);
						
						m30 += 0.5;
						m31 += 0.5;
						
						m00 *= regionWidth;
						m10 *= regionWidth;
						m01 *= regionHeight;
						m11 *= regionHeight;
					}
					
					m30 = m30 * regionWidth + regionX;
					m31 = m31 * regionHeight + regionY;
				}
				
				var obj:Object3D = renderable._object3D;
				obj.updateWorldMatrix();
				var l2w:Matrix4x4 = obj._worldMatrix;
				
				var elements:Object = renderable._meshAsset.elements;
				var vertices:MeshElement = elements[MeshElementType.VERTEX];
				var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
				var len:int = vertices.values.length / 3;
				
				for (var j:int = 0; j < len; j++) {
					var k:int = j * 3;
					
					var x:Number = vertices.values[k++];
					var y:Number = vertices.values[k++];
					var z:Number = vertices.values[k];
					
					vertexBatchData0[index1++] = x * l2w.m00 + y * l2w.m10 + z * l2w.m20 + l2w.m30;
					vertexBatchData0[index1++] = x * l2w.m01 + y * l2w.m11 + z * l2w.m21 + l2w.m31;
					vertexBatchData0[index1++] = x * l2w.m02 + y * l2w.m12 + z * l2w.m22 + l2w.m32;
					
					k = j + j;
					
					var u:Number = texCoords.values[k++];
					var v:Number = texCoords.values[k];
					
					vertexBatchData1[index2++] = u * m00 + v * m10 + m30;
					vertexBatchData1[index2++] = u * m01 + v * m11 + m31;
					vertexBatchData1[index2++] = obj._multipliedAlpha;
				}
			}
			
			var sd:StaticData = new StaticData();
			
			sd.buffers = {};
			var numVertices:int = _numTriangles * 4;
			var vertexBatchDataBuffer0:VertexBufferData = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			vertexBatchDataBuffer0.format = Context3DVertexBufferFormat.FLOAT_3;
			var vertexBatchDataBuffer1:VertexBufferData = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			vertexBatchDataBuffer1.format = Context3DVertexBufferFormat.FLOAT_3;
			var indexData:Vector.<uint> = MeshHelper.createQuadTriangleIndices(_numTriangles);
			sd.indexBuffer = device._indexBufferManager.createIndexBufferData(indexData.length);
			vertexBatchDataBuffer0.uploadFromVector(vertexBatchData0);
			vertexBatchDataBuffer1.uploadFromVector(vertexBatchData1);
			
			sd.batchData0 = vertexBatchData0;
			sd.batchData1 = vertexBatchData1;
			sd.buffers[BATCH_DATA_BUFFER0] = vertexBatchDataBuffer0;
			sd.buffers[BATCH_DATA_BUFFER1] = vertexBatchDataBuffer1;
			sd.indexBuffer.uploadFromVector(indexData);
			sd.texture = tex;
			sd.blendFactors = _blendFactors;
			sd.scissorRectangle = _scissorRectangle;
			sd.renderer = this;
			
			return sd;
		}
		private function _dilatationVertexBatch(device:Device3D, numTriangles:int):void {
			var newNumTriangles:int = _vertexBatchTriangleNum;
			
			while (newNumTriangles < numTriangles) {
				newNumTriangles *= 2;
			}
			
			var len:int = newNumTriangles * 6;
			
			if (_vertexBatchIndexVector == null) {
				_vertexBatchIndexVector = new Vector.<uint>(len);
			} else {
				_vertexBatchIndexVector.length = len;
			}
			
			var numVertices:int = newNumTriangles * 3;
			
			if (_vertexBatchIndexBuffer == null) {
				_vertexBatchData1Vector = new Vector.<Number>(numVertices * 3);
				_vertexBatchData2Vector = new Vector.<Number>(numVertices * 2);
				_vertexBatchData3Vector = new Vector.<Number>(numVertices * 4);
			} else {
				_vertexBatchIndexBuffer.dispose();
				_vertexBatchData1Buffer.dispose();
				_vertexBatchData2Buffer.dispose();
				_vertexBatchData3Buffer.dispose();
				
				_vertexBatchData1Vector.length = numVertices * 3;
				_vertexBatchData2Vector.length = numVertices * 2;
				_vertexBatchData3Vector.length = numVertices * 4;
			}
			
			_vertexBatchData1Buffer = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			_vertexBatchData1Buffer.format = Context3DVertexBufferFormat.FLOAT_3;
			_vertexBatchData2Buffer = device._vertexBufferManager.createVertexBufferData(numVertices, 2);
			_vertexBatchData2Buffer.format = Context3DVertexBufferFormat.FLOAT_2;
			_vertexBatchData3Buffer = device._vertexBufferManager.createVertexBufferData(numVertices, 4);
			_vertexBatchData3Buffer.format = Context3DVertexBufferFormat.FLOAT_4;
			
			_vertexBatchVertexBuffers[BATCH_DATA_BUFFER0] = _vertexBatchData1Buffer;
			_vertexBatchVertexBuffers[BATCH_DATA_BUFFER1] = _vertexBatchData2Buffer;
			_vertexBatchVertexBuffers[BATCH_DATA_BUFFER2] = _vertexBatchData3Buffer;
			
			_vertexBatchIndexBuffer = device._indexBufferManager.createIndexBufferData(_vertexBatchIndexVector.length);
			
			_vertexBatchTriangleNum = newNumTriangles;
		}
		private function _deviceRecoveryHandler(e:Event):void {
			_dilatationVertexBatch(_device, _vertexBatchTriangleNum);
			
			_vertexBatchMaterial.shader = _device.createShader();
			_vertexBatchMaterial.shader.upload(SpineBatchShaderAsset.asset);
			_vertexBatchMaterial.updateShaderProgram();
			
			for each (var sd:StaticData in _staticMap) {
				sd.recovery();
			}
		}
	}
}
import flash.geom.Rectangle;

import asgl.geometries.MeshHelper;
import asgl.materials.Material;
import asgl.materials.MaterialProperty;
import asgl.renderers.AbstractStaticRenderData;
import asgl.renderers.QuadBatchRenderer;
import asgl.system.AbstractTextureData;
import asgl.system.BlendFactorsData;
import asgl.system.IndexBufferData;
import asgl.system.VertexBufferData;

class StaticData extends AbstractStaticRenderData {
	public var batchData0:Vector.<Number>;
	public var batchData1:Vector.<Number>;
	public var buffers:Object;
	public var indexBuffer:IndexBufferData;
	public var texture:AbstractTextureData;
	public var blendFactors:BlendFactorsData;
	public var scissorRectangle:Rectangle;
	public var shaderID:int;
	public var material:Material;
	public var materialProperty:MaterialProperty;
	
	public override function dispose():void {
		if (buffers != null) {
			for each (var buffer:VertexBufferData in buffers) {
				buffer.dispose();
			}
			buffers = null;
			batchData0 = null;
			batchData1 = null;
			
			indexBuffer.dispose();
			indexBuffer = null;
			
			texture = null;
			blendFactors = null;
			scissorRectangle = null;
			material = null;
			materialProperty = null;
			renderer = null;
		}
	}
	public override function recovery():void {
		if (buffers != null) {
			var vb:VertexBufferData = buffers[QuadBatchRenderer.BATCH_DATA_BUFFER0];
			vb.uploadFromVector(batchData0);
			vb = buffers[QuadBatchRenderer.BATCH_DATA_BUFFER1];
			vb.uploadFromVector(batchData1);
			indexBuffer.uploadFromVector(MeshHelper.createQuadTriangleIndices(indexBuffer.numIndices / 6));
		}
	}
}