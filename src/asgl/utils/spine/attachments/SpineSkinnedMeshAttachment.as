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

	public class SpineSkinnedMeshAttachment extends SpineAttachment {
		public var textureRegion:TextureRegion;
		
		public var bones:Vector.<int>;
		public var weights:Vector.<Number>;
		public var texCoords:Vector.<Number>;
		public var triangleIndices:Vector.<uint>;
		
		public function SpineSkinnedMeshAttachment(name:String, color:Float4) {
			super(name, color);
		}
		public override function createRenderable():BaseRenderable {
			var renderable:BaseRenderable = super.createRenderable();
			
			var meshAsset:MeshAsset = renderable._meshAsset;
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 2;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			vertexElement.values = new Vector.<Number>();
			meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			texCoordElement.values = texCoords.concat();;
			meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			meshAsset.triangleIndices = triangleIndices.concat();
			
			renderable.setTextureRegion(ShaderPropertyType.DIFFUSE_TEX, textureRegion);
			
			return renderable;
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
			
			var w:int = 0, v:int = 0, b:int = 0, f:int = 0, n:int = bones.length, nn:int;
			var wx:Number, wy:Number, bone:SpineBoneState, vx:Number, vy:Number, weight:Number;
			if (slot.attachmentVertices.length == 0) {
				for (; v < n;) {
					wx = 0;
					wy = 0;
					nn = bones[v++] + v;
					for (; v < nn; v++) {
						bone = boneStatus[bones[v]];
						vx = weights[b++];
						vy = weights[b++];
						weight = weights[b++];
						wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
						wy += (vx * bone.m10 + vy * bone.m11 + bone.worldY) * weight;
					}
					vertices[w++] = wx;
					vertices[w++] = wy;
				}
			} else {
				var ffd:Vector.<Number> = slot.attachmentVertices;
				for (; v < n;) {
					wx = 0;
					wy = 0;
					nn = bones[v++] + v;
					for (; v < nn; v++) {
						bone = boneStatus[bones[v]];
						vx = weights[b++] + ffd[f++];
						vy = weights[b++] + ffd[f++];
						weight = weights[b++];
						wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
						wy += (vx * bone.m10 + vy * bone.m11 + bone.worldY) * weight;
					}
					vertices[w++] = wx;
					vertices[w++] = wy;
				}
			}
		}
	}
}