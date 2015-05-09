package asgl.utils.spine.timelines {
	import asgl.utils.spine.attachments.SpineAttachment;
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineSlotState;
	import asgl.utils.spine.SpineState;
	
	

	public class SpineFfdTimeline extends SpineCurveTimeline {
		private var _slotIndex:int;
		private var _attachment:SpineAttachment;
		private var _times:Vector.<Number>;
		private var _frameVertices:Vector.<Vector.<Number>>;
		private var _lastIndex:int;
		
		public function SpineFfdTimeline(numFrames:int, slotIndex:int, attachment:SpineAttachment) {
			super(numFrames);
			_slotIndex = slotIndex;
			_attachment = attachment;
			_times = new Vector.<Number>(numFrames);
			_frameVertices = new Vector.<Vector.<Number>>(numFrames);
			_lastIndex = numFrames - 1;
		}
		public function setFrame(frameIndex:int, time:Number, vertices:Vector.<Number>) : void {
			_times[frameIndex] = time;
			_frameVertices[frameIndex] = vertices;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			var slot:SpineSlotState = state.slotStatus[_slotIndex];
			if (slot.attachment != _attachment) return;
			
			if (time < _times[0]) {
				slot.attachmentVertices.length = 0;
				return; // Time is before first frame.
			}
			
			var vertexCount:int = _frameVertices[0].length;
			
			var vertices:Vector.<Number> = slot.attachmentVertices;
			vertices.length = vertexCount;
			
			var i:int;
			if (time >= _times[_lastIndex]) { // Time is after last frame.
				var lastVertices:Vector.<Number> = _frameVertices[_lastIndex];
				for (i = 0; i < vertexCount; i++) {
					vertices[i] = lastVertices[i];
				}
				return;
			}
			
			// Interpolate between the previous frame and the current frame.
			var frameIndex:int = SpineTimeline.binarySearch(_times, time, 1);
			var frameTime:Number = _times[frameIndex];
			var prevFrameIndex:int = frameIndex - 1;
			var percent:Number = 1 - (time - frameTime) / (_times[prevFrameIndex] - frameTime);
			percent = getCurvePercent(frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
			
			var prevVertices:Vector.<Number> = _frameVertices[prevFrameIndex];
			var nextVertices:Vector.<Number> = _frameVertices[frameIndex];
			
			for (i = 0; i < vertexCount; i++) {
				var prev:Number = prevVertices[i];
				vertices[i] = prev + (nextVertices[i] - prev) * percent;
			}
		}
	}
}