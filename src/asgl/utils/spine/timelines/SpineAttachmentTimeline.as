package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineSlot;
	import asgl.utils.spine.SpineSlotState;
	import asgl.utils.spine.SpineState;
	
	public class SpineAttachmentTimeline extends SpineTimeline {
		private var _slotIndex:int;
		private var _times:Vector.<Number>; // time, ...
		private var _attachmentNames:Vector.<String>;
		private var _lastIndex:int;
		
		public function SpineAttachmentTimeline(numFrames:int, slotIndex:int) {
			_slotIndex = slotIndex;
			_times = new Vector.<Number>(numFrames);
			_attachmentNames = new Vector.<String>(numFrames);
			_lastIndex = numFrames - 1;
		}
		public override function get maxTime():Number {
			return _times[_lastIndex];
		}
		public function setFrame (frameIndex:int, time:Number, attachmentName:String) : void {
			_times[frameIndex] = time;
			_attachmentNames[frameIndex] = attachmentName;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _times[0]) {
				if (lastTime > time) {
					var slot:SpineSlot = data.getSlotAt(_slotIndex);
					state.slotStatus[_slotIndex].attachment = state.getAttachment(slot.index, slot.attachmentName);
				}
				return;
			} else if (lastTime > time) {
				lastTime = -1;
			}
			
			var frameIndex:int = time >= _times[_lastIndex] ? _lastIndex : SpineTimeline.binarySearch1(_times, time) - 1;
			if (_times[frameIndex] < lastTime) return;
			
			var slotState:SpineSlotState = state.slotStatus[_slotIndex];
			slotState.attachment = state.getAttachment(_slotIndex, _attachmentNames[frameIndex]);
			slotState.attachmentVertices.length = 0;
		}
	}
}