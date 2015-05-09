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

	public class SpineMeshAttachment extends SpineAttachment {
		public var textureRegion:TextureRegion;
		
		public var vertices:Vector.<Number>;
		public var texCoords:Vector.<Number>;
		public var triangleIndices:Vector.<uint>;
		
		public function SpineMeshAttachment(name:String, color:Float4) {
			super(name, color);
		}
		public override function createRenderable():BaseRenderable {
			var renderable:BaseRenderable = super.createRenderable();
			
			var meshAsset:MeshAsset = renderable._meshAsset;
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 2;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			vertexElement.values = vertices.concat();
			meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			texCoordElement.values = texCoords.concat();
			meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			meshAsset.triangleIndices = triangleIndices.concat();
			
			renderable.setTextureRegion(ShaderPropertyType.DIFFUSE_TEX, textureRegion);
			
			return renderable;
		}
		public override function updateRenderable(renderable:BaseRenderable,  slot:SpineSlotState, boneStatus:Vector.<SpineBoneState>, boneIndex:int):void {
			var meshAsset:MeshAsset = renderable._meshAsset;
			var vers:Vector.<Number> = meshAsset.elements[MeshElementType.VERTEX].values;
			var color:Vector.<Number> = meshAsset.elements[MeshElementType.COLOR0].values;
			
			var slotColor:Float4 = slot.color;
			color[0] = slotColor.x * _color.x;
			color[1] = slotColor.y * _color.y;
			color[2] = slotColor.z * _color.z;
			color[3] = slotColor.w * _color.w;
			
			var bone:SpineBoneState = boneStatus[boneIndex];
			
			var x:Number = bone.worldX;
			var y:Number = bone.worldY;
			var m00:Number = bone.m00;
			var m01:Number = bone.m01;
			var m10:Number = bone.m10;
			var m11:Number = bone.m11;
			
			var src:Vector.<Number> = vertices;
			var len:int = src.length;
			if (slot.attachmentVertices.length == len) src = slot.attachmentVertices;
			
			var index:int = 0;
			for (var i:int = 0; i < len;) {
				var vx:Number = src[i++];
				var vy:Number = src[i++];
				vers[index++] = vx * m00 + vy * m01 + x;
				vers[index++] = vx * m10 + vy * m11 + y;
			}
		}
	}
}