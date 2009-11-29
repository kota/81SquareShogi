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

		private var _komas:Array;
		private var _teban:int;
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

    private static const HAND:int = 99;

		public function Kyokumen():void {
			this._komas = new Array(40);
			this._teban = SENTE;
			this._ban = new Array(9);
			for (var i:int; i < 9; i++ ) {
				_ban[i] = new Array(9);
			}
			_komadai = new Array(2);
			_komadai[0] = new Komadai();
			_komadai[1] = new Komadai();

			//_makeInitialPosition();
      loadFromString(initialPositionStr());
		}

    public function loadFromString(position_str:String):void{
      var lines:Array = position_str.split("\n");
      var id:int = 0;
      for(var y:int=0;y<9;y++){
        var line:String = lines[y].substr(2);
        for(var x:int=0;x<9;x++){
          var koma_str:String = line.slice(x*3,x*3+3)
          trace("koma str:" + koma_str + ", " + koma_str.slice(1,3));
          if(koma_str != " * "){
            var owner:int = koma_str.charAt(0) == '+' ? SENTE : GOTE 
            var koma:Koma = new Koma(koma_names.indexOf(koma_str.slice(1,3)),x,y,owner,id);
            id++;
            _ban[x][y] = koma;
          } else {
            trace("set to null");
            _ban[x][y] = null;
          }
        }
      }
    }
		
		public function get komas():Array{
			return this._komas;
		}
		
		public function get ban():Array{
			return this._ban;
		}

		public function get teban():int {
			return this._teban;
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
		
		public function canPromote(mv:Movement):Boolean {
			var koma:Koma = _ban[mv.from.x - 1][mv.from.y - 1]; 
			if(koma.isPromoted()){
				return false;
			}

			if(mv.from.x == 0){
				return false;
			}
			
			if (koma.type == Koma.OU || koma.type == Koma.KI) {
				return false;
			}

			if(koma.ownerPlayer == SENTE){
				if(mv.from.y <= 3 || mv.to.y <= 3){
					return true;
				}
			} else {
				if(mv.from.y >= 7 || mv.to.y >= 7){
					return true;
				}
			}
			return false;
		}

    public function translateHumanCoordinates(p:Point):Point{
      return new Point(9-p.x,p.y-1);
    }

    public function generateMovementFromCoordinates(from:Point,to:Point):Movement{
      from = translateHumanCoordinates(from);
      to = translateHumanCoordinates(to);
      var koma:Koma = getKomaAt(from);
      var capture:Boolean = getKomaAt(to) != null

      return new Movement(_teban,from,to,koma,false,capture);
    }

    public function generateMovementFromString(moveStr:String):Movement{
      var turn:int = moveStr.charAt(0) == "+" ? 0 : 1;
      var from:Point = new Point(parseInt(moveStr.charAt(1)),parseInt(moveStr.charAt(2)));
      from = translateHumanCoordinates(from);
      var to:Point = new Point(parseInt(moveStr.charAt(3)),parseInt(moveStr.charAt(4)));
      to = translateHumanCoordinates(to);
      var capture:Boolean = getKomaAt(to) != null
      var koma:Koma = new Koma(koma_names.indexOf(moveStr.slice(5,7)),to.x,to.y,turn);
      return new Movement(turn,from,to,koma,false,capture);
    }
		
		public function move(from:Point,to:Point):void {
			var koma:Koma = getKomaAt(from); 
			//drop
			if(from.x == HAND){
				_komadai[koma.ownerPlayer].removeKoma(koma);
			}
			//put piece into hand if capturing.
			if (getKomaAt(to) != null) {
				if(from.x == HAND){
					return; //illegal
				} else {
					var captured_koma:Koma = getKomaAt(to);
					_captureKoma(captured_koma,_teban);
				}
			}
			//move piece
			if(from.x != HAND){
				//_ban[mv.from.x - 1][mv.from.y - 1] = null;
        setKomaAt(from,null);
			}
			koma.x = to.x;
			koma.y = to.y;
      //TODO handle promotion
      /*
			if(promote){
				koma.promote();
			}
      */
			setKomaAt(to,koma);
			komas[koma.id] = koma;
			_teban = _teban == SENTE ? GOTE : SENTE;
		}

		private function _captureKoma(koma:Koma,teban:int):void {
      setKomaAt(new Point(koma.x,koma.y),null);
			var new_owner:int = teban;
			_komadai[new_owner].addKoma(koma);
			koma.ownerPlayer = new_owner;
			koma.x = HAND;
			koma.y = HAND;
			if (koma.isPromoted()) {
				koma.depromote();
			}
			komas[koma.id] = koma;
		}
	}
}
