/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import Board;
	import Komadai;
	
	public class Kyokumen {
		
		public static const SENTE:int = 0;
		public static const GOTE:int = 1;

		private var _turn:int;
		private var _ban:Array;
		private var _komadai:Array;

    public static const koma_names:Array = new Array('OU', 'HI', 'KA', 'KI', 'GI', 'KE', 'KY', 'FU', '', 'RY', 'UM', '', 'NG', 'NK', 'NY', 'TO' );

    public function initialPositionStr():String{
      var tmp:String = "";
      tmp += "P1-KY-KE-GI-KI-OU-KI-GI-KE-KY\n";
      tmp += "P2 * -HI *  *  *  *  * -KA * \n";
      tmp += "P3-FU-FU-FU-FU-FU-FU-FU-FU-FU\n";
      tmp += "P4 *  *  *  *  *  *  *  *  * \n";
      tmp += "P5 *  *  *  *  *  *  *  *  * \n";
      tmp += "P6 *  *  *  *  *  *  *  *  * \n";
      tmp += "P7+FU+FU+FU+FU+FU+FU+FU+FU+FU\n";
      tmp += "P8 * +KA *  *  *  *  * +HI * \n";
      tmp += "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY\n";
      return tmp;
    }

    public static const HAND:int = 100;
    public static const HAND_OU:int = HAND+0;
    public static const HAND_HI:int = HAND+1;
    public static const HAND_KA:int = HAND+2;
    public static const HAND_KI:int = HAND+3;
    public static const HAND_GI:int = HAND+4;
    public static const HAND_KE:int = HAND+5;
    public static const HAND_KY:int = HAND+6;
    public static const HAND_FU:int = HAND+7;

		public function Kyokumen():void {
			this._turn = SENTE;
			this._ban = new Array(9);
			for (var i:int; i < 9; i++ ) {
				_ban[i] = new Array(9);
			}
			_komadai = new Array(2);
			_komadai[0] = new Komadai();
			_komadai[1] = new Komadai();

      loadFromString(initialPositionStr());
		}

    public function loadFromString(position_str:String):void{
      var lines:Array = position_str.split("\n");
      var id:int = 0;
      for(var y:int=0;y<9;y++){
        var line:String = lines[y].substr(2);
        for(var x:int=0;x<9;x++){
          var koma_str:String = line.slice(x*3,x*3+3)
          if(koma_str != " * "){
            var owner:int = koma_str.charAt(0) == '+' ? SENTE : GOTE 
            var koma:Koma = new Koma(koma_names.indexOf(koma_str.slice(1,3)),x,y,owner);
            id++;
            _ban[x][y] = koma;
          } else {
            _ban[x][y] = null;
          }
        }
      }
    }
		
		public function get ban():Array{
			return this._ban;
		}

		public function get turn():int {
			return this._turn;
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
		
		public function validateMovement(mv:Movement):Boolean {
			var koma:Koma = _ban[mv.from.x - 1][mv.from.y - 1]; 
			if(!koma){
				return false;
			}
			
			//invalid if from and to are the same.
			if (mv.from.x == mv.to.x && mv.from.y == mv.to.y) {
				return false;
			}
			
			//invalid if capturing own piece
			if (Koma(getKomaAt(mv.to)) && Koma(getKomaAt(mv.to)).ownerPlayer == mv.turn) {
				return false;
			}
			return true;
		}
		
		public function canPromote(from:Point,to:Point):Boolean {
      to = translateHumanCoordinates(to);

			var koma:Koma; 
      trace(from.x.toString());
      if(from.x > HAND){
        koma = new Koma(from.x-HAND,from.x,from.y,_turn);
      } else {
        from = translateHumanCoordinates(from);
        koma = getKomaAt(from); 
      }

			if(koma.isPromoted() || from.x > HAND){
				return false;
			}
			
			if (koma.type == Koma.OU || koma.type == Koma.KI) {
				return false;
			}

			if(koma.ownerPlayer == SENTE){
				if(from.y <= 2 || to.y <= 2){
					return true;
				}
			} else {
				if(from.y >= 6 || to.y >= 6){
					return true;
				}
			}
			return false;
		}

    public function translateHumanCoordinates(p:Point):Point{
      return new Point(9-p.x,p.y-1);
    }

    public function generateMovementFromCoordinates(from:Point,to:Point,promote:Boolean=false):Movement{
      var koma:Koma;
      if(from.x > HAND){
        koma = new Koma(from.x-HAND,from.x,from.y,_turn);
      } else {
        from = translateHumanCoordinates(from);
        koma = getKomaAt(from);
      }
      if(promote){
        koma.promote();
      }
      to = translateHumanCoordinates(to);
      var capture:Boolean = getKomaAt(to) != null

      return new Movement(_turn,from,to,koma,false,capture);
    }

    public function generateMovementFromString(moveStr:String):Movement{
      var turn:int = moveStr.charAt(0) == "+" ? 0 : 1;
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
      return new Movement(turn,from,to,koma,false,capture);
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
	}
}
