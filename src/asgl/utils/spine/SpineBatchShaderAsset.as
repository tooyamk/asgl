package asgl.utils.spine {
	import flash.utils.ByteArray;

	public class SpineBatchShaderAsset {
		[Embed(source="SpineBatchShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function SpineBatchShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}