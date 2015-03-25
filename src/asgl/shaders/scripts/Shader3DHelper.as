package asgl.shaders.scripts {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.effects.BillboardType;
	import asgl.entities.Camera3D;
	import asgl.entities.Coordinates3D;
	import asgl.entities.Coordinates3DHelper;
	import asgl.materials.TextureRegion;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class Shader3DHelper {
		private static var _tempFloat4_1:Float4 = new Float4();
		private static var _tempFloat4_2:Float4 = new Float4();
		private static var _tempFloat4_3:Float4 = new Float4();
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		
		private static var _billboardMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _localToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _localToViewMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _localToWorldMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _projToViewMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _projToWorldMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _diffTexRegionMatConstants:ShaderConstants = _createShaderConstants(2);
		private static var _viewWorldPosConstants:ShaderConstants = _createShaderConstants(1);
		private static var _viewToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _worldToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		
		public function Shader3DHelper() {
		}
		private static function _createShaderConstants(length:uint):ShaderConstants {
			var sc:ShaderConstants = new ShaderConstants(length);
			sc.values = new Vector.<Number>(length * 4);
			
			return sc;
		}
		public static function setGlobalBillboardMatrix(obj:Coordinates3D, camera:Camera3D, billboardType:int):void {
			if (billboardType == BillboardType.PARALLEL_VIEW_PLANE) {
				var rot:Float4 = Coordinates3DHelper.getBillboardWorldRotationOfParallelToViewPlane(obj, camera, false, _tempFloat4_1);
				var rot2:Float4 = obj.getLocalRotation(_tempFloat4_2);
				rot2.conjugateQuaternion();
				var rot3:Float4 = obj.calculateLocalRotationFromWorldRotation(rot, _tempFloat4_3);
				rot2.multiplyQuaternion(rot3);
				var m:Matrix4x4 = rot2.getMatrixFromQuaternion(_tempMatrix);
				m.toVector3x4(true, _billboardMatConstants.values);
				
				Shader3D.setGlobalConstants(ShaderPropertyType.BILLBOARD_MATRIX, _billboardMatConstants);
			}
		}
		public static function setGlobalLocalToProjMatrix(obj:Coordinates3D, camera:Camera3D):void {
			Coordinates3DHelper.getLocalToProjectionMatrix(obj, camera, _tempMatrix).toVector4x4(true, _localToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_PROJ_MATRIX, _localToProjMatConstants);
		}
		public static function setGlobalLocalToViewMatrix(obj:Coordinates3D, camera:Camera3D):void {
			Coordinates3DHelper.getLocalToLocalMatrix(obj, camera, null, null, null, _tempMatrix).toVector3x4(true, _localToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_WORLD_MATRIX, _localToViewMatConstants);
		}
		public static function setGlobalLocalToWorldMatrix(obj:Coordinates3D):void {
			obj.updateWorldMatrix();
			obj._worldMatrix.toVector3x4(true, _localToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_WORLD_MATRIX, _localToWorldMatConstants);
		}
		public static function setGlobalProjToViewMatrix(camera:Camera3D):void {
			Matrix4x4.invert(camera._projectionMatrix, _tempMatrix).toVector4x4(true, _projToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, _projToViewMatConstants);
		}
		public static function setGlobalProjToWorldMatrix(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix);
			_tempMatrix.invert();
			_tempMatrix.toVector4x4(true, _projToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, _projToWorldMatConstants);
		}
		public static function setGlobalViewWorldPostion(camera:Coordinates3D):void {
			camera.updateWorldMatrix();
			
			_viewWorldPosConstants.values[0] = camera._worldMatrix.m30;
			_viewWorldPosConstants.values[1] = camera._worldMatrix.m31;
			_viewWorldPosConstants.values[2] = camera._worldMatrix.m32;
			_viewWorldPosConstants.values[3] = camera._worldMatrix.m33;
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, _viewWorldPosConstants);
		}
		public static function setGlobalViewToProjMatrix(camera:Camera3D):void {
			camera._projectionMatrix.toVector4x4(true, _viewToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, _viewToProjMatConstants);
		}
		public static function setGlobalWorldToProjMatrix(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix).toVector4x4(true, _worldToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, _worldToProjMatConstants);
		}
		public static function setGlobalForRenderContext(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix).toVector4x4(true, _worldToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, _worldToProjMatConstants);
			
			_tempMatrix.invert();
			_tempMatrix.toVector4x4(true, _projToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, _projToWorldMatConstants);
			
			Matrix4x4.invert(camera._projectionMatrix, _tempMatrix).toVector4x4(true, _projToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, _projToViewMatConstants);
			
			camera._projectionMatrix.toVector4x4(true, _viewToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, _viewToProjMatConstants);
			
			_viewWorldPosConstants.values[0] = camera._worldMatrix.m30;
			_viewWorldPosConstants.values[1] = camera._worldMatrix.m31;
			_viewWorldPosConstants.values[2] = camera._worldMatrix.m32;
			_viewWorldPosConstants.values[3] = camera._worldMatrix.m33;
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, _viewWorldPosConstants);
		}
		public static function clearGlobalForRenderContext():void {
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, null);
		}
		
//		public static function setGlobalDiffuseTexRegion(texRegion:Rectangle, renderableRegion:Rectangle):void {
//			var regionX:Number;
//			var regionY:Number;
//			var regionWidth:Number;
//			var regionHeight:Number;
//			if (texRegion == null) {
//				regionX = 0;
//				regionY = 0;
//				regionWidth = 1;
//				regionHeight = 1;
//			} else {
//				regionX = texRegion.x;
//				regionY = texRegion.y;
//				regionWidth = texRegion.width;
//				regionHeight = texRegion.height;
//			}
//			if (renderableRegion != null) {
//				regionX += texRegion.width * renderableRegion.x;
//				regionY += texRegion.height * renderableRegion.y;
//				regionWidth *= renderableRegion.width;
//				regionHeight *= renderableRegion.height;
//			}
//			
//			_diffTexRegionMatConstants.values[0] = regionX;
//			_diffTexRegionMatConstants.values[1] = regionY;
//			_diffTexRegionMatConstants.values[2] = regionWidth;
//			_diffTexRegionMatConstants.values[3] = regionHeight;
//			
//			Shader3D.setGlobalConstants(ShaderPropertyType.DIFFUSE_TEX_REGION, _diffTexRegionMatConstants);
//		}
		
		public static function setGlobalDiffuseTexMatrix(texRegion:Rectangle, renderableRegion:TextureRegion):void {
			var regionX:Number;
			var regionY:Number;
			var regionWidth:Number;
			var regionHeight:Number;
			if (texRegion == null) {
				regionX = 0;
				regionY = 0;
				regionWidth = 1;
				regionHeight = 1;
			} else {
				regionX = texRegion.x;
				regionY = texRegion.y;
				regionWidth = texRegion.width;
				regionHeight = texRegion.height;
			}
			
			var m00:Number = 1;
			var m01:Number = 0;
			var m10:Number = 0;
			var m11:Number = 1;
			var m30:Number = 0;
			var m31:Number = 0;
			if (renderableRegion != null) {
				regionX += texRegion.width * renderableRegion.x;
				regionY += texRegion.height * renderableRegion.y;
				regionWidth *= renderableRegion.width;
				regionHeight *= renderableRegion.height;
				
				if (renderableRegion.rotate == 0) {
					m00 = regionWidth;
					m11 = regionHeight;
				} else {
					var sin:Number;
					var cos:Number;
					if (renderableRegion.rotate == 1) {
						sin = -1;
						cos = 0;
						
						m31 = 1;
					} else if (renderableRegion.rotate == -1) {
						sin = 1;
						cos = 0;
						
						m30 = 1;
					} else {
						sin = 0;
						cos = 1;
					}
					
					m00 = cos;
					m10 = -sin;
					m01 = sin;
					m11 = cos;
					
					m00 *= regionWidth;
					m10 *= regionWidth;
					m01 *= regionHeight;
					m11 *= regionHeight;
					
					m30 = m30 * regionWidth + regionX;
					m31 = m31 * regionHeight + regionY;
				}
			}
			
			
			_diffTexRegionMatConstants.values[0] = m00;
			_diffTexRegionMatConstants.values[1] = m10;
			_diffTexRegionMatConstants.values[2] = m01;
			_diffTexRegionMatConstants.values[3] = m11;
			_diffTexRegionMatConstants.values[4] = m30;
			_diffTexRegionMatConstants.values[5] = m31;
			
			Shader3D.setGlobalConstants(ShaderPropertyType.DIFFUSE_TEX_REGION, _diffTexRegionMatConstants);
		}
	}
}