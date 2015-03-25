package asgl.materials {
	import flash.geom.Point;

	public class TextureAtlas {
		private var _map:Object;
		private var _amount:uint;
		
		public function TextureAtlas() {
			_map = {};
		}
		public function get numRegions():uint {
			return _amount;
		}
		public function setRegion(name:String, region:TextureRegion):void {
			var hasOld:Boolean = name in _map;
			
			if (region == null) {
				if (hasOld) {
					_amount--;
					delete _map[name];
				}
			} else {
				_map[name] = region;
				if (!hasOld) _amount++;
			}
		}
		public function getRegion(name:String):TextureRegion {
			return _map[name];
		}
		public function calculateRatio(texs:Object):void {
			for each (var region:TextureRegion in _map) {
				var size:Point = texs[region.textureName];
				if (size != null) {
					region.x = region.pixelX / size.x;
					region.y = region.pixelY / size.y;
					if (region.rotate == 0) {
						region.width = region.pixelWidth / size.x;
						region.height = region.pixelHeight / size.y;
					} else {
						region.width = region.pixelHeight / size.x;
						region.height = region.pixelWidth / size.y;
					}
				}
			}
		}
		public function removeRegions():void {
			if (_amount > 0) {
				_map = {};
				_amount = 0;
			}
		}
	}
}