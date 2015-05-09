package asgl.utils.spine.timelines {
	import asgl.asgl_protected;
	import asgl.utils.spine.SpineBone;
	import asgl.utils.spine.SpineBoneState;
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;
	
	use namespace asgl_protected;

	public class SpineScaleTimeline extends SpineCurveTimeline {
		static internal const PREV_FRAME_TIME:int = -3;
		static internal const FRAME_X:int = 1;
		static internal const FRAME_Y:int = 2;
		
		private var _frames:Vector.<Number>;
		private var _boneIndex:int;
		private var _lastIndex:int;
		private var _lastIndex2:int;
		private var _lastIndex3:int;
		
		public function SpineScaleTimeline(numFrames:int, boneIndex:int) {
			super(numFrames);
			_frames = new Vector.<Number>(numFrames * 3, true);
			_boneIndex = boneIndex;
			
			_lastIndex = _frames.length - 1;
			_lastIndex2 = _lastIndex - 1;
			_lastIndex3 = _lastIndex2 - 1;
		}
		public override function get maxTime():Number {
			return _frames[_lastIndex3];
		}
		public function setFrame (frameIndex:int, time:Number, x:Number, y:Number) : void {
			frameIndex *= 3;
			
			_frames[frameIndex++] = time;
			_frames[frameIndex++] = x;
			_frames[frameIndex] = y;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _frames[0]) return;
			
			var bone:SpineBoneState = state.boneStatus[_boneIndex];
			
			var originBone:SpineBone = data.getBoneAt(_boneIndex);
			var sx:Number = originBone.scaleX;
			var sy:Number = originBone.scaleY;
			
			if (time >= _frames[_lastIndex3]) { // Time is after last frame.
				bone.scaleX += (sx * _frames[_lastIndex2] - bone.scaleX);
				bone.scaleY += (sy * _frames[_lastIndex] - bone.scaleY);
				return;
			}
			
			// Interpolate between the previous frame and the current frame.
			var frameIndex:int = SpineTimeline.binarySearch(_frames, time, 3);
			var prevFrameX:Number = _frames[int(frameIndex - 2)];
			var prevFrameY:Number = _frames[int(frameIndex - 1)];
			var frameTime:Number = _frames[frameIndex];
			var percent:Number = 1 - (time - frameTime) / (_frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
			percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
			
			bone.scaleX += sx * (prevFrameX + (_frames[int(frameIndex + FRAME_X)] - prevFrameX) * percent) - bone.scaleX;
			bone.scaleY += sy * (prevFrameY + (_frames[int(frameIndex + FRAME_Y)] - prevFrameY) * percent) - bone.scaleY;
		}
	}
}