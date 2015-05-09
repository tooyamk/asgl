package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineBoneState;
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;

	public class SpineFlipXTimeline extends SpineTimeline {
		private var _boneIndex:int;
		private var _frames:Vector.<Number>; // time, flip, ...
		private var _lastIndex:int;
		private var _lastIndex2:int;
		
		public function SpineFlipXTimeline(numFrames:int, boneIndex:int) {
			_boneIndex = boneIndex;
			_frames = new Vector.<Number>(numFrames * 2);
			_lastIndex = _frames.length - 1;
			_lastIndex2 = _lastIndex - 1;
		}
		public override function get maxTime():Number {
			return _frames[_lastIndex2];
		}
		public function setFrame (frameIndex:int, time:Number, flip:Boolean) : void {
			frameIndex *= 2;
			_frames[frameIndex++] = time;
			_frames[frameIndex] = flip ? 1 : 0;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _frames[0]) {
				if (lastTime > time) update(state, data, int.MAX_VALUE, lastTime);
				return;
			} else if (lastTime > time) {
				lastTime = -1;
			}
			
			var frameIndex:int = time >= _frames[_lastIndex2] ? _lastIndex2 : SpineTimeline.binarySearch(_frames, time, 2) - 2;
			if (_frames[frameIndex] < lastTime) return;
			
			_setFlip(state.boneStatus[_boneIndex], _frames[int(frameIndex + 1)] != 0);
		}
		protected function _setFlip(bone:SpineBoneState, flip:Boolean) : void {
			bone.flipX = flip;
		}
	}
}