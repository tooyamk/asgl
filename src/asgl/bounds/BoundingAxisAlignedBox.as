package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;

	public class BoundingAxisAlignedBox extends BoundingVolume {
		public var maxX:Number;
		public var maxY:Number;
		public var maxZ:Number;
		public var minX:Number;
		public var minY:Number;
		public var minZ:Number;
		
		public var globalMaxX:Number;
		public var globalMaxY:Number;
		public var globalMaxZ:Number;
		public var globalMinX:Number;
		public var globalMinY:Number;
		public var globalMinZ:Number;
		
		public function BoundingAxisAlignedBox(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) {
			this.minX = minX;
			this.maxX = maxX;
			this.minY = minY;
			this.maxY = maxY;
			this.minZ = minZ;
			this.maxZ = maxZ;
			
			_type = BoundingVolumeType.AABB;
		}
		public function clone():BoundingAxisAlignedBox {
			return new BoundingAxisAlignedBox(minX, maxX, minY, maxY, minZ, maxZ);
		}
		public function copy(bound:BoundingAxisAlignedBox):void {
			minX = bound.minX;
			maxX = bound.maxX;
			minY = bound.minY;
			maxY = bound.maxY;
			minZ = bound.minZ;
			maxZ = bound.maxZ;
		}
		public override function hitRay(ray:Ray):Boolean {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null) return false;
			
			if (rayOrigin.x >= minX && rayOrigin.x <= maxX && rayOrigin.y >= minY && rayOrigin.y <= maxY && rayOrigin.z >= minZ && rayOrigin.z <= maxZ) return true;
			
			var t:Number;
			var ix:Number;
			var iy:Number;
			var iz:Number;
			
			if (rayOrigin.x <= minX && rayDir.x > 0) {
				t = (minX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.x >= maxX && rayDir.x < 0) {
				t = (maxX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.y <= minY && rayDir.y > 0) {
				t = (minY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.y >= maxY && rayDir.y < 0) {
				t = (maxY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.z <= minZ && rayDir.z > 0) {
				t = (minZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) return true;
				}
			}
			
			if (rayOrigin.z >= maxZ && rayDir.z < 0) {
				t = (maxZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) return true;
				}
			}
			
			return false;
		}
		public override function intersectRay(ray:Ray):Number {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null) return -1;
			
			if (rayOrigin.x >= minX && rayOrigin.x <= maxX && rayOrigin.y >= minY && rayOrigin.y <= maxY && rayOrigin.z >= minZ && rayOrigin.z <= maxZ) return 0;
			
			var t:Number;
			var min:Number = Number.POSITIVE_INFINITY;
			var ix:Number;
			var iy:Number;
			var iz:Number;
			
			if (rayOrigin.x <= minX && rayDir.x > 0) {
				t = (minX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.x >= maxX && rayDir.x < 0) {
				t = (maxX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.y <= minY && rayDir.y > 0) {
				t = (minY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.y >= maxY && rayDir.y < 0) {
				t = (maxY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.z <= minZ && rayDir.z > 0) {
				t = (minZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (t < min  && ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) min = t;
				}
			}
			
			if (rayOrigin.z >= maxZ && rayDir.z < 0) {
				t = (maxZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (t < min  && ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) min = t;
				}
			}
			
			return min == Number.POSITIVE_INFINITY ? -1 : min;
		}
		public function updateFromVertices(vertices:Vector.<Number>, m:Matrix4x4=null):void {
			var length:int = vertices.length;
			if (length == 0) {
				minX = 0;
				maxX = 0;
				minY = 0;
				maxY = 0;
				minZ = 0;
				maxZ = 0;
			} else {
				if (m != null) {
					vertices = m.transform3x4Vector3(vertices);
				}
				
				minX = Number.MAX_VALUE;
				maxX = Number.MIN_VALUE;
				minY = minX;
				maxY = maxX;
				minZ = minX;
				maxZ = maxZ;
				for (var i:int = 0; i < length; i += 3) {
					var x:Number = vertices[i];
					var y:Number = vertices[int(i + 1)];
					var z:Number = vertices[int(i + 2)];
					if (minX > x) minX = x;
					if (maxX < x) maxX = x;
					if (minY > y) minY = y;
					if (maxY < y) maxY = y;
					if (minZ > z) minZ = z;
					if (maxZ < z) maxZ = z;
				}
			}
		}
		public override function updateGlobal(m:Matrix4x4):void {
			m.transform4x4Number3(minX, minY, minZ, _tempFloat3);
			globalMinX = _tempFloat3.x;
			globalMinY = _tempFloat3.y;
			globalMinZ = _tempFloat3.z;
			globalMaxX = globalMinX;
			globalMaxY = globalMinY;
			globalMaxZ = globalMinZ;
			m.transform4x4Number3(maxX, minY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, minY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, minY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, maxY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, maxY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, maxY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, maxY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
		}
		public function toString():String {
			return 'boundingAxisAlignedBox (minX:' + minX + ' maxX:' + maxX + ' minY:' + minY + ' maxY:' + maxY + ' minZ:' + minZ + ' maxZ:' + maxZ + ')';
		}
	}
}