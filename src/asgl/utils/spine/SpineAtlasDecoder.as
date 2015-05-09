package asgl.utils.spine {
	import flash.geom.Point;
	
	import asgl.materials.TextureAtlas;
	import asgl.materials.TextureRegion;
	
	public class SpineAtlasDecoder {
		public var textureAtlas:TextureAtlas;
		public var textureNames:Vector.<String>;
		
		public function SpineAtlasDecoder(data:String=null) {
			if (data == null) {
				clear();
			} else {
				decode(data);
			}
		}
		public function clear():void {
			textureAtlas = null;
			textureNames = null;
		}
		public function decode(data:String):void {
			clear();
			
			textureAtlas = new TextureAtlas();
			textureNames = new Vector.<String>();
			
			var reader:Reader = new Reader(data);
			
			var tuple:Array = new Array();
			tuple.length = 4;
			
			var page:Boolean = false;
			var texName:String = null;
			
			var names:Object = {};
			var size:Object = {};
			
			while (true) {
				var line:String = reader.readLine();
				if (line == null) break;
				
				line = reader.trim(line);
				
				if (line.length == 0) {
					page = false;
					texName = null;
				} else if (!page) {
					page = true;
					
					if (!(line in names)) textureNames[textureNames.length] = line;
					texName = line;
					
					if (reader.readTuple(tuple) == 2) { // size is only optional for an atlas packed with an old TexturePacker.
						size[line] = new Point(int(tuple[0]), int(tuple[1]));
						
						reader.readTuple(tuple);
					}
					//					page.format = Format[tuple[0]];
					
					reader.readTuple(tuple);
					//					page.minFilter = TextureFilter[tuple[0]];
					//					page.magFilter = TextureFilter[tuple[1]];
					
					var direction:String = reader.readValue();
				} else {
					var region:TextureRegion = new TextureRegion();
					region.textureName = texName;
					region.regionName = line;
					
					if (reader.readValue() == 'true') {
						region.rotate = 1;
					}
					
					reader.readTuple(tuple);
					var x:int = tuple[0];
					var y:int = tuple[1];
					
					region.pixelX = x;
					region.pixelY = y;
					
					reader.readTuple(tuple);
					var width:int = tuple[0];
					var height:int = tuple[1];
					
					if (reader.readTuple(tuple) == 4) { // split is optional
						//						region.splits = new Vector.<int>(parseInt(tuple[0]), parseInt(tuple[1]), parseInt(tuple[2]), parseInt(tuple[3]));
						
						if (reader.readTuple(tuple) == 4) { // pad is optional, but only present with splits
							//							region.pads = Vector.<int>(parseInt(tuple[0]), parseInt(tuple[1]), parseInt(tuple[2]), parseInt(tuple[3]));
							
							reader.readTuple(tuple);
						}
					}
					
					region.pixelWidth = width;
					region.pixelHeight = height;
					region.originalPixelWidth = tuple[0];
					region.originalPixelHeight = tuple[1];
					
					reader.readTuple(tuple);
					region.offsetPixelX = tuple[0];
					region.offsetPixelY = tuple[1];
					
					var index:int = int(reader.readValue());
					
					textureAtlas.setRegion(line, region);
				}
			}
			
			
			for (var any:* in size) {
				textureAtlas.calculateRatio(size);
				break;
			}
		}
	}
}

class Reader {
	private var lines:Array;
	private var index:int;
	
	public function Reader (text:String) {
		lines = text.split(/\r\n|\r|\n/);
	}
	
	public function trim (value:String) : String {
		return value.replace(/^\s+|\s+$/gs, "");
	}
	
	public function readLine () : String {
		if (index >= lines.length)
			return null;
		return lines[index++];
	}
	
	public function readValue () : String {
		var line:String = readLine();
		var colon:int = line.indexOf(":");
		if (colon == -1)
			throw new Error("Invalid line: " + line);
		return trim(line.substring(colon + 1));
	}
	
	/** Returns the number of tuple values read (1, 2 or 4). */
	public function readTuple (tuple:Array) : int {
		var line:String = readLine();
		var colon:int = line.indexOf(":");
		if (colon == -1)
			throw new Error("Invalid line: " + line);
		var i:int = 0, lastMatch:int = colon + 1;
		for (; i < 3; i++) {
			var comma:int = line.indexOf(",", lastMatch);
			if (comma == -1) break;
			tuple[i] = trim(line.substr(lastMatch, comma - lastMatch));
			lastMatch = comma + 1;
		}
		tuple[i] = trim(line.substring(lastMatch));
		return i + 1;
	}
}