package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	import flash.display.Sprite;
	import flash.display.JointStyle;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.utils.Timer;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	public class BoardArrow extends UIComponent {
		private var _fromType:int;
		private var _from:Point;
		private var _to:Point;
		private var _color:uint;
		private var _sender:String;
		private var _sprite:Sprite = new Sprite();
		private var _nameTag:TextField = new TextField();
		private var _nameTagHoldTimer:Timer = new Timer(1500, 1);
		private var _nameTagFadeTimer:Timer = new Timer(100, 10);
		private var _isDrawn:Boolean = false;
		
		public static const FROM_BOARD:int = -1;
		public static const FROM_HAND_SENTE:int = 0;
		public static const FROM_HAND_GOTE:int = 1;
		
		private static const HEAD_LENGTH:Number = 16; // 13;
		private static const HEAD_ANGLE:Number = Math.PI / 6; //7;
		private static const OFFSET:Number = 3;
		
		public function BoardArrow(fromType:int, from:Point, to:Point, color:uint, sender:String) {
			_fromType = fromType;
			_from = new Point(from.x, from.y);
			_to = new Point(to.x, to.y);
			_color = color;
			_sender = sender;
			_nameTag.htmlText = "<b>" + _sender + "</b>";
			_nameTagHoldTimer.addEventListener(TimerEvent.TIMER, _handleTimerHold);
			_nameTagFadeTimer.addEventListener(TimerEvent.TIMER, _handleTimerFade);
			_nameTagFadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleTimerFadeComplete);
			this.addChild(_sprite);
		}
		
		public function drawArrow(myTurn:int):void {
			_sprite.graphics.clear();
			_sprite.graphics.lineStyle(1, _color,1,true,"normal",null,JointStyle.MITER);
			var from:Point = new Point();
			var to:Point = new Point();
			if (_fromType == FROM_BOARD) {
				from = _squareCenterCoord(_from, myTurn);
			} else {
				if (myTurn == _fromType) {
					from = new Point(Board.MY_HAND_X + _from.x, Board.MY_HAND_Y + _from.y);
				} else {
					from = new Point(Board.HIS_HAND_X + _from.x, Board.HIS_HAND_Y + _from.y);
				}
			}
			to = _squareCenterCoord(_to, myTurn);
			var theta:Number = Math.atan2(from.y - to.y, from.x - to.x);
			from = new Point(from.x - OFFSET * Math.cos(theta), from.y - OFFSET * Math.sin(theta));
			to = new Point(to.x + OFFSET * Math.cos(theta), to.y + OFFSET * Math.sin(theta));
			_sprite.graphics.moveTo(from.x, from.y);
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH / 2 * Math.cos(theta + HEAD_ANGLE * 0.4), to.y + HEAD_LENGTH / 2 * Math.sin(theta + HEAD_ANGLE * 0.4))
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta + HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta + HEAD_ANGLE))
			_sprite.graphics.lineStyle(1.5, _color,0.8,true,"normal",null,JointStyle.MITER);
			_sprite.graphics.lineTo(to.x, to.y);
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta - HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta - HEAD_ANGLE))
			_sprite.graphics.lineStyle(1, _color,1,true,"normal",null,JointStyle.MITER);
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH / 2 * Math.cos(theta - HEAD_ANGLE * 0.4), to.y + HEAD_LENGTH / 2 * Math.sin(theta - HEAD_ANGLE * 0.4))
			_sprite.graphics.lineTo(from.x, from.y);
//			_sprite.graphics.lineTo(to.x, to.y);
//			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta + HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta + HEAD_ANGLE))
//			_sprite.graphics.moveTo(to.x, to.y);
//			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta - HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta - HEAD_ANGLE))
			_nameTag.alpha = 1.0;
//			_nameTag.antiAliasType = AntiAliasType.ADVANCED;
			_nameTag.x = to.x + 10;
			_nameTag.y = to.y - 16;
			_nameTag.textColor = _color;
			_nameTag.autoSize = "left";
			_nameTag.selectable = false;
			_sprite.addChild(_nameTag);
			_isDrawn = true;
			_nameTagHoldTimer.start();
		}
		
		public function erase():void {
			_nameTagFadeTimer.reset();
			_nameTagHoldTimer.reset();
			if (_sprite.contains(_nameTag)) _sprite.removeChild(_nameTag);
			_sprite.graphics.clear();
			_isDrawn = false;
		}
		
		private function _handleTimerHold(e:TimerEvent):void {
			_nameTagHoldTimer.reset();
			_nameTagFadeTimer.start();
		}
		
		private function _handleTimerFade(e:TimerEvent):void {
			_nameTag.alpha -= 0.1;
		}
		
		private function _handleTimerFadeComplete(e:TimerEvent):void {
			_nameTagFadeTimer.reset();
			_sprite.removeChild(_nameTag);
		}
		
		private function _squareCenterCoord(p:Point, myTurn:int):Point {
			var i:int;
			var j:int;
			if (myTurn == Kyokumen.SENTE) {
				i = 9 - p.x;
				j = p.y - 1;
			} else {
				i = p.x - 7;
				j = 4 - p.y;
			}
			return new Point(Board.BAN_LEFT_MARGIN + Board.BAN_EDGE_PADDING + (i + 0.5) * Board.KOMA_WIDTH,
								   Board.BAN_TOP_MARGIN + Board.BAN_EDGE_PADDING + (j + 0.5) * Board.KOMA_HEIGHT);
		}
		
		public function get sender():String {
			return this._sender;
		}
		
		public function get isDrawn():Boolean {
			return this._isDrawn;
		}
		
	}
	
}