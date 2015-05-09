package asgl.utils.spine {
	import asgl.math.Float2;

	public class SpineBoneState {
		public var name:String;
		public var length:Number;
		
		public var parent:SpineBoneState;
		
		public var x:Number;
		public var y:Number;
		public var rotation:Number;
		public var rotationIK:Number;
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
		public var worldFlipX:Boolean;
		public var worldFlipY:Boolean;
		
		public function SpineBoneState() {
		}
		public function setPose(bone:SpineBone) : void {
			length = bone.length;
			x = bone.x;
			y = bone.y;
			rotation = bone.rotation;
			rotationIK = rotation;
			scaleX = bone.scaleX;
			scaleY = bone.scaleY;
			flipX = bone.flipX;
			flipY = bone.flipY;
			inheritRotation = bone.inheritRotation;
			inheritScale = bone.inheritScale;
		}
		public function updateWorldTransform():void {
			if (parent != null) {
				worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
				worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
				if (inheritScale) {
					worldScaleX = parent.worldScaleX * scaleX;
					worldScaleY = parent.worldScaleY * scaleY;
				} else {
					worldScaleX = scaleX;
					worldScaleY = scaleY;
				}
				worldRotation = inheritRotation ? parent.worldRotation + rotationIK : rotationIK;
				worldFlipX = parent.worldFlipX != flipX;
				worldFlipY = parent.worldFlipY != flipY;
			} else {
				worldX = x;
				worldY = y;
				worldScaleX = scaleX;
				worldScaleY = scaleY;
				worldRotation = rotationIK;
				worldFlipX = flipX;
				worldFlipY = flipY;
			}
			
			var cos:Number = Math.cos(worldRotation);
			var sin:Number = Math.sin(worldRotation);
			
			if (worldFlipX) {
				m00 = -cos * worldScaleX;
				m01 = sin * worldScaleY;
			} else {
				m00 = cos * worldScaleX;
				m01 = -sin * worldScaleY;
			}
			if (worldFlipY) {
				m10 = -sin * worldScaleX;
				m11 = -cos * worldScaleY;
			} else {
				m10 = sin * worldScaleX;
				m11 = cos * worldScaleY;
			}
		}
		public function worldToLocal(world:Float2) : void {
			var dx:Number = world.x - worldX;
			var dy:Number = world.y - worldY;
			
			var mm00:Number = m00, mm11:Number = m11;
			if (worldFlipX != worldFlipY) {
				mm00 = -mm00;
				mm11 = -mm11;
			}
			var invDet:Number = 1 / (mm00 * mm11 - m01 * m10);
			world.x = (dx * mm00 * invDet - dy * m01 * invDet);
			world.y = (dy * mm11 * invDet - dx * m10 * invDet);
		}
		public function localToWorld(local:Float2):void {
			var x:Number = local.x;
			var y:Number = local.y;
			
			local.x = x * m00 + y * m01 + worldX;
			local.y = x * m10 + y * m11 + worldY;
		}
	}
}