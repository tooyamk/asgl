package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;

	public class BoundingOrientedBox extends BoundingVolume {
		protected static var _tempMatrix:Matrix4x4 = new Matrix4x4(); 
		
		public var rotation:Matrix4x4;
		public var aabb:BoundingAxisAlignedBox;
		
		public var globalVertices:Vector.<Number>;
		
		public function BoundingOrientedBox(rotation:Matrix4x4, aabb:BoundingAxisAlignedBox) {
			this.rotation = rotation;
			this.aabb = aabb;
			
			_type = BoundingVolumeType.OBB;
			
			globalVertices = new Vector.<Number>(24);
		}
		public function copy(bound:BoundingOrientedBox):void {
			rotation = bound.rotation == null ? null : bound.rotation.clone();
			aabb = bound.aabb == null ? null : bound.aabb.clone();
		}
		public function clone():BoundingOrientedBox {
			return new BoundingOrientedBox(rotation == null ? null : rotation.clone(), aabb == null ? null : aabb.clone());
		}
		public override function hitRay(ray:Ray):Boolean {
			var newRay:Ray;
			if (rotation == null) {
				newRay = ray;
			} else {
				newRay = new Ray();
				ray.transform3x4(rotation, newRay);
			}
			
			return aabb == null ? false : aabb.hitRay(newRay);
		}
		public override function intersectRay(ray:Ray):Number {
			var newRay:Ray;
			if (rotation == null) {
				newRay = ray;
			} else {
				newRay = new Ray();
				ray.transform3x4(rotation, newRay);
			}
			
			return aabb == null ? -1 : aabb.intersectRay(newRay);
		}
		public override function updateGlobal(m:Matrix4x4):void {
			if (rotation != null) m = Matrix4x4.append3x4(rotation, m, _tempMatrix);
			
			if (aabb == null) {
				for (var i:int = 0; i < 24; i++) {
					globalVertices[i] = 0;
				}
			} else {
				var minX:Number = aabb.minX;
				var maxX:Number = aabb.maxX;
				var minY:Number = aabb.minY;
				var maxY:Number = aabb.maxY;
				var minZ:Number = aabb.minZ;
				var maxZ:Number = aabb.maxZ;
				
				m.transform4x4Number3(minX, minY, minZ, _tempFloat3);
				globalVertices[0] = _tempFloat3.x;
				globalVertices[1] = _tempFloat3.y;
				globalVertices[2] = _tempFloat3.z;
				m.transform4x4Number3(maxX, minY, minZ, _tempFloat3);
				globalVertices[3] = _tempFloat3.x;
				globalVertices[4] = _tempFloat3.y;
				globalVertices[5] = _tempFloat3.z;
				m.transform4x4Number3(maxX, minY, maxZ, _tempFloat3);
				globalVertices[6] = _tempFloat3.x;
				globalVertices[7] = _tempFloat3.y;
				globalVertices[8] = _tempFloat3.z;
				m.transform4x4Number3(minX, minY, maxZ, _tempFloat3);
				globalVertices[9] = _tempFloat3.x;
				globalVertices[10] = _tempFloat3.y;
				globalVertices[11] = _tempFloat3.z;
				m.transform4x4Number3(minX, maxY, minZ, _tempFloat3);
				globalVertices[12] = _tempFloat3.x;
				globalVertices[13] = _tempFloat3.y;
				globalVertices[14] = _tempFloat3.z;
				m.transform4x4Number3(maxX, maxY, minZ, _tempFloat3);
				globalVertices[15] = _tempFloat3.x;
				globalVertices[16] = _tempFloat3.y;
				globalVertices[17] = _tempFloat3.z;
				m.transform4x4Number3(maxX, maxY, maxZ, _tempFloat3);
				globalVertices[18] = _tempFloat3.x;
				globalVertices[19] = _tempFloat3.y;
				globalVertices[20] = _tempFloat3.z;
				m.transform4x4Number3(minX, maxY, maxZ, _tempFloat3);
				globalVertices[21] = _tempFloat3.x;
				globalVertices[22] = _tempFloat3.y;
				globalVertices[23] = _tempFloat3.z;
			}
		}
		public function toString():String {
			var euler:Float3;
			if (rotation == null) {
				euler = new Float3();
			} else {
				euler = rotation.getQuaternion().getEulerFromQuaternion();
			}
			
			var minX:Number = 0;
			var maxX:Number = 0;
			var minY:Number = 0;
			var maxY:Number = 0;
			var minZ:Number = 0;
			var maxZ:Number = 0;
			if (aabb != null) {
				minX = aabb.minX;
				maxX = aabb.maxX;
				minY = aabb.minY;
				maxY = aabb.maxY;
				minZ = aabb.minZ;
				maxZ = aabb.maxZ;
			}
			
			return 'boundingOrientedBox (euler:' + euler + ' minX:' + minX + ' maxX:' + maxX + ' minY:' + minY + ' maxY:' + maxY + ' minZ:' + minZ + ' maxZ:' + maxZ + ')';
		}
	}
}