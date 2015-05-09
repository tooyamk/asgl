package asgl.utils.spine {
	import asgl.math.Float4;
	import asgl.utils.spine.attachments.SpineAttachment;

	public class SpineSlotState {
		public var attachment:SpineAttachment;
		public var attachmentVertices:Vector.<Number>;
		public var color:Float4;
		
		public function SpineSlotState() {
			attachmentVertices = new Vector.<Number>();
			color = new Float4(1, 1, 1, 1);
		}
		public function setPose(slot:SpineSlot, state:SpineState):void {
			attachmentVertices.length = 0;
			
			if (slot == null) {
				color.x = 1;
				color.y = 1;
				color.z = 1;
				color.w = 1;
				attachment = null;
			} else {
				color.x = slot.color.x;
				color.y = slot.color.y;
				color.z = slot.color.z;
				color.w = slot.color.w;
				attachment = state.getAttachment(slot.index, slot.attachmentName);
			}
		}
	}
}