package asgl.system {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.VideoTexture;
	import flash.events.VideoTextureEvent;
	import flash.media.Camera;
	import flash.net.NetStream;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.events.ASGLEvent;
	
	use namespace asgl_protected;
	
	[Event(name="renderState", type="flash.events.VideoTextureEvent")]

	public class VideoTextureData extends AbstractTextureData {
		private var _tex:VideoTexture;
		private var _attachObj:*;
		
		public function VideoTextureData(device:Device3D) {
			super(device, Context3DTextureFormat.BGRA, false, 0);
			
			_mipmap = [];
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex = _device._context3D.createVideoTexture();
					_texture = _tex;
					_tex.addEventListener(VideoTextureEvent.RENDER_STATE, _renderStateHandler, false, 0, true);
				}
			}
		}
		public function get videoHeight():int {
			return _tex == null ? 0 : _tex.videoHeight;
		}
		public function get videoWidth():int {
			return _tex == null ? 0 : _tex.videoWidth;
		}
		public override function dispose():void {
			if (_device != null) {
				if (_tex != null) {
					_tex.removeEventListener(VideoTextureEvent.RENDER_STATE, _renderStateHandler);
					_tex.dispose();
					_tex = null;
					_texture = null;
				}
				
				_device._textureManager._disposeTextureData(this);
				_device = null;
				
				_mipmap = null;
				
				_attachObj = null;
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function attachCamera(theCamera:Camera):void {
			if (_tex != null) {
				_tex.attachCamera(theCamera);
				_valid = true;
			}
			_attachObj = theCamera;
		}
		public function attachNetStream(netStream:NetStream):void {
			if (_tex != null) {
				_tex.attachNetStream(netStream);
				_valid = true;
			}
			_attachObj = netStream;
		}
		asgl_protected override function _lost():void {
			_tex.removeEventListener(VideoTextureEvent.RENDER_STATE, _renderStateHandler);
			_tex = null;
			_texture = null;
			_valid = false;
		}
		asgl_protected override function _recovery():void {
			if (_device._context3D.driverInfo == Device3D.DISPOSED) {
				_device._lost();
			} else {
				_tex = _device._context3D.createVideoTexture();
				_texture = _tex;
				_tex.addEventListener(VideoTextureEvent.RENDER_STATE, _renderStateHandler, false, 0, true);
				
				if (_attachObj != null) {
					if (_attachObj is Camera3D) {
						attachCamera(_attachObj);
					} else {
						attachNetStream(_attachObj);
					}
				}
			}
		}
		protected function _renderStateHandler(e:VideoTextureEvent):void {
			if (hasEventListener(VideoTextureEvent.RENDER_STATE)) dispatchEvent(e);
		}
	}
}