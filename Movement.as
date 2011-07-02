/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.geom.Point;
	import mx.accessibility.AccordionHeaderAccImpl;
		
	public class Movement {
		
		public static const RESIGN:int = 1;
		public static const TIMEUP:int = 2;
		public static const SENNICHITE:int = 3;
		public static const ILLEGAL:int = 4;
		public static const OUTE_SENNICHITE:int = 5;
		public static const LIST_UNIVERSAL:int = 0;
		public static const LIST_JAPANESE:int = 1;
		public static const LIST_WESTERN:int = 2;
		private static const koma_japanese_names:Array = new Array('玉', '飛', '角', '金', '銀', '桂', '香', '歩', '', '龍', '馬', '', '成銀', '成桂', '成香', 'と');
		private static const rank_japanese_names:Array = new Array('一','二','三','四','五','六','七','八','九');
		private static const file_japanese_names:Array = new Array('１', '２', '３', '４', '５', '６', '７', '８', '９');
		private static const koma_western_names:Array = new Array('Ｋ', 'Ｒ', 'Ｂ', 'Ｇ', 'Ｓ', 'Ｎ', 'Ｌ', 'Ｐ', '', 'Ｄ', 'Ｈ', '', '+S', '+N', '+L', 'Ｔ');
//		private static const koma_western_names:Array = new Array(' K', ' R', ' B', ' G', ' S', ' N', ' L', ' P', '', ' D', ' H', '', '+S', '+N', '+L', ' T');
		private static const rank_western_names:Array = new Array('ａ', 'ｂ', 'ｃ', 'ｄ', 'ｅ', 'ｆ', 'ｇ', 'ｈ', 'ｉ');
//		private static const rank_western_names:Array = new Array('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
		private static const rank_universal_names:Array = new Array('ⅰ', 'ⅱ', 'ⅲ', 'ⅳ', 'ⅴ', 'ⅵ', 'ⅶ', 'ⅷ', 'ⅸ');
		public static var listType:int = LIST_UNIVERSAL;
		
		private var _n:int;
		private var _turn:int = 0;
		private var _from:Point = null;
		private var _to:Point = null;
		private var _last_to:Point = null;
		private var _type:int;
		private var _promote:Boolean = false;
		private var _capture:Boolean = false;
		private var _time:int = 0;
		private var _special:int = 0;
		private var _branch:Boolean = false;
		private var _comment:String = "";
		
		public function Movement(n:int = 0) {
			_n = n;
		}
		
		public function setFromKyokumen(turn:int, from:Point, to:Point, type:int, promote:Boolean, capture:Boolean = false, last_to:Point = null, time:int = 0):void {
			_turn = turn;
			_from = from;
			_to = to;
			_type = type;
			_promote = promote;
			_capture = capture;
			_last_to = last_to;
			_time = time;
		}
		
		public function setGameEnd(turn:int, special:int, time:int = 0):void {
			_turn = turn;
			_special = special;
			_time = time;
		}

		private function toHumanCoordinates(p:Point):Point{
			return new Point(9-p.x,p.y+1);
		}

		public function toCSA():String{
			var from:Point;
			if(_from.x >= Kyokumen.HAND){
				from = new Point(0,0);
			} else {
				from = toHumanCoordinates(_from);
			}
			var to:Point = toHumanCoordinates(_to);
			var buff:String = _turn == 0 ? "+" : "-"
			buff += from.x.toString() + from.y.toString() + to.x.toString() + to.y.toString();
			if (_promote) {
				buff += Kyokumen.koma_names[_type + Koma.PROMOTE];
			} else {
				buff += Kyokumen.koma_names[_type];
			}
			return buff;
		}
		
		public function get numStr():String {
			return (_branch ? "*" : "") + _n;
		}
		
		public function get toListString():String {
			if (_n == 0 || _special >= ILLEGAL) {
				var str:String = "";
			} else {
				str = _turn == 0 ? "▲" : "△";
			}
			str += (listType == LIST_JAPANESE ? toJapaneseNotation() : toWesternNotation(listType == LIST_UNIVERSAL));
			if (_n == 0 || _special >= TIMEUP) return str;
			do {
				str += "　";
			} while (str.length < (listType == LIST_JAPANESE ? 6 : 8));
			return str + "(" + _time + ")";
		}
		
		public function toWesternNotation(universal:Boolean):String {
			if (_n == 0) return "Start";
			if (_special > 0) {
				switch (_special) {
					case TIMEUP:
						return " Time-up";
					case RESIGN:
						return " Resign";
					case ILLEGAL:
						return " Illegal move";
					case SENNICHITE:
						return " Repetition Draw";
					case OUTE_SENNICHITE:
						return " Perpetual Check";
				}
			}
			var str:String = koma_western_names[_type];
			if (_from.x >= Kyokumen.HAND) {
				str += "* ";
			} else if (_capture) {
				str += "x ";
			} else {
				str += "- ";
			}
			if (_to.x != _last_to.x || _to.y != _last_to.y) {
				str += 9 - _to.x
				str += universal ? rank_universal_names[_to.y] : rank_western_names[_to.y];
			}
			if (_promote) {
				str += "+";
			} else if (_from.x != Kyokumen.HAND && _type < Koma.PROMOTE && !_promote && _type != Koma.OU && _type != Koma.KI){
				if ( (1 - _turn) * _from.y + _turn * (8 - _from.y) <= 2 || (1 - _turn) * _to.y + _turn * (8 - _to.y) <= 2 ) str += "=";
			} 
			return str;	
		}
		
		public function toJapaneseNotation():String {
			if (_n == 0) return "開始";
			if (_special > 0) {
				switch (_special) {
					case TIMEUP:
						return "切れ負け";
					case RESIGN:
						return "投了";
					case ILLEGAL:
						return "反則手";
					case SENNICHITE:
						return "千日手";
					case OUTE_SENNICHITE:
						return "連続王手の千日手";
				}
			}
			if (_to.x != _last_to.x || _to.y != _last_to.y) {
				var str:String = file_japanese_names[8 - _to.x];
				str += rank_japanese_names[_to.y];
			} else {
				str = "同　";
			}
			str += koma_japanese_names[_type];
			if (_from.x >= Kyokumen.HAND) {
				if (_type != 7) str += "打";
			} else {
				if (_promote) {
					str += "成";
				} else if (_from.x < Kyokumen.HAND && _type < Koma.PROMOTE && !_promote && _type != Koma.OU && _type != Koma.KI){
					if ( (1 - _turn) * _from.y + _turn * (8 - _from.y) <= 2 || (1 - _turn) * _to.y + _turn * (8 - _to.y) <= 2 ) str += "不成";
				} 
			}
			return str;
		}
		
		public function toKIFNotation():String{
			var str:String = toJapaneseNotation();
			if (_from && _from.x < Kyokumen.HAND) str += "(" + String(9 - _from.x) + String(_from.y + 1) + ")";
			return str + "   ( " + int(_time/60) + ":" + _time % 60 + "/)";
		}
		
		public function replayable():Boolean {
			return (!_n == 0 && _special == 0);
		}

		public function getResultKoma():Koma {
			return new Koma(_promote ? _type + Koma.PROMOTE : _type, _to.x, _to.y, _turn);
		}
		public function get from():Point {
			return this._from;
		}
		public function get to():Point {
			return this._to;
		}
		public function get type():int {
			return this._type;
		}
		public function get promote():Boolean {
			return this._promote;
		}
		public function get capture():Boolean{
			return this._capture;
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
		public function get n():int{
			return this._n;
		}
		public function set n(v:int):void{
			this._n = v;
		}
		public function get branch():Boolean{
			return this._branch;
		}
		public function set branch(v:Boolean):void{
			this._branch = v;
		}
		public function get comment():String{
			return this._comment;
		}
		public function set comment(v:String):void{
			this._comment = v;
		}

	}
	
}
