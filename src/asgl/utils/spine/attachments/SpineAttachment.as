package asgl.utils.spine.attachments {
	import asgl.asgl_protected;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.materials.Material;
	import asgl.math.Float4;
	import asgl.renderables.BaseRenderable;
	import asgl.renderers.BaseRenderer;
	import asgl.utils.spine.SpineBoneState;
	import asgl.utils.spine.SpineSlotState;
	
	use namespace asgl_protected;

	public class SpineAttachment {
		private static const COLOR:Vector.<Number> = new Vector.<Number>([1, 1, 1, 1]);
		
		private static var _instanceIDAccumulator:uint = 0;
		
		asgl_protected var _instanceID:uint;
		
		protected var _name:String;
		protected var _color:Float4;
		
		public function SpineAttachment(name:String, color:Float4) {
			_instanceID = ++_instanceIDAccumulator;
			
			_name = name;
			_color = color;
		}
		public function get name():String {
			return _name;
		}
		public function createRenderable():BaseRenderable {
			var renderable:BaseRenderable = new BaseRenderable();
			var meshAsset:MeshAsset = new MeshAsset();
			renderable._meshAsset = meshAsset;
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.values = COLOR.concat();
			meshAsset.elements[MeshElementType.COLOR0] = vertexElement;
			
			return renderable;
		}
		public function updateRenderable(renderable:BaseRenderable, slot:SpineSlotState, boneStatus:Vector.<SpineBoneState>, boneIndex:int):void {
		}
	}
}