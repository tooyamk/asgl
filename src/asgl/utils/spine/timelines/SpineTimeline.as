package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineData;
	import asgl.utils.spine.SpineState;

	public class SpineTimeline {
		public function SpineTimeline() {
		}
		public function update(state:SpineState, data:SpineData, time:Number, lastTime:Number):void {
		}
		public function get maxTime():Number {
			return 0;
		}
		/** @param target After the first and before the last entry. */
		public static function binarySearch (values:Vector.<Number>, target:Number, step:int):int {
			var low:int = 0;
			var high:int = values.length / step - 2;
			if (high == 0)
				return step;
			var current:int = high >>> 1;
			while (true) {
				if (values[int((current + 1) * step)] <= target)
					low = current + 1;
				else
					high = current;
				if (low == high)
					return (low + 1) * step;
				current = (low + high) >>> 1;
			}
			return 0; // Can't happen.
		}
		/** @param target After the first and before the last entry. */
		public static function binarySearch1 (values:Vector.<Number>, target:Number):int {
			var low:int = 0;
			var high:int = values.length - 2;
			if (high == 0)
				return 1;
			var current:int = high >>> 1;
			while (true) {
				if (values[int(current + 1)] <= target)
					low = current + 1;
				else
					high = current;
				if (low == high)
					return low + 1;
				current = (low + high) >>> 1;
			}
			return 0; // Can't happen.
		}
	}
}