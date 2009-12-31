/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.geom.Point;
	import Koma;
		
	public class Movement {
		
		private var _turn:int;
		private var _from:Point;
		private var _to:Point;
		private var _koma:Koma;
		private var _promote:Boolean;
		private var _capture:Boolean;
		private var _time:int;
		
		public function Movement(turn:int, from:Point, to:Point, koma:Koma, promote:Boolean, capture:Boolean, time:int=0 ) {
			_turn = turn;
			_from = from;
			_to = to;
			_koma = koma;
			_promote = promote;
			_capture = capture;
			_time = time;
		}

    private function toHumanCoordinates(p:Point):Point{
      return new Point(9-p.x,p.y+1);
    }

    public function toCSA():String{
      var from:Point;
      if(_from.x > Kyokumen.HAND){
        from = new Point(0,0);
      } else {
        from = toHumanCoordinates(_from);
      }
      var to:Point = toHumanCoordinates(_to);
      var buff:String = _turn == 0 ? "+" : "-"
      buff += from.x.toString() + from.y.toString() + to.x.toString() + to.y.toString();
      buff += Kyokumen.koma_names[_koma.type];
      return buff;
    }
		
		public function get from():Point {
			return this._from;
		}
		
		public function get to():Point {
			return this._to;
		}
		public function get koma():Koma {
			return this._koma;
		}
		public function get promote():Boolean {
			return this._promote;
		}
		public function set promote(v:Boolean):void {
			this._promote = v;
		}
		public function get turn():int {
			return this._turn;
		}
		public function get time():int {
			return this._time;
		}

	}
	
}
