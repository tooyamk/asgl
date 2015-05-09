package asgl.utils.spine {
	import asgl.asgl_protected;
	import asgl.animators.BaseAnimator;
	import asgl.utils.spine.timelines.SpineTimeline;
	
	use namespace asgl_protected;
	
	public class SpineAnimator extends BaseAnimator {
		private static const FRAME_TO_TIME:Number = 1 / 30;
		
		private var _data:SpineRenderable;
		private var _lastTime:Number;
		
		public function SpineAnimator() {
			_lastTime = 0;
		}
		public function set data(value:SpineRenderable):void {
			_data = value;
		}
		public override function changeClip(label:String, gotoFrame:Number=0, blendFrames:Number=0, update:Boolean=true):Boolean {
			var b:Boolean = super.changeClip(label, gotoFrame, blendFrames, update);
			
			if (_data != null) _data._state.setToSetupPose();
			
			_lastTime = 0;
			
			return b;
		}
		protected override function _update(lerp:Boolean):void {
			super._update(lerp);
			
			if (_data != null) {
				var time:Number = _globalCurrentFrame * FRAME_TO_TIME;
				var state:SpineState = _data._state;
				
				if (_lastTime > time) {
					state.resetPose(_data._data);
				}
				
				var animData:SpineAnimationData = _currentClip.data;
				
				var timelines:Vector.<SpineTimeline> = animData.timelines;
				var len:int = timelines.length;
				for (var i:int = 0; i < len; i++) {
					var timeline:SpineTimeline = timelines[i];
					timeline.update(state, _data._data, time, _lastTime);
				}
				
				state.updateWorldTransform();
				state.updateRenderables();
				
				_lastTime = time;
			}
		}
	}
}