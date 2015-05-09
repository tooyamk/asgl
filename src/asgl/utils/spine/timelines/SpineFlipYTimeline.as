package asgl.utils.spine.timelines {
	import asgl.utils.spine.SpineBoneState;

	public class SpineFlipYTimeline extends SpineFlipXTimeline {
		public function SpineFlipYTimeline(numFrames:int, boneIndex:int) {
			super(numFrames, boneIndex);
		}
		protected override function _setFlip(bone:SpineBoneState, flip:Boolean) : void {
			bone.flipY = flip;
		}
	}
}