package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineIkConstraintState;
	import asgl.utils.spine.SpineState;

	public class SpineIkConstraintTimeline extends SpineCurveTimeline {
		private static const PREV_FRAME_TIME:int = -3;
		private static const PREV_FRAME_MIX:int = -2;
		private static const PREV_FRAME_BEND_DIRECTION:int = -1;
		private static const FRAME_MIX:int = 1;
		
		private var _ikConstraintIndex:int;
		private var _frames:Vector.<Number>; // time, mix, bendDirection, ...
		private var _lastIndex:int;
		private var _lastIndex2:int;
		private var _lastIndex3:int;
		
		public function SpineIkConstraintTimeline(numFrames:int, ikConstraintIndex:int) {
			super(numFrames);
			
			_ikConstraintIndex = ikConstraintIndex;
			_frames = new Vector.<Number>(numFrames * 3);
			_lastIndex = _frames.length - 1;
			_lastIndex2 = _lastIndex - 1;
			_lastIndex3 = _lastIndex2 - 1;
		}
		public override function get maxTime():Number {
			return _frames[_lastIndex3];
		}
		/** Sets the time, mix and bend direction of the specified keyframe. */
		public function setFrame (frameIndex:int, time:Number, mix:Number, bendDirection:int) : void {
			frameIndex *= 3;
			_frames[frameIndex++] = time;
			_frames[frameIndex++] = mix;
			_frames[frameIndex] = bendDirection;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _frames[0]) return; // Time is before first frame.
			
			var ik:SpineIkConstraintState = state.ikConstraintStatus[_ikConstraintIndex];
			
			if (time >= _frames[_lastIndex3]) { // Time is after last frame.
				ik.mix += _frames[_lastIndex2] - ik.mix;
				ik.bendDirection = _frames[_lastIndex];
				return;
			}
			
			// Interpolate between the previous frame and the current frame.
			var frameIndex:int = SpineTimeline.binarySearch(_frames, time, 3);
			var prevFrameMix:Number = _frames[int(frameIndex + PREV_FRAME_MIX)];
			var frameTime:Number = _frames[frameIndex];
			var percent:Number = 1 - (time - frameTime) / (_frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
			percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
			
			var mix:Number = prevFrameMix + (_frames[int(frameIndex + FRAME_MIX)] - prevFrameMix) * percent;
			ik.mix += mix - ik.mix;
			ik.bendDirection = _frames[int(frameIndex + PREV_FRAME_BEND_DIRECTION)];
		}
	}
}