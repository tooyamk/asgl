package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;

	public class ConstantBatchColorShaderAsset {
		[Embed(source="ConstantBatchColorShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function ConstantBatchColorShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}