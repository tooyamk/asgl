package asgl.utils {
	import asgl.animators.SpriteSheetAsset;
	import asgl.animators.SpriteSheetAtlas;
	import asgl.materials.TextureRegion;

	public class StarlingHelper {
		public function StarlingHelper() {
		}
		public static function createSpriteSheetAtlasFromTextureAtlasXML(xml:XML, texWidth:int, texHeight:int):SpriteSheetAtlas {
			var atlas:SpriteSheetAtlas = new SpriteSheetAtlas();
			
			var list:XMLList = xml.SubTexture;
			var len:int = list.length();
			var count:int;
			for (var i:int = 0; i < len; i++) {
				xml = list[i];
				var name:String = xml.@name;
				
				var x:Number = xml.@x;
				var y:Number = xml.@y;
				var w:Number = xml.@width;
				var h:Number = xml.@height;
				var fx:Number = xml.@frameX;
				var fy:Number = xml.@frameY;
				var fw:Number = xml.@frameWidth;
				var fh:Number = xml.@frameHeight;
				
				var deltaRight:Number  = fw + fx - w;
				var deltaBottom:Number = fh + fy - h;
				
				var ssa:SpriteSheetAsset = new SpriteSheetAsset();
				var region:TextureRegion = new TextureRegion(x / texWidth, y / texHeight, w / texWidth, h / texHeight);
				ssa.textureRegion = region;
				
				region.pixelX = x;
				region.pixelY = y;
				region.offsetPixelX = fx; 
				region.offsetPixelY = fy;
				region.pixelWidth = w;
				region.pixelHeight = h;
				
				var vertices:Vector.<Number> = new Vector.<Number>(12);
				vertices[0] = -fx;
				vertices[1] = fy;
				
				vertices[3] = fw - deltaRight;
				vertices[4] = fy;
				
				vertices[6] = fw - deltaRight;
				vertices[7] = deltaBottom - fh;
				
				vertices[9] = -fx;
				vertices[10] = deltaBottom - fh;
				
				if (fw == 0 && fh == 0) {
					fw = w;
					fh = h;
				}
				region.originalPixelWidth = fw;
				region.originalPixelHeight = fh;
				
				ssa.vertices = vertices;
				
				atlas.setAsset(name, ssa);
			}
			
			return atlas;
		}
	}
}