package asgl.utils.spine {
	import asgl.asgl_protected;
	import asgl.animators.AnimationClip;
	import asgl.materials.TextureAtlas;
	import asgl.math.Float4;
	import asgl.system.BlendFactorsData;
	import asgl.utils.spine.attachments.SpineAttachment;
	import asgl.utils.spine.attachments.SpineMeshAttachment;
	import asgl.utils.spine.attachments.SpineRegionAttachment;
	import asgl.utils.spine.attachments.SpineSkinnedMeshAttachment;
	import asgl.utils.spine.timelines.SpineAttachmentTimeline;
	import asgl.utils.spine.timelines.SpineColorTimeline;
	import asgl.utils.spine.timelines.SpineCurveTimeline;
	import asgl.utils.spine.timelines.SpineDrawOrderTimeline;
	import asgl.utils.spine.timelines.SpineFfdTimeline;
	import asgl.utils.spine.timelines.SpineFlipXTimeline;
	import asgl.utils.spine.timelines.SpineFlipYTimeline;
	import asgl.utils.spine.timelines.SpineIkConstraintTimeline;
	import asgl.utils.spine.timelines.SpineRotateTimeline;
	import asgl.utils.spine.timelines.SpineScaleTimeline;
	import asgl.utils.spine.timelines.SpineTranslateTimeline;
	
	use namespace asgl_protected;
	
	public class SpineDecoder {
		private static const BLEND_MODE:Object = {'additive':BlendFactorsData.MUL_ALPHA_ADDITIVE, 
			'multiply':BlendFactorsData.MULTIPLY, 
			'screen':BlendFactorsData.SCREEN};
		private static const D2R:Number = Math.PI / 180
		
		public var data:SpineData;
		public var animationClips:Vector.<AnimationClip>;
		
		private var _rootPath:String;
		
		public function SpineDecoder(data:String=null, textureAtlas:TextureAtlas=null, transformLRH:Boolean=false) {
			if (data == null) {
				clear();
			} else {
				decode(data, textureAtlas, transformLRH);
			}
		}
		public function clear():void {
			data = null;
			animationClips = null;
			_rootPath = null;
		}
		/**
		 * @param rendererHandler handler(attachment:SpineAttachment, slotEntry:Object), set renderer and material.
		 */
		public function decode(src:String, textureAtlas:TextureAtlas, transformLRH:Boolean=false):void {
			clear();
			
			var json:Object = JSON.parse(src);
			
			data = new SpineData();
			animationClips = new Vector.<AnimationClip>();
			
			var boneMap:Object = {};
			var boneIndies:Object = {};
			
			_decodeSkeleton(json);
			_decodeBones(json, boneMap, boneIndies);
			_decodeIk(json);
			_decodeSlots(json, boneMap);
			_decodeSkins(json, textureAtlas);
			_decodeAnims(json, boneIndies);
		}
		private function _decodeSkeleton(json:Object):void {
			var skeleton:Object = json.skeleton;
			if (skeleton == null) {
				_rootPath = '';
			} else {
				_rootPath = skeleton.images || '';
			}
			
			if (_rootPath.indexOf('./') != -1) _rootPath = _rootPath.substr(2);
		}
		private function _decodeBones(json:Object, boneMap:Object, boneIndies:Object):void {
			var bones:Array = json.bones;
			
			var len:int = bones.length;
			
			var boneData:Object;
			
			for (var i:int = 0; i < len; i++) {
				boneData = bones[i];
				
				var bone:SpineBone = new SpineBone();
				bone.name = boneData.name;
				bone.length = boneData.length || 0;
				bone.x = boneData.x || 0;
				bone.y = boneData.y || 0;
				bone.rotation = (boneData.rotation || 0) * D2R;
				bone.scaleX = boneData.scaleX || 1;
				bone.scaleY = boneData.scaleY || 1;
				bone.flipX = boneData.flipX || false;
				bone.flipY = boneData.flipY || false;
				bone.inheritScale = boneData.inheritScale == null ? true : boneData.inheritScale == 'true';
				bone.inheritRotation = boneData.inheritRotation == null ? true : boneData.inheritRotation == 'true';
				
				data.addBone(bone);
				
				boneIndies[bone.name] = i;
				boneMap[bone.name] = bone;
			}
			
			for (i = 0; i < len; i++) {
				boneData = bones[i];
				(boneMap[boneData.name] as SpineBone).parent = boneMap[boneData.parent];
			}
		}
		private function _decodeIk(json:Object):void {
			var iks:Array = json.ik;
			if (iks != null) {
				var len:int = iks.length;
				for (var i:int = 0; i < len; i++) {
					var ikMap:Object = iks[i];
					var ik:SpineIkConstraint = new SpineIkConstraint(ikMap.name);
					
					var bones:Array = ikMap.bones;
					if (bones != null) {
						var numBones:int = bones.length;
						for (var j:int = 0; j < numBones; j++) {
							ik.boneIndices[j] = data.getBoneIndex(bones[j]);
						}
					}
					
					ik.targetName = ikMap.target;
					ik.bendDirection = (ikMap.bendPositive == null || ikMap.bendPositive) ? 1 : -1;
					ik.mix = ikMap.mix == null ? 1 : ikMap.mix;
					
					data.addIkConstraint(ik);
				}
			}
		}
		private function _decodeSlots(json:Object, boneMap:Object):void {
			var slots:Array = json.slots;
			if (slots != null) {
				var len:int = slots.length;
				
				for (var i:int = 0; i < len; i++) {
					var slotMap:Object = slots[i];
					var slotName:String = slotMap.name;
					var attachmentName:String = slotMap.attachment;
					var bone:SpineBone = boneMap[slotMap.bone];
					
					var color:Float4;
					var colorValues:String = slotMap.color;
					if (colorValues == null) {
						color = new Float4(1, 1, 1, 1);
					} else {
						color = new Float4(_toColor(colorValues, 0), _toColor(colorValues, 1), _toColor(colorValues, 2), _toColor(colorValues, 3));
					}
					
					var slot:SpineSlot = new SpineSlot(slotName, bone);
					slot.attachmentName = slotMap.attachment;
					slot.color = color;
					slot.blendMode = BLEND_MODE[slotMap.blend] || BlendFactorsData.ALPHA_BLEND;
					
					data.addSlot(slot);
				}
			}
		}
		private function _decodeSkins(json:Object, textureAtlas:TextureAtlas):void {
			var skins:Object = json.skins;
			
			for (var skinName:String in skins) {
				var skinMap:Object = skins[skinName];
				
				var skin:SpineSkin = new SpineSkin(skinName);
				
				for (var slotName:String in skinMap) {
					var slotEntry:Object = skinMap[slotName];
					for (var attachmentName:String in slotEntry) {
						var attachment:SpineAttachment = _readAttachment(attachmentName, slotEntry[attachmentName], textureAtlas);
						if (attachment != null) {
							skin.addAttachment(data.getSlotIndex(slotName), attachmentName, attachment);
						}
					}
				}
				
				data.addSkin(skin);
				
				if (skin.name == 'default') data.defaultSkin = skin;
			}
		}
		private function _readAttachment(name:String, map:Object, textureAtlas:TextureAtlas):SpineAttachment {
			name = map.name || name;
			var type:String = map.type || 'region';
			var path:String = _rootPath + (map.path || name);
			
			//			var texRegion:Rectangle = textureAtlas.getRegion(path);
			
			//			trace(type, name, path);
			
			//			if (name != 'shield') {
			//				return null;
			//			}
			
			var color:Float4;
			var colorValues:String = map.color;
			if (colorValues == null) {
				color = new Float4(1, 1, 1, 1);
			} else {
				color = new Float4(_toColor(colorValues, 0), _toColor(colorValues, 1), _toColor(colorValues, 2), _toColor(colorValues, 3));
			}
			
			if (type == 'region') {
				var ra:SpineRegionAttachment = new SpineRegionAttachment(name, color);
				ra.textureRegion = textureAtlas.getRegion(path);
				ra.setLocalMesh(map.x || 0, map.y || 0, map.width || 0, map.height || 0, map.scaleX || 1, map.scaleY || 1, (map.rotation || 0) * D2R);
				//				return null;
				return ra;
			} else if (type == 'mesh') {
				var ma:SpineMeshAttachment = new SpineMeshAttachment(name, color);
				ma.textureRegion = textureAtlas.getRegion(path);
				ma.vertices = Vector.<Number>(map.vertices);
				ma.triangleIndices = Vector.<uint>(map.triangles);
				ma.texCoords = Vector.<Number>(map.uvs);
				//				return null;
				return ma;
			} else if (type == 'skinnedmesh') {
				var sma:SpineSkinnedMeshAttachment = new SpineSkinnedMeshAttachment(name, color);
				sma.textureRegion = textureAtlas.getRegion(path);
				sma.triangleIndices = Vector.<uint>(map.triangles);
				sma.texCoords = Vector.<Number>(map.uvs);
				
				var vertices:Vector.<Number> = Vector.<Number>(map.vertices);
				var weights:Vector.<Number> = new Vector.<Number>();
				var bones:Vector.<int> = new Vector.<int>();
				var len:int = vertices.length;
				for (var i:int = 0; i < len;) {
					var boneCount:int = vertices[i++];
					bones[bones.length] = boneCount;
					for (var j:int = i + boneCount * 4; i < j;) {
						bones[bones.length] = vertices[i++];
						weights[weights.length] = vertices[i++];
						weights[weights.length] = vertices[i++];
						weights[weights.length] = vertices[i++];
					}
				}
				
				sma.bones = bones;
				sma.weights = weights;
				//				return null;
				return sma;
			}
			
			return null;
		}
		private function _decodeAnims(json:Object, boneIndies:Object):void {
			var anims:Object = json.animations;
			
			var d2r:Number = Math.PI / 180;
			
			var numAnims:int;
			
			for (var animName:String in anims) {
				var maxTime:Number = 0;
				
				var clipData:SpineAnimationData = new SpineAnimationData();
				
				var clip:AnimationClip = new AnimationClip();
				clip.name = animName;
				clip._data = clipData;
				animationClips[numAnims++] = clip;
				
				var timelineName:String;
				var values:Array;
				var valueMap:Object;
				var len:int;
				var i:int;
				var j:int;
				var slotIndex:int;
				
				var numTimelines:int = 0;
				
				var animData:Object = anims[animName];
				
				var slotMap:Object;
				
				var slots:Object = animData.slots;
				for (var slotName:String in slots) {
					slotMap = slots[slotName];
					slotIndex = data.getSlotIndex(slotName);
					
					for (timelineName in slotMap) {
						values = slotMap[timelineName];
						len = values.length;
						
						if (timelineName == 'color') {
							var colorTimeline:SpineColorTimeline = new SpineColorTimeline(len, slotIndex);
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								var color:String = valueMap.color;
								colorTimeline.setFrame(i, valueMap.time, _toColor(color, 0), _toColor(color, 1), _toColor(color, 2), _toColor(color, 3));
								_readCurve(colorTimeline, i, valueMap);
							}
							
							if (maxTime < colorTimeline.maxTime) maxTime = colorTimeline.maxTime;
							clipData.timelines[numTimelines++] = colorTimeline;
						} else if (timelineName == 'attachment') {
							var attachmentTimeline:SpineAttachmentTimeline = new SpineAttachmentTimeline(len, slotIndex);
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								attachmentTimeline.setFrame(i, valueMap.time, valueMap.name);
							}
							
							if (maxTime < attachmentTimeline.maxTime) maxTime = attachmentTimeline.maxTime;
							clipData.timelines[numTimelines++] = attachmentTimeline;
						}
					}
				}
				
				var bones:Object = animData.bones;
				for (var boneName:String in bones) {
					var boneMap:Object = bones[boneName];
					var boneIndex:int = boneIndies[boneName];
					
					for (timelineName in boneMap) {
						values = boneMap[timelineName];
						len = values.length;
						
						if (timelineName == 'rotate') {
							//							continue;
							var rotateTimeline:SpineRotateTimeline = new SpineRotateTimeline(len, boneIndex);
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								rotateTimeline.setFrame(i, valueMap.time, valueMap.angle * d2r);
								_readCurve(rotateTimeline, i, valueMap);
							}
							
							if (maxTime < rotateTimeline.maxTime) maxTime = rotateTimeline.maxTime;
							clipData.timelines[numTimelines++] = rotateTimeline;
						} else if (timelineName == 'translate') {
							//							continue;
							var translateTimeline:SpineTranslateTimeline = new SpineTranslateTimeline(len, boneIndex);
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								translateTimeline.setFrame(i, valueMap.time, valueMap.x || 0, valueMap.y || 0);
								_readCurve(translateTimeline, i, valueMap);
							}
							
							if (maxTime < translateTimeline.maxTime) maxTime = translateTimeline.maxTime;
							clipData.timelines[numTimelines++] = translateTimeline;
						} else if (timelineName == 'scale') {
							//							continue;
							var scaleTimeline:SpineScaleTimeline = new SpineScaleTimeline(len, boneIndex);
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								scaleTimeline.setFrame(i, valueMap.time, valueMap.x || 0, valueMap.y || 0);
								_readCurve(scaleTimeline, i, valueMap);
							}
							
							if (maxTime < scaleTimeline.maxTime) maxTime = scaleTimeline.maxTime;
							clipData.timelines[numTimelines++] = scaleTimeline;
						} else if (timelineName == 'flipX' || timelineName == 'flipY') {
							var field:String;
							var flipTimeline:SpineFlipXTimeline;
							if (timelineName == 'flipX') {
								flipTimeline = new SpineFlipXTimeline(len, boneIndex);
								field = 'x';
							} else {
								flipTimeline = new SpineFlipYTimeline(len, boneIndex);
								field = 'y';
							}
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								flipTimeline.setFrame(i, valueMap.time, valueMap[field] || false);
							}
							
							if (maxTime < flipTimeline.maxTime) maxTime = flipTimeline.maxTime;
							clipData.timelines[numTimelines++] = flipTimeline;
						}
					}
				}
				
				var ikMap:Object = animData.ik;
				for (var ikConstraintName:String in ikMap) {
					values = ikMap[ikConstraintName];
					len = values.length;
					
					var ikTimeline:SpineIkConstraintTimeline = new SpineIkConstraintTimeline(len, data.getIkConstraintIndex(ikConstraintName));
					
					for (i = 0; i < len; i++) {
						valueMap = values[i];
						var mix:Number = valueMap.mix == null ? 1 : valueMap.mix;
						var bendDirection:int = (valueMap.bendPositive == null || valueMap.bendPositive) ? 1 : -1;
						ikTimeline.setFrame(i, valueMap.time, mix, bendDirection);
						_readCurve(ikTimeline, i, valueMap);
					}
					
					if (maxTime < ikTimeline.maxTime) maxTime = ikTimeline.maxTime;
					clipData.timelines[numTimelines++] = ikTimeline;
				}
				
				var ffd:Object = animData.ffd;
				for (var skinName:String in ffd) {
					var skin:SpineSkin = data.getSkin(skinName);
					slotMap = ffd[skinName];
					for (slotName in slotMap) {
						slotIndex = data.getSlotIndex(slotName);
						var meshMap:Object = slotMap[slotName];
						for (var meshName:String in meshMap) {
							values = meshMap[meshName];
							len = values.length;
							
							var attachment:SpineAttachment = skin.getAttachment(slotIndex, meshName);
							if (attachment == null) continue;
							var ffdTimeline:SpineFfdTimeline = new SpineFfdTimeline(len, slotIndex, attachment);
							
							var vertexCount:int;
							if (attachment is SpineMeshAttachment) {
								vertexCount = (attachment as SpineMeshAttachment).vertices.length;
							} else {
								vertexCount = (attachment as SpineSkinnedMeshAttachment).weights.length / 3 * 2;
							}
							
							for (i = 0; i < len; i++) {
								valueMap = values[i];
								
								var vertices:Vector.<Number>;
								var verticesValue:Array = valueMap.vertices;
								if (verticesValue == null) {
									if (attachment is SpineMeshAttachment) {
										vertices = (attachment as SpineMeshAttachment).vertices;
									} else {
										vertices = new Vector.<Number>(vertexCount);
									}
								} else {
									vertices = new Vector.<Number>(vertexCount);
									var start:int = valueMap.offset || 0;
									var n:int = verticesValue.length;
									for (j = 0; j < n; j++) {
										vertices[int(j + start)] = verticesValue[j];
									}
									if (attachment is SpineMeshAttachment) {
										var meshVertices:Vector.<Number> = (attachment as SpineMeshAttachment).vertices;
										for (j = 0; j < vertexCount; j++) {
											vertices[j] += meshVertices[j];
										}
									}
								}
								
								ffdTimeline.setFrame(i, valueMap.time, vertices);
								_readCurve(ffdTimeline, i, valueMap);
							}
							
							if (maxTime < ffdTimeline.maxTime) maxTime = ffdTimeline.maxTime;
							clipData.timelines[numTimelines++] = ffdTimeline;
						}
					}
				}
				
				var drawOrderValues:Array = animData.drawOrder;
				if (drawOrderValues == null) animData.draworder;
				if (drawOrderValues != null) {
					len = drawOrderValues.length;
					
					var drawOrderTimeline:SpineDrawOrderTimeline = new SpineDrawOrderTimeline(len);
					
					var numSlots:int = data.numSlots;
					
					for (i = 0; i < len; i++) {
						var drawOrder:Vector.<int> = null;
						
						var drawOrderMap:Object = drawOrderValues[i];
						var offsets:Array = drawOrderMap.offsets;
						
						if (offsets != null) {
							var numOffsets:int = offsets.length;
							drawOrder = new Vector.<int>(numSlots);
							
							for (j = 0; j < numSlots; j++) {
								drawOrder[j] = -1;
							}
							
							var unchanged:Vector.<int> = new Vector.<int>(numSlots - numOffsets);
							var originalIndex:int = 0;
							var unchangedIndex:int = 0;
							
							for (j = 0; j < numOffsets; j++) {
								var offsetMap:Object = offsets[j];
								slotIndex = data.getSlotIndex(offsetMap.slot);
								
								while (originalIndex != slotIndex) {
									unchanged[unchangedIndex++] = originalIndex++;
								}
								
								drawOrder[originalIndex + offsetMap.offset] = originalIndex++;
							}
							
							while (originalIndex < numSlots) {
								unchanged[unchangedIndex++] = originalIndex++;
							}
							
							for (j = numSlots - 1; j >= 0; j--) {
								if (drawOrder[j] == -1) drawOrder[j] = unchanged[--unchangedIndex];
							}
						}
						
						drawOrderTimeline.setFrame(i, drawOrderMap.time, drawOrder);
					}
					
					if (maxTime < drawOrderTimeline.maxTime) maxTime = drawOrderTimeline.maxTime;
					clipData.timelines[numTimelines++] = drawOrderTimeline;
				}
				
				maxTime *= 30;
				if (maxTime != int(maxTime)) maxTime = int(maxTime) + 1;
				clip._totalFrames = maxTime > 0 ? maxTime + 1 : maxTime;
			}
		}
		private function _readCurve (timeline:SpineCurveTimeline, frameIndex:int, valueMap:Object) : void {
			var curve:Object = valueMap.curve;
			if (curve == null) return;
			
			if (curve == 'stepped')
				timeline.setStepped(frameIndex);
			else if (curve is Array) {
				timeline.setCurve(frameIndex, curve[0], curve[1], curve[2], curve[3]);
			}
		}
		private function _toColor (hexString:String, colorIndex:int) : Number {
			if (hexString.length != 8)
				throw new ArgumentError("Color hexidecimal length must be 8, recieved: " + hexString);
			return parseInt(hexString.substring(colorIndex * 2, colorIndex * 2 + 2), 16) / 255;
		}
	}
}