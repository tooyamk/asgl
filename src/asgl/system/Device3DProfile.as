package asgl.system {
	import flash.display3D.Context3DProfile;
	
	import asgl.asgl_protected;
	import asgl.shaders.asm.agal.compiler.AGALConfiguration;
	
	use namespace asgl_protected;

	public class Device3DProfile {
		asgl_protected var _profile:String;
		asgl_protected var _agalConfiguration:AGALConfiguration;
		
		public function Device3DProfile() {
		}
		public function get agalConfiguration():AGALConfiguration {
			return _agalConfiguration;
		}
		public function get profile():String {
			return _profile;
		}
		asgl_protected function setProfile(value:String):void {
			_profile = value;
			
			var agalVersion:int;
			
			if (value == Context3DProfile.BASELINE_CONSTRAINED) {
				agalVersion = 1;
			} else if (value == Context3DProfile.BASELINE) {
				agalVersion = 1;
			} else if (value == Context3DProfile.BASELINE_EXTENDED) {
				agalVersion = 1;
			} else if (value == Context3DProfile.STANDARD_CONSTRAINED) {
				agalVersion = 2;
			} else if (value == Context3DProfile.STANDARD) {
				agalVersion = 2;
			} else if (value == Context3DProfile.STANDARD_EXTENDED) {
				agalVersion = 3;
			} else {
				agalVersion = 0;
			}
			
			_agalConfiguration = new AGALConfiguration(agalVersion);
		}
	}
}