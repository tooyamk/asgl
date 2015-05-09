package asgl.utils.spine {
	import asgl.math.Float4;
	import asgl.system.BlendFactorsData;

	public class SpineSlot {
		public var attachmentName:String;
		public var blendMode:BlendFactorsData;
		public var color:Float4;
		public var index:int;
		
		private var _bone:SpineBone;
		private var _name:String;
		
		public function SpineSlot(name:String, bone:SpineBone) {
			_name= name;
			_bone = bone;
		}
		public function get bone():SpineBone {
			return _bone;
		}
		public function get name():String {
			return _name;
		}
	}
}