package asgl.utils.spine.attachments {
	import asgl.asgl_protected;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.materials.TextureRegion;
	import asgl.math.Float4;
	import asgl.renderables.BaseRenderable;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.utils.spine.SpineBoneState;
	import asgl.utils.spine.SpineSlotState;
	
	use namespace asgl_protected;

	public class SpineRegionAttachment extends SpineAttachment {
		private static const INDEX:Vector.<uint> = Vector.<uint>([0, 1, 2, 2, 3, 0]);
		
		public var textureRegion:TextureRegion;
		
		private var _x0:Number;
		private var _y0:Number;
		private var _x1:Number;
		private var _y1:Number;
		private var _x2:Number;
		private var _y2:Number;
		private var _x3:Number;
		private var _y3:Number;
		
		public function SpineRegionAttachment(name:String, color:Float4) {
			super(name, color);
		}
		public override function createRenderable():BaseRenderable {
			var renderable:BaseRenderable = super.createRenderable();
			
			var meshAsset:MeshAsset = renderable._meshAsset;
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 2;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var vertices:Vector.<Number> = new Vector.<Number>(8);
			vertexElement.values = vertices;
			meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var texCoords:Vector.<Number> = new Vector.<Number>(8);
			texCoordElement.values = texCoords;
			meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			texCoords[1] = 1;
			
			texCoords[4] = 1;
			
			texCoords[6] = 1;
			texCoords[7] = 1;
			
			meshAsset.triangleIndices = INDEX.concat();
			
			renderable.setTextureRegion(ShaderPropertyType.DIFFUSE_TEX, textureRegion);
			
			return renderable;
		}
		public function setLocalMesh(x:Number, y:Number, w:Number, h:Number, sx:Number, sy:Number, rotation:Number):void {
			var regionScaleX:Number = w / textureRegion.originalPixelWidth * sx;
			var regionScaleY:Number = h / textureRegion.originalPixelHeight * sy;
			var localX:Number = -w * 0.5 * sx + textureRegion.offsetPixelX * regionScaleX;
			var localY:Number = -h * 0.5 * sy + textureRegion.offsetPixelY * regionScaleY;
			var localX2:Number = localX + textureRegion.pixelWidth * regionScaleX;
			var localY2:Number = localY + textureRegion.pixelHeight * regionScaleY;
			var cos:Number = Math.cos(rotation);
			var sin:Number = Math.sin(rotation);
			var localXCos:Number = localX * cos + x;
			var localXSin:Number = localX * sin;
			var localYCos:Number = localY * cos + y;
			var localYSin:Number = localY * sin;
			var localX2Cos:Number = localX2 * cos + x;
			var localX2Sin:Number = localX2 * sin;
			var localY2Cos:Number = localY2 * cos + y;
			var localY2Sin:Number = localY2 * sin;
			_x0 = localXCos - localYSin;
			_y0 = localYCos + localXSin;
			_x1 = localXCos - localY2Sin;
			_y1 = localY2Cos + localXSin;
			_x2 = localX2Cos - localY2Sin;
			_y2 = localY2Cos + localX2Sin;
			_x3 = localX2Cos - localYSin;
			_y3 = localYCos + localX2Sin;
		}
		public override function updateRenderable(renderable:BaseRenderable,  slot:SpineSlotState, boneStatus:Vector.<SpineBoneState>, boneIndex:int):void {
			var meshAsset:MeshAsset = renderable._meshAsset;
			var vertices:Vector.<Number> = meshAsset.elements[MeshElementType.VERTEX].values;
			var color:Vector.<Number> = meshAsset.elements[MeshElementType.COLOR0].values;
			
			var slotColor:Float4 = slot.color;
			color[0] = slotColor.x * _color.x;
			color[1] = slotColor.y * _color.y;
			color[2] = slotColor.z * _color.z;
			color[3] = slotColor.w * _color.w;
			
			var bone:SpineBoneState = boneStatus[boneIndex];
			
			var x:Number  = bone.worldX;
			var y:Number = bone.worldY;
			var m00:Number = bone.m00;
			var m01:Number = bone.m01;
			var m10:Number = bone.m10;
			var m11:Number = bone.m11;
			var x1:Number = _x0;
			var y1:Number = _y0;
			var x2:Number = _x1;
			var y2:Number = _y1;
			var x3:Number = _x2;
			var y3:Number = _y2;
			var x4:Number = _x3;
			var y4:Number = _y3;
			vertices[0] = x1 * m00 + y1 * m01 + x;
			vertices[1] = x1 * m10 + y1 * m11 + y;
			vertices[2] = x2 * m00 + y2 * m01 + x;
			vertices[3] = x2 * m10 + y2 * m11 + y;
			vertices[4] = x3 * m00 + y3 * m01 + x;
			vertices[5] = x3 * m10 + y3 * m11 + y;
			vertices[6] = x4 * m00 + y4 * m01 + x;
			vertices[7] = x4 * m10 + y4 * m11 + y;
		}
	}
}