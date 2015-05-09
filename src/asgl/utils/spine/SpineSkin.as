package asgl.utils.spine {
	import asgl.utils.spine.attachments.SpineAttachment;

	public class SpineSkin {
		private var _name:String;
		private var _attachments:Vector.<Object> = new Vector.<Object>();
		
		public function SpineSkin(name:String) {
			_name = name;
			_attachments = new Vector.<Object>();
		}
		public function get name():String {
			return _name;
		}
		public function addAttachment (slotIndex:int, name:String, attachment:SpineAttachment) : void {
			if (slotIndex >= _attachments.length) _attachments.length = slotIndex + 1;
			
			var map:Object = _attachments[slotIndex];
			if (map == null) {
				map = {};
				_attachments[slotIndex] = map;
			}
			
			map[name] = attachment;
		}
		public function getAttachment(slotIndex:int, name:String):SpineAttachment {
			if (slotIndex >= _attachments.length) return null;
			var map:Object = _attachments[slotIndex];
			return map == null ? null : map[name];
		}
	}
}