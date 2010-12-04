﻿package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
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
		private var _nameTagTimer:Timer = new Timer(2000);
		
		public static const FROM_BOARD:int = -1;
		public static const FROM_HAND_SENTE:int = 0;
		public static const FROM_HAND_GOTE:int = 1;
		
		private static const HEAD_LENGTH:Number = 13;
		private static const HEAD_ANGLE:Number = Math.PI / 7;
		private static const OFFSET:Number = 5;
		
		public function BoardArrow(fromType:int, from:Point, to:Point, color:uint, sender:String) {
			_fromType = fromType;
			_from = from;
			_to = to;
			_color = color;
			_sender = sender;
			_nameTag.text = _sender;
			_nameTagTimer.addEventListener(TimerEvent.TIMER, _handleTimer);
			this.addChild(_sprite);
		}
		
		public function drawArrow(myTurn:int):void {
			_sprite.graphics.clear();
			_sprite.graphics.lineStyle(2, _color);
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
			_sprite.graphics.lineTo(to.x, to.y);
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta + HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta + HEAD_ANGLE))
			_sprite.graphics.moveTo(to.x, to.y);
			_sprite.graphics.lineTo(to.x + HEAD_LENGTH * Math.cos(theta - HEAD_ANGLE), to.y + HEAD_LENGTH * Math.sin(theta - HEAD_ANGLE))
			_nameTag.x = to.x + 10;
			_nameTag.y = to.y - 15;
			_nameTag.textColor = _color;
			_nameTag.autoSize = "left";
			_nameTag.selectable = false;
			_sprite.addChild(_nameTag);
			_nameTagTimer.start();
		}
		
		private function _handleTimer(e:TimerEvent):void {
			_nameTagTimer.stop();
			_sprite.removeChild(_nameTag);
		}
		
		private function _squareCenterCoord(p:Point, myTurn:int):Point {
			var i:int;
			var j:int;
			if (myTurn == Kyokumen.SENTE) {
				i = 9 - p.x;
				j = p.y - 1;
			} else {
				i = p.x - 1;
				j = 9 - p.y;
			}
			return new Point(Board.BAN_LEFT_MARGIN + Board.BAN_EDGE_PADDING + (i + 0.5) * Board.KOMA_WIDTH,
								   Board.BAN_TOP_MARGIN + Board.BAN_EDGE_PADDING + (j + 0.5) * Board.KOMA_HEIGHT);
		}
	}
	
}