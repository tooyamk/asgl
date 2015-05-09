package asgl.utils.spine {
	public class SpineIkConstraint {
		public var name:String;
		public var bendDirection:int;
		public var mix:Number;
		public var boneIndices:Vector.<int>;
		public var targetName:String;
		
		public function SpineIkConstraint(name:String) {
			this.name = name;
			boneIndices = new Vector.<int>();
		}
	}
}