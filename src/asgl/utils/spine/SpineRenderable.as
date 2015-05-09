package asgl.utils.spine {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.renderables.BaseRenderable;
	import asgl.renderers.BaseRenderContext;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;
	
	public class SpineRenderable extends BaseRenderable {
		asgl_protected var _data:SpineData;
		
		asgl_protected var _state:SpineState;
		
		protected var _skinName:String;
		
		public function SpineRenderable() {
			_state = new SpineState();
		}
		asgl_protected override function _setObject3D(value:Object3D):void {
			super._setObject3D(value);
			_state.object = _object3D;
		}
		public function get data():SpineData {
			return _data;
		}
		public function set data(value:SpineData):void {
			_data = value;
			
			if (_data == null) {
				_state.clear();
			} else {
				_state.reset(_data);
				_state.setSkin(_skinName);
			}
		}
		public function set createRenderableHandler(value:Function):void {
			_state.createRenderableHandler = value;
		}
		public override function set scissorRectangle(value:Rectangle):void {
			if (_scissorRectangle != value) {
				super.scissorRectangle = value;
				_state.scissorRectangle = _scissorRectangle;
			}
		}
		public function setSkin(name:String):void {
			_skinName = name;
			_state.setSkin(name);
		}
		
		public override function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			for (var i:int = 0; i < _state.numRenderables; i++) {
				var renderable:BaseRenderable = _state.renderables[i];
				context.pushRenderable(renderable);
			}
		}
	}
}