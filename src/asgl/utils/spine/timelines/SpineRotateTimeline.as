package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineBone;
	import asgl.utils.spine.SpineBoneState;
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;
	

	public class SpineRotateTimeline extends SpineCurveTimeline {
		private static const PREV_FRAME_TIME:int = -2;
		private static const FRAME_VALUE:int = 1;
		
		private static const PI2:Number = Math.PI * 2;
		
		private var _frames:Vector.<Number>;
		private var _boneIndex:int;
		private var _lastIndex:int;
		private var _lastIndex2:int;
		
		public function SpineRotateTimeline(numFrames:int, boneIndex:int) {
			super(numFrames);
			_frames = new Vector.<Number>(numFrames * 2);
			_boneIndex = boneIndex;
			
			_lastIndex = _frames.length - 1;
			_lastIndex2 = _lastIndex - 1;
		}
		public override function get maxTime():Number {
			return _frames[_lastIndex2];
		}
		public function setFrame (frameIndex:int, time:Number, angle:Number) : void {
			frameIndex *= 2;
			
			_frames[frameIndex++] = time;
			_frames[frameIndex] = angle;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _frames[0]) return;
			
			var bone:SpineBoneState = state.boneStatus[_boneIndex];
			
			var originBone:SpineBone = data.getBoneAt(_boneIndex);
			
			var amount:Number;
			if (time >= _frames[_lastIndex2]) { // Time is after last frame.
				amount = originBone.rotation + _frames[_lastIndex] - bone.rotation;
				while (amount > Math.PI)
					amount -= PI2;
				while (amount < -Math.PI)
					amount += PI2;
				bone.rotation += amount;
				return;
			}
			
			// Interpolate between the previous frame and the current frame.
			var frameIndex:int = SpineTimeline.binarySearch(_frames, time, 2);
			var prevFrameValue:Number = _frames[int(frameIndex - 1)];
			var frameTime:Number = _frames[frameIndex];
			var percent:Number = 1 - (time - frameTime) / (_frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
			percent = getCurvePercent(frameIndex / 2 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));
			
			amount = _frames[int(frameIndex + FRAME_VALUE)] - prevFrameValue;
			while (amount > Math.PI)
				amount -= PI2;
			while (amount < -Math.PI)
				amount += PI2;
			amount = originBone.rotation + (prevFrameValue + amount * percent) - bone.rotation;
			while (amount > Math.PI)
				amount -= PI2;
			while (amount < -Math.PI)
				amount += PI2;
			
			bone.rotation += amount;
		}
	}
}