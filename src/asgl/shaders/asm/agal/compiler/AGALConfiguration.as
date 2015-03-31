package asgl.shaders.asm.agal.compiler {
	public class AGALConfiguration {
		private static const NUM_REGISTERS:Object = _createNumMap();
		private static const NUM_TOKENS:Object = {1:200, 2:1024, 3:2048};
		
		private var _version:int;
		private var _tokens:int;
		
		private var _va:AGALRegister;
		private var _vc:AGALRegister;
		private var _vt:AGALRegister;
		private var _vo:AGALRegister;
		private var _v:AGALRegister;
		private var _fc:AGALRegister;
		private var _ft:AGALRegister;
		private var _fo:AGALRegister;
		private var _fs:AGALRegister;
		private var _fd:AGALRegister;
		
		private var _registerMap:Object;
		
		public function AGALConfiguration(version:uint) {
			_version = version;
			
			if (_version >= 1 && _version <= 3) {
				_tokens = NUM_TOKENS[_version];
				
				_va = new AGALRegister(AGALRegisterType.VA, getAvailableMaxNumRegisters(AGALRegisterType.VA, _version), AGALScopeType.VERTEX);
				_vc = new AGALRegister(AGALRegisterType.VC, getAvailableMaxNumRegisters(AGALRegisterType.VC, _version), AGALScopeType.VERTEX);
				_vt = new AGALRegister(AGALRegisterType.VT, getAvailableMaxNumRegisters(AGALRegisterType.VT, _version), AGALScopeType.VERTEX);
				_vo = new AGALRegister(AGALRegisterType.VO, getAvailableMaxNumRegisters(AGALRegisterType.VO, _version), AGALScopeType.VERTEX);
				_v = new AGALRegister(AGALRegisterType.V, getAvailableMaxNumRegisters(AGALRegisterType.V, _version), AGALScopeType.VERTEX|AGALScopeType.FRAGMENT);
				_fc = new AGALRegister(AGALRegisterType.FC, getAvailableMaxNumRegisters(AGALRegisterType.FC, _version), AGALScopeType.FRAGMENT);
				_ft = new AGALRegister(AGALRegisterType.FT, getAvailableMaxNumRegisters(AGALRegisterType.FT, _version), AGALScopeType.FRAGMENT);
				_fo = new AGALRegister(AGALRegisterType.FO, getAvailableMaxNumRegisters(AGALRegisterType.FO, _version), AGALScopeType.FRAGMENT);
				_fs = new AGALRegister(AGALRegisterType.FS, getAvailableMaxNumRegisters(AGALRegisterType.FS, _version), AGALScopeType.FRAGMENT);
				_fd = new AGALRegister(AGALRegisterType.FD, getAvailableMaxNumRegisters(AGALRegisterType.FD, _version), AGALScopeType.FRAGMENT);
			} else {
				_tokens = uint.MAX_VALUE;
				_va = new AGALRegister(AGALRegisterType.VA, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vc = new AGALRegister(AGALRegisterType.VC, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vt = new AGALRegister(AGALRegisterType.VT, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vo = new AGALRegister(AGALRegisterType.VO, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_v = new AGALRegister(AGALRegisterType.V, uint.MAX_VALUE, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT);
				_fc = new AGALRegister(AGALRegisterType.FC, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_ft = new AGALRegister(AGALRegisterType.FT, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_fo = new AGALRegister(AGALRegisterType.FO, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_fs = new AGALRegister(AGALRegisterType.FS, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_fd = new AGALRegister(AGALRegisterType.FD, 1, AGALScopeType.FRAGMENT);
			}
			
			_registerMap = {};
			_registerMap[AGALRegisterType.VA] = _va;
			_registerMap[AGALRegisterType.VC] = _vc;
			_registerMap[AGALRegisterType.VT] = _vt;
			_registerMap[AGALRegisterType.VO] = _vo;
			_registerMap[AGALRegisterType.V]  = _v;
			_registerMap[AGALRegisterType.FC] = _fc;
			_registerMap[AGALRegisterType.FT] = _ft;
			_registerMap[AGALRegisterType.FO] = _fo;
			_registerMap[AGALRegisterType.FS] = _fs;
			_registerMap[AGALRegisterType.FD] = _fd;
		}
		private static function _createNumMap():Object {
			var map:Object = {};
			map[AGALRegisterType.VA] = {1:8,   2:8,   3:16};
			map[AGALRegisterType.VC] = {1:128, 2:250, 3:250};
			map[AGALRegisterType.VT] = {1:8,   2:26,  3:26};
			map[AGALRegisterType.VO] = {1:1,   2:1,   3:1};
			map[AGALRegisterType.V]  = {1:8,   2:10,  3:10};
			map[AGALRegisterType.FC] = {1:28,  2:64,  3:200};
			map[AGALRegisterType.FT] = {1:8,   2:26,  3:26};
			map[AGALRegisterType.FO] = {1:1,   2:4,   3:4};
			map[AGALRegisterType.FS] = {1:8,   2:8,   3:8};
			map[AGALRegisterType.FD] = {1:0,   2:1,   3:1};
			
			return map;
		}
		public static function getAvailableMaxNumRegisters(type:uint, version:uint):uint {
			var obj:Object = NUM_REGISTERS[type];
			if (obj == null) {
				return 0;
			} else {
				return obj[version];
			}
		}
		public static function getLowestVersionWithRegisterIndex(type:uint, index:uint):uint {
			var obj:Object = NUM_REGISTERS[type];
			if (obj == null) {
				return 0;
			} else {
				var min:int = int.MAX_VALUE;
				for (var version:int in obj) {
					if (index < obj[version]) {
						if (min > version) {
							min = version;
						}
					}
				}
				
				return min == int.MAX_VALUE ? 0 : min;
			}
		}
		public static function getLowestVersionWithTokens(num:uint):int {
			var v:int = 1;
			while (true) {
				var n:* = NUM_TOKENS[v];
				if (n == null) {
					return 0;
				} else if (num < n) {
					return v;
				}
			}
			
			return 0;
		}
		public function get version():int {
			return _version;
		}
		public function get tokens():int {
			return _tokens;
		}
		public function get va():AGALRegister {
			return _va;
		}
		public function get vc():AGALRegister {
			return _vc;
		}
		public function get vt():AGALRegister {
			return _vt;
		}
		public function get vo():AGALRegister {
			return _vo;
		}
		public function get v():AGALRegister {
			return _v;
		}
		public function get fc():AGALRegister {
			return _fc;
		}
		public function get ft():AGALRegister {
			return _ft;
		}
		public function get fo():AGALRegister {
			return _fo;
		}
		public function get fs():AGALRegister {
			return _fs;
		}
		public function get fd():AGALRegister {
			return _fd;
		}
		public function getRegsiter(type:int):AGALRegister {
			return _registerMap[type];
		}
	}
}