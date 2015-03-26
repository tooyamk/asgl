package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;

	public class VertexBatchColorShaderAsset {
		[Embed(source="VertexBatchColorShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function VertexBatchColorShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}