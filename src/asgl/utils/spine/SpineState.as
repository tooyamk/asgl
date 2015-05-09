package asgl.utils.spine {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.entities.Object3D;
	import asgl.math.Float4;
	import asgl.renderables.BaseRenderable;
	import asgl.utils.spine.attachments.SpineAttachment;
	
	use namespace asgl_protected;

	public class SpineState {
		public var createRenderableHandler:Function;
		
		public var drawOrder:Vector.<int>;
		public var slotStatus:Vector.<SpineSlotState>;
		public var boneStatus:Vector.<SpineBoneState>;
		
		public var renderables:Vector.<BaseRenderable>;
		public var numRenderables:int;
		
		public var ikConstraintStatus:Vector.<SpineIkConstraintState>;
		
		protected var _skin:SpineSkin;
		protected var _renderables:Object;
		protected var _obj:Object3D;
		protected var _scissorRectangle:Rectangle;
		
		protected var _data:SpineData;
		
		private var _boneCache:Vector.<Vector.<SpineBoneState>>;
		private var _numBoneCache:int;
		
		public function SpineState() {
			_renderables = {};
			renderables = new Vector.<BaseRenderable>();
			ikConstraintStatus = new Vector.<SpineIkConstraintState>();
			
			_boneCache = new Vector.<Vector.<SpineBoneState>>();
		}
		public function set object(value:Object3D):void {
			_obj = value;
			
			for each (var renderable:BaseRenderable in _renderables) {
				renderable._object3D = _obj;
			}
		}
		public function set scissorRectangle(value:Rectangle):void {
			_scissorRectangle = value;
			
			for each (var renderable:BaseRenderable in _renderables) {
				renderable._scissorRectangle = _scissorRectangle;
			}
		}
		public function get skin():SpineSkin {
			return _skin;
		}
		public function setSkin(skinName:String):void {
			var skin:SpineSkin;
			if (_data == null) {
				_skin = null;
			} else {
				_skin = _data.getSkin(skinName);
				if (_skin == null) {
					skin = _data.defaultSkin;
				} else {
					skin = _skin;
				}
			}
			
			setToSetupPose();
		}
		public function clear():void {
			drawOrder = null;
			slotStatus = null;
			boneStatus = null;
			_skin = null;
			renderables.length = 0;
			_renderables = {};
			numRenderables = 0;
			ikConstraintStatus.length = 0;
			_data = null;
		}
		public function reset(data:SpineData):void {
			_data = data;
			
			var len:int = data.numSlots;
			drawOrder = new Vector.<int>(len);
			slotStatus = new Vector.<SpineSlotState>(len);
			
			for (var i:int = 0; i < len; i++) {
				drawOrder[i] = i;
				slotStatus[i] = new SpineSlotState();
			}
			
			boneStatus = new Vector.<SpineBoneState>(data.numBones);
			var boneStatusMap:Object = {};
			len = data.numBones;
			for (i = 0; i < len; i++) {
				var boneState:SpineBoneState = new SpineBoneState();
				
				var bone:SpineBone = data.getBoneAt(i);
				boneStatusMap[bone.name] = boneState;
				
				if (bone.parent != null) {
					boneState.parent = boneStatusMap[bone.parent.name];
				}
				
				boneState.name = bone.name;
				boneStatus[i] = boneState;
			}
			
			len = data.numIkConstraints;
			for (i = 0; i < len; i++) {
				var ikConstraint:SpineIkConstraint = data.getIkConstraintAt(i);
				var ikConstraintState:SpineIkConstraintState = new SpineIkConstraintState(ikConstraint);
				ikConstraintStatus[i] = ikConstraintState;
				ikConstraintState.target = boneStatusMap[ikConstraint.targetName];
				
				var boneIndices:Vector.<int> = ikConstraint.boneIndices;
				var num:int = boneIndices.length;
				for (var j:int = 0; j < num; j++) {
					ikConstraintState.boneStatus[j] = boneStatus[ikConstraint.boneIndices[j]];
				}
			}
			
			_updateCache();
		}
		public function getAttachment(slotIndex:int, attachmentName:String):SpineAttachment {
			var attachment:SpineAttachment = null;
			if (attachmentName != null) {
				if (_skin == null) {
					if (_data != null && _data.defaultSkin != null) {
						attachment = _data.defaultSkin.getAttachment(slotIndex, attachmentName);
					}
				} else {
					attachment = _skin.getAttachment(slotIndex, attachmentName);
				}
			}
			
			return attachment;
		}
		public function setToSetupPose():void {
			setBonesToSetupPose();
			setSlotsToSetupPose();
		}
		public function setBonesToSetupPose ():void {
			if (_data != null) {
				var len:int = boneStatus.length;
				for (var i:int = 0; i < len; i++) {
					boneStatus[i].setPose(_data.getBoneAt(i));
				}
			}
		}
		public function setSlotsToSetupPose ():void {
			if (_data != null) {
				var len:int = drawOrder.length;
				for (var i:int = 0; i < len; i++) {
					drawOrder[i] = i;
					slotStatus[i].setPose(_data.getSlotAt(i), this);
				}
			}
		}
		public function resetPose(data:SpineData):void {
			var len:int = boneStatus.length;
			for (var i:int = 0; i < len; i++) {
				var bone:SpineBoneState = boneStatus[i];
				bone.setPose(data.getBoneAt(i));
			}
			
			len = slotStatus.length;
			for (i = 0; i < len; i++) {
				var color:Float4 = slotStatus[i].color;
				var color1:Float4 = data.getSlotAt(i).color;
				color.copyDataFromFloat4(color1);
			}
		}
		public function updateWorldTransform():void {
			var len:int = boneStatus.length;
			for (var i:int = 0; i < len; i++) {
				var bone:SpineBoneState = boneStatus[i];
				bone.rotationIK = bone.rotation;
			}
			
			i = 0;
			var last:int = _numBoneCache - 1;
			while (true) {
				for (var j:int = 0; j < _numBoneCache; j++) {
					var bones:Vector.<SpineBoneState> = _boneCache[j];
					var numBones:int = bones.length;
					for (var k:int = 0; k < numBones; k++) {
						bones[k].updateWorldTransform();
					}
				}
				
				if (i == last) break;
				ikConstraintStatus[i].apply();
				i++;
			}
			
//			for (i = 0; i < len; i++) {
//				boneStatus[i].updateWorldTransform();
//			}
		}
		public function updateRenderables():void {
			numRenderables = 0;
			var len:int = drawOrder.length;
			for (var i:int = 0; i < len; i++) {
				var order:int = drawOrder[i];
				var slotState:SpineSlotState = slotStatus[order];
				var attachment:SpineAttachment = slotState.attachment;
				if (attachment != null) {
					var renderable:BaseRenderable = _renderables[attachment._instanceID];
					if (renderable == null) {
						renderable = attachment.createRenderable();
						if (renderable == null) continue;
						
						renderable._object3D = _obj;
						renderable._scissorRectangle = _scissorRectangle;
						
						if (createRenderableHandler != null) createRenderableHandler(renderable, attachment);
						
						_renderables[attachment._instanceID] = renderable;
					}
					
					var slot:SpineSlot = _data.getSlotAt(order);
					renderable._blendFactors = slot.blendMode;
					attachment.updateRenderable(renderable, slotState, boneStatus, slot.bone.index);
					
					renderables[numRenderables++] = renderable;
				}
			}
		}
		/** Caches information about bones and IK constraints. Must be called if bones or IK constraints are added or removed. */
		private function _updateCache () : void {
			var ikConstraintsCount:int = ikConstraintStatus.length;
			
			var arrayCount:int = ikConstraintsCount + 1;
			if (_numBoneCache > arrayCount) {
				_boneCache.length = arrayCount;
				_numBoneCache = arrayCount;
			}
			
			for (var i:int = 0; i < _numBoneCache; i++) {
				_boneCache[i].length = 0;
			}
			
			for (i = _numBoneCache; i < arrayCount; i++) {
				_boneCache[i] = new Vector.<SpineBoneState>();
			}
			_numBoneCache = arrayCount;
			
			var nonIkBones:Vector.<SpineBoneState> = _boneCache[0];
			
			var numBoneStatus:int = boneStatus.length;
			
			outer:
			for (i = 0; i < numBoneStatus; i++) {
				var bone:SpineBoneState = boneStatus[i];
				
				var current:SpineBoneState = bone;
				do {
					var ii:int = 0;
					for (var j:int = 0; j < ikConstraintsCount; j++) {
						var ikConstraint:SpineIkConstraintState = ikConstraintStatus[j];
						var parent:SpineBoneState = ikConstraint.boneStatus[0];
						var child:SpineBoneState = ikConstraint.boneStatus[int(ikConstraint.boneStatus.length - 1)];
						while (true) {
							if (current == child) {
								_boneCache[ii].push(bone);
								_boneCache[int(ii + 1)].push(bone);
								continue outer;
							}
							if (child == parent) break;
							child = child.parent;
						}
						ii++;
					}
					current = current.parent;
				} while (current != null);
				nonIkBones[nonIkBones.length] = bone;
			}
		}
	}
}