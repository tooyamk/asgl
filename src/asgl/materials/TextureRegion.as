package asgl.materials {
	public class TextureRegion {
		public var textureName:String;
		public var regionName:String;
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		
		/**
		 * -1 = anticlockwise
		 * 0 = none
		 * 1 = clockwise
		 */
		public var rotate:Number = 0;
		
		public var pixelX:int;
		public var pixelY:int;
		public var pixelWidth:int;
		public var pixelHeight:int;
		public var originalPixelWidth:int;
		public var originalPixelHeight:int;
		public var offsetPixelX:int;
		public var offsetPixelY:int;
		
		public function TextureRegion(x:Number=0, y:Number=0, width:Number=0, height:Number=0) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
	}
}