package asgl.utils.spine.timelines {
	public class SpineCurveTimeline extends SpineTimeline {
		static private const LINEAR:Number = 0;
		static private const STEPPED:Number = -1;
		static private const BEZIER_SEGMENTS:int = 10;
		
		private var _curves:Vector.<Number>; // dfx, dfy, ddfx, ddfy, dddfx, dddfy, ...
		
		public function SpineCurveTimeline(numFrames:int) {
			_curves = new Vector.<Number>(numFrames * 6, true)
		}
		public function setStepped (frameIndex:int) : void {
			_curves[int(frameIndex * 6)] = STEPPED;
		}
		/** Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
		 * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
		 * the difference between the keyframe's values. */
		public function setCurve (frameIndex:int, cx1:Number, cy1:Number, cx2:Number, cy2:Number) : void {
			var subdiv_step:Number = 1 / BEZIER_SEGMENTS;
			var subdiv_step2:Number = subdiv_step * subdiv_step;
			var subdiv_step3:Number = subdiv_step2 * subdiv_step;
			var pre1:Number = 3 * subdiv_step;
			var pre2:Number = 3 * subdiv_step2;
			var pre4:Number = 6 * subdiv_step2;
			var pre5:Number = 6 * subdiv_step3;
			var tmp1x:Number = -cx1 * 2 + cx2;
			var tmp1y:Number = -cy1 * 2 + cy2;
			var tmp2x:Number = (cx1 - cx2) * 3 + 1;
			var tmp2y:Number = (cy1 - cy2) * 3 + 1;
			var i:int = frameIndex * 6;
			_curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
			_curves[int(i + 1)] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
			_curves[int(i + 2)] = tmp1x * pre4 + tmp2x * pre5;
			_curves[int(i + 3)] = tmp1y * pre4 + tmp2y * pre5;
			_curves[int(i + 4)] = tmp2x * pre5;
			_curves[int(i + 5)] = tmp2y * pre5;
		}
		public function getCurvePercent (frameIndex:int, percent:Number) : Number {
			var curveIndex:int = frameIndex * 6;
			var dfx:Number = _curves[curveIndex];
			if (dfx == LINEAR)
				return percent;
			if (dfx == STEPPED)
				return 0;
			var dfy:Number = _curves[int(curveIndex + 1)];
			var ddfx:Number = _curves[int(curveIndex + 2)];
			var ddfy:Number = _curves[int(curveIndex + 3)];
			var dddfx:Number = _curves[int(curveIndex + 4)];
			var dddfy:Number = _curves[int(curveIndex + 5)];
			var x:Number = dfx;
			var y:Number = dfy;
			var i:int = BEZIER_SEGMENTS - 2;
			while (true) {
				if (x >= percent) {
					var prevX:Number = x - dfx;
					var prevY:Number = y - dfy;
					return prevY + (y - prevY) * (percent - prevX) / (x - prevX);
				}
				if (i == 0)
					break;
				i--;
				dfx += ddfx;
				dfy += ddfy;
				ddfx += dddfx;
				ddfy += dddfy;
				x += dfx;
				y += dfy;
			}
			return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
		}
	}
}