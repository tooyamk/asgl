package asgl.geometries {
	public class MeshElementValueMappingType {
		public static const TRIANGLE_INDEX:int = 1;
		
		/**
		 * example:</br>
		 * element.values:[data of idx0, data of idx1, data of idx2, data of idx3, data of idx4, data of idx5...]</br>
		 * meshAsset.indices:[0, 1, 2, 0, 2, 3...]
		 */
		public static const EACH_TRIANGLE:int = 2;
		
		/**
		 * example:</br>
		 * element.values:[1, 2, 3, 4]</br>
		 * element.indices:[0, 1, 2, 0, 2, 3]
		 */
		public static const SELF_TRIANGLE_INDEX:int = 3;
		
		public function MeshElementValueMappingType() {
		}
	}
}