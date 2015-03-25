package asgl.effects.postprocess {
	import asgl.asgl_protected;
	import asgl.materials.Material;
	import asgl.system.AbstractTextureData;
	import asgl.system.BlendFactorsData;
	import asgl.system.ClearData;
	
	use namespace asgl_protected;

	public class PostProcesser {
		public var renderTargets:Vector.<AbstractTextureData>;
		
		asgl_protected var _clearData:ClearData;
		
		public var material:Material;
		public var blendFactors:BlendFactorsData;
		public var buffers:Object;
		//executor
		public function PostProcesser() {
			buffers = {};
			
			_clearData = new ClearData();
		}
		public function get clearData():ClearData {
			return _clearData;
		}
		public function execute(executor:PostProcessExecutor, source:Vector.<AbstractTextureData>, dest:Vector.<AbstractTextureData>):void {
			executor._draw(this, source, dest);
		}
	}
}