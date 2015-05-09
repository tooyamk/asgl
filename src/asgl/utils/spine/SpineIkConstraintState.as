package asgl.utils.spine {
	import asgl.math.Float2;

	public class SpineIkConstraintState {
		private static const PI2:Number = Math.PI * 2;
		private static var tempFloat2:Float2 = new Float2();
		
		public var bendDirection:int;
		public var mix:Number;
		public var boneStatus:Vector.<SpineBoneState>;
		public var target:SpineBoneState;
		
		public function SpineIkConstraintState(ikConstraint:SpineIkConstraint) {
			bendDirection = ikConstraint.bendDirection;
			mix = ikConstraint.mix;
			boneStatus = new Vector.<SpineBoneState>();
		}
		public function apply () : void {
			var len:int = boneStatus.length;
			
			if (len == 1) {
				_apply1(boneStatus[0], target.worldX, target.worldY, mix);
			} else if (len == 2) {
				_apply2(boneStatus[0], boneStatus[1], target.worldX, target.worldY, bendDirection, mix);
			}
		}
		/** Adjusts the bone rotation so the tip is as close to the target position as possible. The target is specified in the world
		 * coordinate system. */
		private static function _apply1 (boneState:SpineBoneState, targetX:Number, targetY:Number, alpha:Number) : void {
			var parentRotation:Number = (!boneState.inheritRotation || boneState.parent == null) ? 0 : boneState.parent.worldRotation;
			var rotation:Number = boneState.rotation;
			var rotationIK:Number = Math.atan2(targetY - boneState.worldY, targetX - boneState.worldX) - parentRotation;
			boneState.rotationIK = rotation + (rotationIK - rotation) * alpha;
		}
		/** Adjusts the parent and child bone rotations so the tip of the child is as close to the target position as possible. The
		 * target is specified in the world coordinate system.
		 * @param child Any descendant bone of the parent. */
		private static function _apply2 (parent:SpineBoneState, child:SpineBoneState, targetX:Number, targetY:Number, bendDirection:int, alpha:Number) : void {
			var childRotation:Number = child.rotation, parentRotation:Number = parent.rotation;
			if (alpha == 0) {
				child.rotationIK = childRotation;
				parent.rotationIK = parentRotation;
				return;
			}
			var positionX:Number, positionY:Number;
			var parentParent:SpineBoneState = parent.parent;
			if (parentParent) {
				tempFloat2.x = targetX;
				tempFloat2.y = targetY;
				parentParent.worldToLocal(tempFloat2);
				targetX = (tempFloat2.x - parent.x) * parentParent.worldScaleX;
				targetY = (tempFloat2.y - parent.y) * parentParent.worldScaleY;
			} else {
				targetX -= parent.x;
				targetY -= parent.y;
			}
			if (child.parent == parent) {
				positionX = child.x;
				positionY = child.y;
			} else {
				tempFloat2.x = child.x;
				tempFloat2.y = child.y;
				child.parent.localToWorld(tempFloat2);
				parent.worldToLocal(tempFloat2);
				positionX = tempFloat2.x;
				positionY = tempFloat2.y;
			}
			var childX:Number = positionX * parent.worldScaleX, childY:Number = positionY * parent.worldScaleY;
			var offset:Number = Math.atan2(childY, childX);
			var len1:Number = Math.sqrt(childX * childX + childY * childY), len2:Number = child.length * child.worldScaleX;
			// Based on code by Ryan Juckett with permission: Copyright (c) 2008-2009 Ryan Juckett, http://www.ryanjuckett.com/
			var cosDenom:Number = 2 * len1 * len2;
			if (cosDenom < 0.0001) {
				child.rotationIK = childRotation + (Math.atan2(targetY, targetX) - parentRotation - childRotation) * alpha;
				return;
			}
			var cos:Number = (targetX * targetX + targetY * targetY - len1 * len1 - len2 * len2) / cosDenom;
			if (cos < -1) {
				cos = -1;
			} else if (cos > 1) {
				cos = 1;
			}
			var childAngle:Number = Math.acos(cos) * bendDirection;
			var adjacent:Number = len1 + len2 * cos, opposite:Number = len2 * Math.sin(childAngle);
			var parentAngle:Number = Math.atan2(targetY * adjacent - targetX * opposite, targetX * adjacent + targetY * opposite);
			var rotation:Number = (parentAngle - offset) - parentRotation;
			if (rotation > Math.PI) {
				rotation -= PI2;
			} else if (rotation < -Math.PI) {
				rotation += PI2;
			}
			parent.rotationIK = parentRotation + rotation * alpha;
			rotation = (childAngle + offset) - childRotation;
			if (rotation > Math.PI) {
				rotation -= PI2;
			} else if (rotation < -Math.PI) {
				rotation += PI2;
			}
			child.rotationIK = childRotation + (rotation + parent.worldRotation - child.parent.worldRotation) * alpha;
		}
	}
}