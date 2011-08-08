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

    public static const koma_names:Array = new Array('OU', 'HI', 'KA', 'KI', 'GI', 'KE', 'KY', 'FU', '', 'RY', 'UM', '', 'NG', 'NK', 'NY', 'TO' );
	private static const koma_sfen_names:Array = new Array('K', 'R', 'B', 'G', 'S', 'N', 'L', 'P', '', '%2BR', '%2BB', '', '%2BS', '%2BN', '%2BL', '%2BP');
	private static const koma_impasse_points:Array = new Array(100, 5, 5, 1, 1, 1, 1, 1, 0, 5, 5, 1, 1, 1, 1, 1);
	private static const ALL_POINTS:int = 2 * (koma_impasse_points[0] + 27);
	
	public var initialPositionStr:String;

//    public function initialPositionStr():String{
//     var tmp:String = "";
//      tmp += "P1-KY-KE-GI-KI-OU-KI-GI-KE-KY\n";
//      tmp += "P2 * -HI *  *  *  *  * -KA * \n";
//      tmp += "P3-FU-FU-FU-FU-FU-FU-FU-FU-FU\n";
//      tmp += "P4 *  *  *  *  *  *  *  *  * \n";
//      tmp += "P5 *  *  *  *  *  *  *  *  * \n";
//      tmp += "P6 *  *  *  *  *  *  *  *  * \n";
//      tmp += "P7+FU+FU+FU+FU+FU+FU+FU+FU+FU\n";
//      tmp += "P8 * +KA *  *  *  *  * +HI * \n";
//      tmp += "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY\n";
//      return tmp;
//    }

    public static const HAND:int = 100;
    public static const HAND_OU:int = HAND+0;
    public static const HAND_HI:int = HAND+1;
    public static const HAND_KA:int = HAND+2;
    public static const HAND_KI:int = HAND+3;
    public static const HAND_GI:int = HAND+4;
    public static const HAND_KE:int = HAND+5;
    public static const HAND_KY:int = HAND+6;
    public static const HAND_FU:int = HAND+7;

		public function Kyokumen(kyokumen_str:String, promoteY1:int = 2, promoteY2:int = 6):void {
			initialPositionStr = kyokumen_str;
			_promoteY1 = promoteY1;
			_promoteY2 = promoteY2;
			this._turn = SENTE;
			this._ban = new Array(9);
			for (var i:int; i < 9; i++ ) {
				_ban[i] = new Array(9);
			}
			_komadai = new Array(2);
			_impasseStatus = new Array(2);
			for (i = 0; i < 2; i++) {
				_komadai[i] = new Komadai();
				_impasseStatus[i] = new Object();
				_impasseStatus[i] = { 'entered':false, 'pieces':0, 'points':0 };
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
      for(var y:int=0;y<9;y++){
        var line:String = lines[y+1].substr(2);
        for(var x:int=0;x<9;x++){
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
      if(lines.length > 10){
        for(var i:int = 9; i< lines.length; i++){
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
		for (var y:int = 0; y < 9; y++) {
			var line:String = "P" + (y + 1);
			for (var x:int = 0; x < 9; x++) {
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
		for (y = 0; y < 2; y++) {
			line = "P" + (y == SENTE ? "+" : "-");
			for (x = 0; x < 8; x++) {
				if (_komadai[y].getNumOfKoma(x) > 0) {
					for (var i:int = 0; i < _komadai[y].getNumOfKoma(x); i++) {
						line += "00" + koma_names[x];
					}
				}
			}
			if (line.length > 2) str += line + "\n";
		}
		return str;
	}
	
	public function toSFEN():String {
		var str:String = "";
		var n:int = 0;
		for (var y:int = 0; y < 9; y++) {
			for (var x:int = 0; x < 9; x++) {
				if (_ban[x][y]) {
					if (n > 0) str += n;
					n = 0;
					if (_ban[x][y].ownerPlayer == SENTE) {
						str += koma_sfen_names[_ban[x][y].type];
					} else {
						str += koma_sfen_names[_ban[x][y].type].toLowerCase();
					}
				} else {
					n += 1;
				}
			}
			if (n > 0) str += n;
			n = 0;
			if (y < 8) str += "/";
		}
		str += "%20" + (turn == SENTE ? "b" : "w");
		var hand:String = ""
		for (var j:int = 0; j < 2;j++) {
			for (var i:int = 0; i < 8; i++) {
				n = _komadai[j].getNumOfKoma(i);
				if (n > 0) hand += (n > 1 ? n : "") + (j == 0 ? koma_sfen_names[i] : koma_sfen_names[i].toLowerCase());
			}
		}
		if (hand == "") hand = "-";
		str += "%20" + hand;
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
		
//		public function validateMovement(mv:Movement):Boolean {
//			var koma:Koma = _ban[mv.from.x - 1][mv.from.y - 1]; 
//			if (!koma) {
//				return false;
//			}
//
//			//invalid if from and to are the same.
//			if (mv.from.x == mv.to.x && mv.from.y == mv.to.y) {
//				return false;
//			}
//			
//			//invalid if capturing own piece
//			if (Koma(getKomaAt(mv.to)) && Koma(getKomaAt(mv.to)).ownerPlayer == mv.turn) {
//				return false;
//			}
//			
//			return true;
//		}
		
		public function canPromote(from:Point,to:Point):Boolean {
			to = translateHumanCoordinates(to);
			var koma:Koma; 
			if (from.x > HAND) return false;
			from = translateHumanCoordinates(from);
			koma = getKomaAt(from);
			if(koma.isPromoted()) return false;
			if (koma.type == Koma.OU || koma.type == Koma.KI) return false;
			if(koma.ownerPlayer == SENTE){
				if(from.y <= _promoteY1 || to.y <= _promoteY1){
					return true;
				}
			} else {
				if(from.y >= _promoteY2 || to.y >= _promoteY2){
					return true;
				}
			}
			return false;
		}
		
		public function mustPromote(from:Point, to:Point):Boolean {
			from = translateHumanCoordinates(from);
			to = translateHumanCoordinates(to);
			var koma:Koma = getKomaAt(from);
			if (koma.type == Koma.FU || koma.type == Koma.KY) {
				if (koma.ownerPlayer == SENTE && to.y == 0) return true;
				if (koma.ownerPlayer == GOTE && to.y == 8) return true;
			} else if (koma.type == Koma.KE) {
				if (koma.ownerPlayer == SENTE && to.y <= 1) return true;
				if (koma.ownerPlayer == GOTE && to.y >= 7) return true;
			}
			return false;
		}
		
		public function isNifu(from:Point, to:Point):Boolean {
			if (from.x == HAND_FU) {
				to = translateHumanCoordinates(to);
				for (var i:int = 0; i < 9; i++) {
					var koma:Koma;
					if ((koma = getKomaAt(new Point(to.x, i)))) {
						if (koma.type == Koma.FU && koma.ownerPlayer == _turn) {
							return true;
						}
					}
				}
			}
			return false;
		}
		
		public function cantMove(koma:Koma, from:Point,to:Point):Boolean {
			if(from.x > HAND) return false;
			from = translateHumanCoordinates(from);
			to = translateHumanCoordinates(to);
//			var koma:Koma; 
//	        koma = getKomaAt(from);
	        var dx:Number = to.x - from.x;
	        var dy:Number = koma.ownerPlayer == SENTE ? to.y - from.y : from.y - to.y;
	        switch (koma.type){
	        	case Koma.OU:
				case Koma.OU+Koma.PROMOTE:
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
	        	case Koma.KI:
	        	case Koma.GI+Koma.PROMOTE:
	        	case Koma.KE+Koma.PROMOTE:
	        	case Koma.KY+Koma.PROMOTE:
	        	case Koma.FU+Koma.PROMOTE:
	        		if (Math.abs(dx) == 1 && dy == 1) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
	        	case Koma.GI:
	        		if (Math.abs(dx) == 1 && dy == 0) return true;
	        		if (dx == 0 && dy == 1) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
					break;
				case Koma.HI+Koma.PROMOTE:
					if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        	case Koma.HI:
					if (dx == 0) {
						if (Math.abs(dy) == 1) return false;
						for (var i:int = Math.min(from.y, to.y) + 1; i <= Math.max(from.y, to.y) - 1; i++) {
							if (getKomaAt(new Point(from.x, i))) return true;
						}
						return false;
					} else if (dy == 0) {
						if (Math.abs(dx) == 1) return false;
						for (i = Math.min(from.x, to.x) + 1; i <= Math.max(from.x, to.x) - 1; i++) {
							if (getKomaAt(new Point(i, from.y))) return true;
						}
						return false;
					}
	        		break;
				case Koma.KA + Koma.PROMOTE:
					if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        	case Koma.KA:
	        		if (Math.abs(dx) == Math.abs(dy)) {
						if (Math.abs(dx) == 1) return false;
						for (i = 1; i <= int(Math.abs(dx)) - 1; i++) {
							if (getKomaAt(new Point(from.x + (dx > 0 ? i : - i), from.y + (to.y > from.y ? i : - i)))) return true;
						}
						return false;
					}
	        		break;
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
	        	case Koma.KE:
	        		if (Math.abs(dx) == 1 && dy == -2) return false;
				default:
	        }
	        return true;
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
      return new Point(9-p.x,p.y-1);
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
      var capture:Boolean = getKomaAt(to) != null
	  var mv:Movement = new Movement();
	  mv.setFromKyokumen(_turn, from, to, koma.type, promote, capture, _last_to);
	  return mv;
    }

    public function generateMovementFromString(moveStr:String):Movement {
	  if (!moveStr || moveStr.charAt(0) == "%") return null;
	  var turn:int = moveStr.charAt(0) == "+" ? Kyokumen.SENTE : Kyokumen.GOTE;
      var from:Point = new Point(parseInt(moveStr.charAt(1)),parseInt(moveStr.charAt(2)));
      if(from.x == 0){
        from.x = HAND;
        from.y = HAND;
      } else {
        from = translateHumanCoordinates(from);
      }
      var to:Point = new Point(parseInt(moveStr.charAt(3)),parseInt(moveStr.charAt(4)));
      to = translateHumanCoordinates(to);
      var capture:Boolean = getKomaAt(to) != null
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
			if (getKomaAt(mv.to) != null) {
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
		
		public function calcImpasse():void {
			var turn:int;
			var total_points:int = 0;
			for (turn = 0; turn < 2; turn++) {
				_impasseStatus[turn].entered = false;
				_impasseStatus[turn].pieces = 0;
				_impasseStatus[turn].points = 0;
				for (var i:int = 0; i < 8; i++) {
					_impasseStatus[turn].points += _komadai[turn].getNumOfKoma(i) * koma_impasse_points[i];
				}
				total_points += _impasseStatus[turn].points;
			}
			for (var y:int = 0; y < 9; y++) {
				for (var x:int = 0; x < 9; x++) {
					if (_ban[x][y]) {
						total_points += koma_impasse_points[_ban[x][y].type];
						if (y <= _promoteY1) {
							turn = SENTE;
						} else if (y >= _promoteY2) {
							turn = GOTE;
						} else {
							continue;
						}
						if (_ban[x][y].ownerPlayer == turn) {
							_impasseStatus[turn].pieces += 1;
							_impasseStatus[turn].points += koma_impasse_points[_ban[x][y].type];
						}
					}
				}
			}
			_impasseStatus[GOTE].points += ALL_POINTS - total_points;
			for (turn = 0; turn < 2; turn++) {
				if (_impasseStatus[turn].points >= koma_impasse_points[0]) {
					_impasseStatus[turn].points -= koma_impasse_points[0];
					_impasseStatus[turn].pieces -= 1;
					_impasseStatus[turn].entered = true;
				}
			}
		}
		
//		public function calcImpasse(turn:int):int {
//			var n:int = 0;
//			for (var y:int = 0; y < 9; y++) {
//				if (turn == SENTE) {
//					if (y > _promoteY1) continue;
//				} else {
//					if (y < _promoteY2) continue;
//				}
//				for (var x:int = 0; x < 9; x++) {
//						if (_ban[x][y] && _ban[x][y].ownerPlayer == turn) n += koma_impasse_points[_ban[x][y].type];
//				}
//			}
//			for (var i:int = 0; i < 8; i++) {
//				n += _komadai[turn].getNumOfKoma(i) * koma_impasse_points[i];
//			}
//			return n;
//		}

	}
	
}
