package asgl.utils.spine {
	public class SpineBone {
		public var name:String;
		public var parent:SpineBone;
		public var index:int;
		public var length:Number;
		
		public var x:Number;
		public var y:Number;
		public var rotation:Number;
		public var scaleX:Number
		public var scaleY:Number;
		public var flipX:Boolean;
		public var flipY:Boolean;
		public var inheritScale:Boolean;
		public var inheritRotation:Boolean;
		
		public var m00:Number;
		public var m01:Number;
		public var m10:Number;
		public var m11:Number;
		public var worldX:Number;
		public var worldY:Number;
		public var worldRotation:Number;
		public var worldScaleX:Number;
		public var worldScaleY:Number;
		
		public function SpineBone() {
			inheritScale = true;
			inheritRotation = true;
		}
	}
}