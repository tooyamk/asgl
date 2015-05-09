package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;

	public class SpineDrawOrderTimeline extends SpineTimeline {
		private var _times:Vector.<Number>; // time, ...
		private var _drawOrders:Vector.<Vector.<int>>;
		private var _lastIndex:int;
		
		public function SpineDrawOrderTimeline(numFrames:int) {
			_times = new Vector.<Number>(numFrames);
			_drawOrders = new Vector.<Vector.<int>>(numFrames);
			_lastIndex = numFrames - 1;
		}
		public override function get maxTime():Number {
			return _times[_lastIndex];
		}
		public function setFrame (frameIndex:int, time:Number, drawOrder:Vector.<int>) : void {
			_times[frameIndex] = time;
			_drawOrders[frameIndex] = drawOrder;
		}
		public override function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
			if (time < _times[0]) return;
			
			var frameIndex:int;
			if (time >= _times[_lastIndex]) {// Time is after last frame.
				frameIndex = _lastIndex;
			} else {
				frameIndex = SpineTimeline.binarySearch(_times, time, 1) - 1;
			}
			
			var len:int;
			var i:int;
			
			var drawOrder:Vector.<int> = state.drawOrder;
			
			var drawOrderToSetupIndex:Vector.<int> = _drawOrders[frameIndex];
			if (drawOrderToSetupIndex == null) {
				len = data.numSlots;
				for (i = 0; i < len; i++) {
					drawOrder[i] = i;
				}
			} else {
				len = drawOrderToSetupIndex.length;
				for (i = 0; i < len; i++) {
					drawOrder[i] = drawOrderToSetupIndex[i];
				}
			}
		}
	}
}