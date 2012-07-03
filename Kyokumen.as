/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.geom.Point;
	
	public class Kyokumen {
		
		public static const SENTE:int = 0;
		public static const GOTE:int = 1;

		private var _turn:int;
		private var _ban:Array;
		private var _komadai:Array;
		private var _superior:int;
		private var _impasseStatus:Array;
		private var _last_to:Point;
		private var _promoteY1:int;
		private var _promoteY2:int;
		private var _half_move:Boolean = false;
		private var _first_move:Movement;

    public static const koma_names:Array = new Array('OU', 'SZ', 'KR', 'HO', 'LI', 'HN', 'RY', 'UM', 'HI', 'KA', 'KO', 'KI', 'GI', 'DO', 'HY', 'SG', 'OG', 'HE', 'KY', 'CN', 'FU',
													 '', 'TA', 'PL', 'PN', '', '', 'WS', 'TK', 'PR', 'PU', 'SK', 'PH', 'PS', 'PO', 'PK', 'GY', 'CH', 'KJ', 'HK', 'PZ', 'TO');
	private static const koma_sfen_names:Array = new Array('K', 'R', 'B', 'G', 'S', 'N', 'L', 'P', '', '%2BR', '%2BB', '', '%2BS', '%2BN', '%2BL', '%2BP');
	
	public var initialPositionStr:String;

    public static const HAND:int = 100;
//    public static const HAND_OU:int = HAND+0;
//    public static const HAND_HI:int = HAND+1;
//    public static const HAND_KA:int = HAND+2;
//    public static const HAND_KI:int = HAND+3;
//    public static const HAND_GI:int = HAND+4;
//    public static const HAND_KE:int = HAND+5;
//    public static const HAND_KY:int = HAND+6;
//    public static const HAND_FU:int = HAND+7;

		public function Kyokumen(kyokumen_str:String, promoteY1:int = 3, promoteY2:int = 8):void {
			initialPositionStr = kyokumen_str;
			_promoteY1 = promoteY1;
			_promoteY2 = promoteY2;
			this._turn = SENTE;
			this._ban = new Array(12);
			for (var i:int; i < 12; i++ ) {
				_ban[i] = new Array(12);
			}
			_komadai = new Array(2);
			for (i = 0; i < 2; i++) {
				_komadai[i] = new Komadai();
			}
			loadFromString(initialPositionStr);
			this._last_to = new Point(0, 0);
		}

    public function loadFromString(position_str:String):void{
      var lines:Array = position_str.split("\n");
	  if (lines[0].substr(2) == "+") {
		  _turn = SENTE;
	  } else {
		  _turn = GOTE;
	  }
      for(var y:int=0;y<12;y++){
        var line:String = lines[y+1].substr(2);
        for(var x:int=0;x<12;x++){
          var koma_str:String = line.slice(x*3,x*3+3)
          if(koma_str != " * "){
            var owner:int = koma_str.charAt(0) == '+' ? SENTE : GOTE
            var koma:Koma = new Koma(koma_names.indexOf(koma_str.slice(1,3)),x,y,owner);
            _ban[x][y] = koma;
          } else {
            _ban[x][y] = null;
          }
        }
      }
	  _komadai[0].clearKoma();
	  _komadai[1].clearKoma();
      if(lines.length > 13){
        for(var i:int = 12; i< lines.length; i++){
          var match:Array = lines[i].match(/P([+-])00(.*)/);
          if(match != null){
            owner = match[1] == "+" ? SENTE : GOTE
            var komas:Array = lines[i].split("00");
            komas.shift();//P[+-]
            for each(var koma_name:String in komas){
              koma = new Koma(koma_names.indexOf(koma_name),0,0,owner);
              _komadai[owner].addKoma(koma);
            }
          }
        }
      }
    }
	
	public function toString():String {
		var str:String = "";
		if (_turn == SENTE) {
			str += "P0+\n";
		} else {
			str += "P0-\n";
		}
		for (var y:int = 0; y < 12; y++) {
			var line:String = "P" + (y + 1).toString(16);
			for (var x:int = 0; x < 12; x++) {
				if (_ban[x][y]) {
					if (_ban[x][y].ownerPlayer == SENTE) {
						line += "+";
					} else {
						line += "-";
					}
					line += koma_names[_ban[x][y].type];
				} else {
					line += " * ";
				}
			}
			str += line + "\n";
		}
		return str;
	}
		
		public function get ban():Array{
			return this._ban;
		}

		public function get turn():int {
			return this._turn;
		}
		
		public function set turn(v:int):void {
			this._turn = v;
		}
		
		public function get half_move():Boolean {
			return this._half_move;
		}
		
		public function get first_move():Movement {
			return this._first_move;
		}
		
		public function get impasseStatus():Array {
			return this._impasseStatus;
		}

		public function getKomadai(sengo:int):Komadai{
			if(sengo > 1){
				return Komadai(null);
			} else {
				return _komadai[sengo];
			}
		}

		public function getKomaAt(p:Point):Koma {
			return _ban[p.x][p.y] as Koma;
 		}

    public function setKomaAt(p:Point,koma:Koma):void{
      _ban[p.x][p.y] = koma;
    }
		
		public function canPromote(from:Point,to:Point):Boolean {
			to = translateHumanCoordinates(to);
			var koma:Koma;
			if (from.x > HAND) return false;
			from = translateHumanCoordinates(from);
			koma = getKomaAt(from);
			if(koma.isPromoted()) return false;
			if (koma.type == Koma.OU || koma.type == Koma.LI || koma.type == Koma.HN) return false;
			if(koma.ownerPlayer == SENTE){
				if (from.y > _promoteY1 && to.y <= _promoteY1) return true;
				else if ((koma.type == Koma.FU || koma.type == Koma.KY) && to.y == 0) return true;
				else if (from.y <= _promoteY1 || to.y <= _promoteY1){
					if (getKomaAt(to)) return true;
				}
			} else {
				if (from.y < _promoteY2 && to.y >= _promoteY2) return true;
				else if ((koma.type == Koma.FU || koma.type == Koma.KY) && to.y == 11) return true;
				else if (from.y >= _promoteY2 || to.y >= _promoteY2){
					if (getKomaAt(to)) return true;
				}
			}
			return false;
		}
		
		public function cantMove(koma:Koma, from:Point,to:Point):Boolean {
			if(from.x > HAND) return false;
			from = translateHumanCoordinates(from);
			to = translateHumanCoordinates(to);
	        var to_koma:Koma = getKomaAt(to);
			if (to_koma) {
				if (to_koma.ownerPlayer == koma.ownerPlayer) return true;
			}
	        var dx:Number = to.x - from.x;
	        var dy:Number = koma.ownerPlayer == SENTE ? to.y - from.y : from.y - to.y;
	        switch (koma.type) {
				case Koma.KO+Koma.PROMOTE:
					if (dx == 0) {
						if (Math.abs(dy) == 1) return false;
						for (var i:int = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
				case Koma.SZ:
				case Koma.CN+Koma.PROMOTE:
					if (dx == 0 && dy == 1) return true;
	        	case Koma.OU:
				case Koma.OU + Koma.PROMOTE:
				case Koma.SZ+Koma.PROMOTE:
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
					
				case Koma.KO:
					if (dx == 0 && dy == -1) return true;
					if (Math.abs(dx) <= 1 && Math.abs(dy) <= 1) return false;
					break;
					
				case Koma.HY:
					if (Math.abs(dx) == 1 && dy == 0) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
					
	        	case Koma.KI:
	        	case Koma.FU+Koma.PROMOTE:
	        		if (Math.abs(dx) == 1 && dy == 1) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
					
	        	case Koma.GI:
	        		if (Math.abs(dx) == 1 && dy == 0) return true;
	        		if (dx == 0 && dy == 1) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
					break;
					
	        	case Koma.DO:
	        		if (Math.abs(dx) <= 1 && dy == -1) return false;
	        		if (dx == 0 && dy == 1) return false;
					break;
					
				case Koma.RY:
				case Koma.HI+Koma.PROMOTE:
					if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        	case Koma.HI:
				case Koma.KI + Koma.PROMOTE:
					if (dy == 0) {
						if (Math.abs(dx) == 1) return false;
						for (i = Math.min(from.x, to.x) + 1; i <= Math.max(from.x, to.x) - 1; i++) {
							if (getKomaAt(new Point(i, from.y))) return true;
						}
						return false;
					}
				case Koma.SG:
				case Koma.GI + Koma.PROMOTE:
					if (Math.abs(dx) == 1 && dy == 0) return false;
				case Koma.HE:
					if (dx == 0) {
						if (Math.abs(dy) == 1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
	        		break;
					
				case Koma.UM:
				case Koma.KA + Koma.PROMOTE:
					if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        	case Koma.KA:
				case Koma.HY+Koma.PROMOTE:
	        		if (Math.abs(dx) == Math.abs(dy)) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
	        		break;
					
				case Koma.OG:
				case Koma.DO+Koma.PROMOTE:
					if (dy == 0) {
						if (Math.abs(dx) == 1) return false;
						for (i = Math.min(from.x, to.x) + 1; i <= Math.max(from.x, to.x) - 1; i++) {
							if (getKomaAt(new Point(i, from.y))) return true;
						}
						return false;
					}
				case Koma.CN:
					if (dx == 0 && dy == 1) return false;
	        	case Koma.FU:
	        		if (dx == 0 && dy == -1) return false;
	        		break;
					
	        	case Koma.KY:
	        		if (dx == 0 && dy < 0) {
						if (dy == -1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
	        		break;
					
				case Koma.HN:
				case Koma.HO+Koma.PROMOTE:
	        		if (dx == 0 && dy < 0) {
						if (dy == -1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
				case Koma.UM+Koma.PROMOTE:
					if (dx == 0 && (dy == -1 || dy == -2)) return false;
	        		if (dx == 0 && dy > 0) {
						if (dy == 1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
				case Koma.OG+Koma.PROMOTE:
					if (dy == 0) {
						if (Math.abs(dx) == 1) return false;
						for (i = Math.min(from.x, to.x) + 1; i <= Math.max(from.x, to.x) - 1; i++) {
							if (getKomaAt(new Point(i, from.y))) return true;
						}
						return false;
					}
	        		if (Math.abs(dx) == Math.abs(dy)) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
					break;
					
				case Koma.RY + Koma.PROMOTE:
					if (Math.abs(dx) == 1 && dy == -1 || Math.abs(dx) == 2 && dy == -2) return false;
					if (dy == 0) {
						if (Math.abs(dx) == 1) return false;
						for (i = Math.min(from.x, to.x) + 1; i <= Math.max(from.x, to.x) - 1; i++) {
							if (getKomaAt(new Point(i, from.y))) return true;
						}
						return false;
					}
				case Koma.HE + Koma.PROMOTE:
					if (dx == 0) {
						if (Math.abs(dy) == 1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
	        		if (Math.abs(dx) == dy) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
	        		break;
					
				case Koma.SG+Koma.PROMOTE:
	        		if (Math.abs(dx) == dy) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
				case Koma.KY + Koma.PROMOTE:
	        		if (- Math.abs(dx) == dy) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
					if (dx == 0) {
						if (Math.abs(dy) == 1) return false;
						for (i = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					}
					break;
					
				case Koma.LI:
				case Koma.KR + Koma.PROMOTE:
					if (Math.abs(dx) <= 2 && Math.abs(dy) <= 2) return false;
					break;
					
				case Koma.KR:
					if (Math.abs(dx) == 1 && Math.abs(dy) == 1) return false;
					if (dx == 0 && Math.abs(dy) == 2) return false;
					if (dy == 0 && Math.abs(dx) == 2) return false;
					break;
					
				case Koma.HO:
					if (Math.abs(dx) == 2 && Math.abs(dy) == 2) return false;
					if (dx == 0 && Math.abs(dy) == 1) return false;
					if (dy == 0 && Math.abs(dx) == 1) return false;
					break;
					
				default:
	        }
	        return true;
		}
		
		public function isSecondMovableGrids(x:int, y:int):Boolean {
			var p:Point = new Point(x, y);
			p = translateHumanCoordinates(p);
			if (_first_move.type == Koma.LI || _first_move.type == Koma.KR + Koma.PROMOTE) {
				if (Math.abs(p.x - _first_move.to.x) <= 1 && Math.abs(p.y - _first_move.to.y) <= 1) return true;
			} else if (_first_move.type == Koma.UM + Koma.PROMOTE || _first_move.type == Koma.RY + Koma.PROMOTE) {
				if ((p.x == _first_move.from.x && p.y == _first_move.from.y) || (p.x == _first_move.to.x && p.y == _first_move.to.y) || (p.x == 2 * _first_move.to.x - _first_move.from.x && p.y == 2 * _first_move.to.y - _first_move.from.y)) return true;
			}
			return false;
		}
		
		public function isSoundDouble(to:Point):Boolean {
			var koma:Koma;
			if (getKomaAt(to).ownerPlayer == SENTE && to.y <= 7) {
				if ((koma = getKomaAt(new Point(to.x, to.y + 1)))) {
					if (koma.ownerPlayer == SENTE) return true;
				}
			} else if (getKomaAt(to).ownerPlayer == GOTE && to.y >= 1) {
				if ((koma = getKomaAt(new Point(to.x, to.y - 1)))) {
					if (koma.ownerPlayer == GOTE) return true;
				}
			}
			return false;
		}

    public static function translateHumanCoordinates(p:Point):Point{
      return new Point(12-p.x,p.y-1);
    }

    public function generateMovementFromCoordinates(from:Point,to:Point,promote:Boolean):Movement{
      var koma:Koma;
      if(from.x > HAND){
        koma = new Koma(from.x-HAND,from.x,from.y,_turn);
      } else {
        from = translateHumanCoordinates(from);
        koma = getKomaAt(from);
      }
      to = translateHumanCoordinates(to);
      var capture:Boolean = ((to.x != from.x || to.y != from.y) && getKomaAt(to) != null)
	  var mv:Movement = new Movement();
	  mv.setFromKyokumen(_turn, from, to, koma.type, promote, capture, _last_to);
	  return mv;
    }

    public function generateMovementFromString(moveStr:String):Movement {
	  if (!moveStr || moveStr.charAt(0) == "%") return null;
	  var turn:int = moveStr.charAt(0) == "+" ? Kyokumen.SENTE : Kyokumen.GOTE;
      var from:Point = new Point(parseInt(moveStr.charAt(1), 16), parseInt(moveStr.charAt(2), 16));
      if(from.x == 0){
        from.x = HAND;
        from.y = HAND;
      } else {
        from = translateHumanCoordinates(from);
      }
      var to:Point = new Point(parseInt(moveStr.charAt(3),16),parseInt(moveStr.charAt(4),16));
      to = translateHumanCoordinates(to);
      var capture:Boolean = ((to.x != from.x || to.y != from.y) && getKomaAt(to) != null)
	  var match:Array = moveStr.match(/,T([0-9]*)/);
	  var time:int = parseInt(match[1]);
	  if (from.x != HAND){
	  	var promote:Boolean = getKomaAt(from).type != koma_names.indexOf(moveStr.slice(5,7));
	  }
	  var mv:Movement = new Movement();
	  mv.setFromKyokumen(turn, from, to, koma_names.indexOf(moveStr.slice(5,7)) - (promote ? Koma.PROMOTE : 0), promote, capture, _last_to, time);
	  return mv;
    }
		
		public function move(mv:Movement):void {
			//drop
			if(mv.from.x == HAND){
				_komadai[mv.turn].removeKoma(mv.type);
			}
			//put piece into hand if capturing.
			if ((mv.to.x != mv.from.x || mv.to.y != mv.from.y) && getKomaAt(mv.to) != null) {
				if(mv.from.x == HAND){
					return; //illegal
				} else {
					var captured_koma:Koma = getKomaAt(mv.to);
					_captureKoma(captured_koma,_turn);
				}
			}
			//move piece
			if(mv.from.x != HAND){
				//_ban[mv.from.x - 1][mv.from.y - 1] = null;
				setKomaAt(mv.from,null);
			}
			setKomaAt(mv.to, mv.getResultKoma());
			_last_to = mv.to;
			if (_half_move) {
				_half_move = false;
			} else {
				if (mv.type == Koma.LI || mv.type == Koma.KR + Koma.PROMOTE) {
					if (Math.abs(mv.to.x - mv.from.x) <= 1 && Math.abs(mv.to.y - mv.from.y) <= 1) {
						_half_move = true;
						_first_move = mv;
						return;
					}
				} else if (mv.type == Koma.UM + Koma.PROMOTE) {
					if (mv.to.x == mv.from.x && (mv.to.y - mv.from.y == (_turn == SENTE ? -1 : 1))) {
						_half_move = true;
						_first_move = mv;
						return;
					}
				} else if (mv.type == Koma.RY + Koma.PROMOTE) {
					if (Math.abs(mv.to.x - mv.from.x) == 1 && (mv.to.y - mv.from.y == (_turn == SENTE ? -1 : 1))) {
						_half_move = true;
						_first_move = mv;
						return;
					}
				}
			}
			_turn = _turn == SENTE ? GOTE : SENTE;
		}

		private function _captureKoma(koma:Koma,turn:int):void {
      setKomaAt(new Point(koma.x,koma.y),null);
			koma.ownerPlayer = turn;
			koma.x = HAND;
			koma.y = HAND;
			if (koma.isPromoted()) {
				koma.depromote();
			}
			_komadai[turn].addKoma(koma);
		}

	}
	
}
