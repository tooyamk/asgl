package asgl.utils.spine {
	import asgl.utils.spine.timelines.SpineTimeline;

	public class SpineAnimationData {
		public var timelines:Vector.<SpineTimeline>;
		
		public function SpineAnimationData() {
			timelines = new Vector.<SpineTimeline>();
		}
	}
}