package asgl.utils.spine {
	public class SpineData {
		public var defaultSkin:SpineSkin;		
		
		private var _bones:Vector.<SpineBone>;
		private var _bonesIndexMap:Object;
		private var _numBones:int;
		
		private var _slots:Vector.<SpineSlot>;
		private var _slotsIndexMap:Object;
		private var _numSlots:int;
		
		private var _skins:Object;
		private var _numSkins:int;
		
		private var _ikConstraints:Vector.<SpineIkConstraint>;
		private var _ikConstraintsIndexMap:Object;
		private var _numIkConstraints:int;
		
		public function SpineData() {
			_bones = new Vector.<SpineBone>();
			_bonesIndexMap = {};
			
			_slots = new Vector.<SpineSlot>();
			_slotsIndexMap = {};
			
			_skins = {};
			
			_ikConstraints = new Vector.<SpineIkConstraint>();
			_ikConstraintsIndexMap = {};
		}
		public function get numSkins():int {
			return _numSkins;
		}
		public function get numSlots():int {
			return _numSlots;
		}
		public function get numBones():int {
			return _numBones;
		}
		public function get numIkConstraints():int {
			return _numIkConstraints;
		}
		public function get bones():Vector.<SpineBone> {
			return _bones;
		}
		public function addBone(bone:SpineBone):void {
			bone.index = _numBones;
			_bones[_numBones++] = bone;
			_bonesIndexMap[bone.name] = bone.index;
		}
		public function getBoneAt(index:int):SpineBone {
			return _bones[index];
		}
		public function getBoneIndex(name:String):int {
			var index:* = _bonesIndexMap[name];
			return index == null ? -1 : index;
		}
		public function addSlot(slot:SpineSlot):void {
			_slotsIndexMap[slot.name] = _numSlots;
			slot.index = _numSlots;
			_slots[_numSlots++] = slot;
		}
		public function getSlotAt(index:int):SpineSlot {
			return _slots[index];
		}
		public function getSlotIndex(name:String):int {
			var index:* = _slotsIndexMap[name];
			return index == null ? -1 : index;
		}
		public function addIkConstraint(ik:SpineIkConstraint):void {
			_ikConstraints[_numIkConstraints] = ik;
			_ikConstraintsIndexMap[ik.name] = _numIkConstraints++;
		}
		public function getIkConstraintAt(index:int):SpineIkConstraint {
			return _ikConstraints[index];
		}
		public function getIkConstraintIndex(name:String):int {
			var index:* = _ikConstraintsIndexMap[name];
			return index == null ? -1 : index;
		}
		public function addSkin(skin:SpineSkin):void {
			var old:SpineSkin = _skins[skin.name];
			if (old == null) _numSkins++;
			_skins[skin.name] = skin;
		}
		public function getSkin(name:String):SpineSkin {
			return _skins[name];
		}
	}
}