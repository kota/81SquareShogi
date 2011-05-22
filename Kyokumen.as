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

    public static const koma_names:Array = new Array('OU', 'ZG', 'ZE', 'ZC', '', '', '', 'TO');
    private static const koma_western_names:Array = new Array('K','R','B','P','','','','T');
    private static const koma_japanese_names:Array = new Array('ら', 'ひ', 'ゾ', 'キ', '', '', '', 'ニ');
	private static const koma_impasse_points:Array = new Array(100, 5, 5, 1, 0, 0, 0, 1);
    private static const file_names:Array = new Array('A','B','C','','','','','','');
    private static const rank_japanese_names:Array = new Array('一','二','三','四','五','六','七','八','九');
    private static const file_japanese_names:Array = new Array('１', '２', '３', '４', '５', '６', '７', '８', '９');
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

		public function Kyokumen(kyokumen_str:String, promoteY1:int = 0, promoteY2:int = 3):void {
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
			for (x = 0; x < 4; x++) {
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
			if (koma.type != Koma.ZC) return false;
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
			return false;
		}
		
		public function isNifu(from:Point, to:Point):Boolean {
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
	        	case Koma.ZC+Koma.PROMOTE:
	        		if (Math.abs(dx) == 1 && dy == 1) return true;
	        		if (Math.abs(dx) <= 1 && Math.abs(dy) <=1) return false;
	        		break;
	        	case Koma.ZG:
	        		if (Math.abs(dx) == 1 && dy == 0) return false;
	        		if (dx == 0 && Math.abs(dy) == 1) return false;
	        		break;
	        	case Koma.ZE:
	        		if (Math.abs(dx) == 1 && Math.abs(dy) == 1) return false;
					break;
	        	case Koma.ZC:
	        		if (dx == 0 && dy == -1) return false;
	        		break;
				default:
	        }
	        return true;
		}
		
		public function isSoundDouble(to:Point):Boolean {
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

      return new Movement(_turn,from,to,koma,promote,capture);
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
      var koma:Koma = new Koma(koma_names.indexOf(moveStr.slice(5,7)),to.x,to.y,turn);
			var match:Array = moveStr.match(/,T([0-9]*)/);
			var time:int = parseInt(match[1]);
	  if (from.x != HAND){
	  	var promote:Boolean = getKomaAt(from).type != koma_names.indexOf(moveStr.slice(5,7));
	  }
      return new Movement(turn,from,to,koma,promote,capture,time);
    }
		
		public function move(mv:Movement):void {
			var koma:Koma = mv.koma; 
			//drop
			if(mv.from.x == HAND){
				_komadai[koma.ownerPlayer].removeKoma(koma.type);
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
			koma.x = mv.to.x;
			koma.y = mv.to.y;
      setKomaAt(mv.to,koma);
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
		
	public function generateWesternNotationFromMovement(mv:Movement):String {
	  var notationStr:String = mv.turn == 0 ? "▲" : "△";
	  var originalType:int = mv.promote ? mv.koma.type - Koma.PROMOTE : mv.koma.type;
	  notationStr += koma_western_names[originalType];
	  if (mv.from.x == HAND) {
	  	notationStr += "*";
	  } else if (mv.capture) {
	  	notationStr += "x";
	  } else {
	  	notationStr += "-";
	  }
	  if (mv.to.x != _last_to.x || mv.to.y != _last_to.y) {
		notationStr += file_names[mv.to.x];
		notationStr += mv.to.y + 1;
	  }
	  _last_to = mv.to;
	  if (mv.promote) {
	  	notationStr += "+";
	  } else if (mv.from.x != HAND && !mv.koma.isPromoted() && mv.koma.type == Koma.ZC){
	  	if ( mv.turn == Kyokumen.SENTE && mv.to.y == 0 || mv.turn == Kyokumen.GOTE && mv.to.y == 3) notationStr += "=";
	  } 
	  do {
		  notationStr += " ";
	  } while (notationStr.length < 7);
	  notationStr += " (" + mv.time + ")";
	  return notationStr;	
	}
	
	public function generateKIFTextFromMovement(mv:Movement):String{
	  var KIFStr:String = file_japanese_names[8 - mv.to.x];
	  KIFStr += rank_japanese_names[mv.to.y];
	  
	  var originalType:int = mv.promote ? mv.koma.type - Koma.PROMOTE : mv.koma.type;
	  KIFStr += koma_japanese_names[originalType];
	  if (mv.from.x == HAND) {
	  	KIFStr += "打";
	  } else {
	  	if (mv.promote) KIFStr += "成";
	  	KIFStr += "(" + String(9 - mv.from.x) + String(mv.from.y + 1) + ")";
	  }
	  KIFStr += "   ( " + int(mv.time/60) + ":" + mv.time % 60 + "/)";
	  return KIFStr;	
	}

	}
	
}
