package asgl.system {
	import flash.display3D.Context3DProfile;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class Device3DProfile {
		asgl_protected var _profile:String;
		asgl_protected var _vertexConstantsMax:int;
		asgl_protected var _fragmentConstantsMax:int;
		
		public function Device3DProfile() {
		}
		public function get fragmentConstantsMax():int {
			return _fragmentConstantsMax;
		}
		public function get profile():String {
			return _profile;
		}
		public function get vertexConstantsMax():int {
			return _vertexConstantsMax;
		}
		asgl_protected function setProfile(value:String):void {
			_profile = value;
			
			if (value == Context3DProfile.STANDARD) {
				_vertexConstantsMax = 250;
				_fragmentConstantsMax = 64;
			} else {
				_vertexConstantsMax = 128;
				_fragmentConstantsMax = 28;
			}
		}
	}
}