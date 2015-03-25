package asgl.effects.postprocess {
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.events.Event;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.materials.Material;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.AbstractTextureData;
	import asgl.system.Device3D;
	import asgl.system.IndexBufferData;
	import asgl.system.VertexBufferData;
	
	use namespace asgl_protected;

	public class PostProcessExecutor {
		private static var _vertices:Vector.<Number> = Vector.<Number>([-1, 1, 0, 0, 1, 1, 1, 0, 1, -1, 1, 1, -1, -1, 0, 1]);
		private static var _indices:Vector.<uint> = Vector.<uint>([0, 1, 2, 0, 2, 3]);
		
		private var _device:Device3D;
		private var _vertexBuffer:VertexBufferData;
		private var _indexBuffer:IndexBufferData;
		
		public function PostProcessExecutor(device:Device3D) {
			_device = device;
			
			_vertexBuffer = _device._vertexBufferManager.createVertexBufferData(4, 4);
			_vertexBuffer.format = Context3DVertexBufferFormat.FLOAT_4;
			
			_indexBuffer = _device._indexBufferManager.createIndexBufferData(6);
			
			_device.addEventListener(ASGLEvent.RECOVERY, _recoveryHandler, false, 0, true);
			_recoveryHandler(null);
		}
		public function dispose():void {
			if (_device != null) {
				_device.removeEventListener(ASGLEvent.RECOVERY, _recoveryHandler);
				_device = null;
				
				_vertexBuffer.dispose();
				_vertexBuffer = null;
				
				_indexBuffer.dispose();
				_indexBuffer = null;
			}
		}
		public function render(postProcessers:Vector.<PostProcesser>, source:Vector.<AbstractTextureData>, destination:Vector.<AbstractTextureData>):void {
			var src:Vector.<AbstractTextureData> = source;
			var dest:Vector.<AbstractTextureData>;
			
			var len:int = postProcessers.length;
			if (len > 0) {
				_device.setCulling(Context3DTriangleFace.NONE);
				_device.setDepthTest(false, Context3DCompareMode.ALWAYS);
				
				for (var i:int = 0; i < len; i++) {
					var pp:PostProcesser = postProcessers[i];
					
					dest = i + 1 == len ? destination : pp.renderTargets;
					
					pp.execute(this, src, dest);
					
					src = dest;
				}
			}
		}
		asgl_protected function _draw(postProcesser:PostProcesser, source:Vector.<AbstractTextureData>, dest:Vector.<AbstractTextureData>):void {
			var material:Material = postProcesser.material;
			
			var i:int;
			var src:AbstractTextureData;
			var numSrc:int;
			if (source != null) {
				numSrc = source.length;
				for (i = 0; i < numSrc; i++) {
					src = source[i];
					if (src == null) continue;
					if (i == 0) {
						material.setTexture(ShaderPropertyType.SOURCE_TEX, src);
					} else {
						material.setTexture(ShaderPropertyType.SOURCE_TEX + i, src);
					}
				}
			}
			
			material.updateShaderProgram();
			
			if (material._shaderProgram != null) {
				if (dest == null) {
					_device.setRenderToBackBuffer();
				} else {
					_device.setRenderToTargets(dest);
				}
				
				_device.clearFromData(postProcesser._clearData);
				_device.setDepthTest(false, Context3DCompareMode.ALWAYS);
				if (postProcesser.blendFactors != null) _device.setBlendFactorsFormData(postProcesser.blendFactors);
				
				postProcesser.buffers[ShaderPropertyType.VERTEX_BUFFER] = _vertexBuffer;
				
				_device._vertexBufferManager.resetOccupiedState();
				_device._textureManager.resetOccupiedState();
				if (_device.setRenderData(material._shaderProgram, material, null, postProcesser.buffers)) {
					_device._vertexBufferManager.deactiveUnoccupiedVertexBuffers();
					_device._textureManager.deactiveUnoccupiedTextures();
					
					_device.drawTrianglesFromData(_indexBuffer);
				}
				
				delete postProcesser.buffers[ShaderPropertyType.VERTEX_BUFFER];
			}
			
			if (source != null) {
				for (i = 0; i < numSrc; i++) {
					src = source[i];
					if (src == null) continue;
					if (i == 0) {
						material.setTexture(ShaderPropertyType.SOURCE_TEX, null);
					} else {
						material.setTexture(ShaderPropertyType.SOURCE_TEX + i, null);
					}
				}
			}
		}
		private function _recoveryHandler(e:Event):void {
			_vertexBuffer.uploadFromVector(_vertices);
			_indexBuffer.uploadFromVector(_indices);
		}
	}
}