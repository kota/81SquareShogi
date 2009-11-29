/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import mx.controls.Image;
	
	public class Koma {
		
		public static const KOMA_WIDTH:int = 43;
		public static const KOMA_HEIGHT:int = 48;
		
		public static const OU:int = 0;
		public static const HI:int = 1;
		public static const KA:int = 2;
		public static const KI:int = 3;
		public static const GI:int = 4;
		public static const KE:int = 5;
		public static const KY:int = 6;
		public static const FU:int = 7;
		public static const NARI:int = 8;
		
		private var _ownerPlayer:int;
		private var _type:int;
		private var _x:int;
		private var _y:int;
		private var _images:Array;
		private var _nari:int;
		private var _id:int;
		
		public function Koma(type:int = 0, x:int = 0, y:int = 0, ownerPlayer:int = 0,id:int=0) {
			this._type = type;
			this._x = x;
			this._y = y;
			this._ownerPlayer = ownerPlayer;
			this._nari = 0;
			this._id = id;
			/*
			this.width = KOMA_WIDTH;
			this.height = KOMA_HEIGHT;
			*/
			//this.source = images[_ownerPlayer + _nari * 2];
		}
		
		public function set ownerPlayer(v:int):void {
			this._ownerPlayer = v;
		}
		
		public function get ownerPlayer():int {
			return this._ownerPlayer;
		}
		
		public function set type(v:int):void {
			this._type = v;
		}
		
		public function get type():int {
			return this._type;
		}
		
		public function set x(v:int):void {
			this._x = v;
		}
		
		public function get x():int {
			return this._x;
		}
		
		public function set y(v:int):void {
			this._y = v;
		}
		
		public function get y():int {
			return this._y;
		}
		
		public function set nari(v:int):void {
			this._nari = v;
		}
		
		public function get nari():int {
			return this._nari;
		}
		
		public function set id(v:int):void {
			this._id = v;
		}
		
		public function get id():int {
			return this._id;
		}


		public function isPromoted():Boolean {
		  if(this._nari == 1){
		    return true;
		  }
		  return false;
		}

		public function promote():void {
			this._nari = 1;
			//updateImage();
		}
			
		public function depromote():void {
			this._nari = 0;
			//updateImage();
		}
	}
	
}
