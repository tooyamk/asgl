package asgl.utils.spine.timelines {
	import asgl.math.Float4;
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;

	public class SpineColorTimeline extends SpineCurveTimeline {
		static private const PREV_FRAME_TIME:int = -5;
		
		private var _slotIndex:int;
		private var _frames:Vector.<Number>; // time, ...
		private var _lastIndex:int;
		private var _lastIndex2:int;
		private var _lastIndex3:int;
		private var _lastIndex4:int;
		private var _lastIndex5:int;
		
		public function SpineColorTimeline(numFrames:int, slotIndex:int) {
			super(numFrames);
			_slotIndex = slotIndex;
			_frames = new Vector.<Number>(numFrames * 5);
			_lastIndex = _frames.length - 1;
			_lastIndex2 = _lastIndex - 1;
			_lastIndex3 = _lastIndex - 2;
			_lastIndex4 = _lastIndex - 3;
			_lastIndex5 = _lastIndex - 4;
		}
		public override function get maxTime():Number {
			return _frames[_lastIndex5];
		}
		public function setFrame (frameIndex:int, time:Number, r:Number, g:Number, b:Number, a:Number) : void {
			frameIndex *= 5;
			_frames[frameIndex++] = time;
			_frames[frameIndex++] = r;
			_frames[frameIndex++] = g;
			_frames[frameIndex++] = b;
			_frames[frameIndex] = a;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _frames[0]) return;
			
			var r:Number, g:Number, b:Number, a:Number;
			if (time >= _frames[_lastIndex5]) {
				// Time is after last frame.
				r = _frames[_lastIndex4];
				g = _frames[_lastIndex3];
				b = _frames[_lastIndex2];
				a = _frames[_lastIndex];
			} else {
				// Interpolate between the previous frame and the current frame.
				var frameIndex:int = SpineTimeline.binarySearch(_frames, time, 5);
				var prevFrameR:Number = _frames[int(frameIndex - 4)];
				var prevFrameG:Number = _frames[int(frameIndex - 3)];
				var prevFrameB:Number = _frames[int(frameIndex - 2)];
				var prevFrameA:Number = _frames[int(frameIndex - 1)];
				var frameTime:Number = _frames[frameIndex];
				var percent:Number = 1 - (time - frameTime) / (_frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
				percent = getCurvePercent(frameIndex / 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
				
				r = prevFrameR + (_frames[++frameIndex] - prevFrameR) * percent;
				g = prevFrameG + (_frames[++frameIndex] - prevFrameG) * percent;
				b = prevFrameB + (_frames[++frameIndex] - prevFrameB) * percent;
				a = prevFrameA + (_frames[++frameIndex] - prevFrameA) * percent;
			}
			
			var color:Float4 = state.slotStatus[_slotIndex].color;
			color.x = r;
			color.y = g;
			color.z = b;
			color.w = a;
		}
	}
}