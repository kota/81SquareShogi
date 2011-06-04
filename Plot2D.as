package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	import flash.display.Sprite;
	import flash.display.JointStyle;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.utils.Timer;
	import mx.controls.Text;
	import mx.controls.ToolTip;
	import mx.core.UIComponent;
	
	public class Plot2D extends UIComponent {
		private var _xmin:Number;
		private var _xmax:Number;
		private var _ymin:Number;
		private var _ymax:Number;
		private var _points:Array;
		private var _margin:Number = 0.05;
		private var _label:TextField = new TextField();
		
		private var _lineSprite:Sprite = new Sprite();
		
		public function Plot2D() {
			addChild(_lineSprite);
		}
		
		public function loadData(points:Array):void {
			_points = points;
			_xmin = 1e10;
			_xmax = -1e10;
			_ymin = _xmin;
			_ymax = _xmax;
			for each (var p:Point in _points) {
				if (p.x < _xmin) _xmin = p.x;
				if (p.x > _xmax) _xmax = p.x;
				if (p.y < _ymin) _ymin = p.y;
				if (p.y > _ymax) _ymax = p.y;
			}
			var tmp:Number = _xmax == _xmin ? 2 * Math.max(Math.abs(_xmax), 1) : _xmax - _xmin;
			_xmax += 0.05 * tmp;
			_xmin -= 0.05 * tmp;
			tmp = _ymax == _ymin ? 2 * Math.max(Math.abs(_ymax), 1) : _ymax - _ymin;
			_ymax += 0.1 * tmp;
			_ymin -= 0.1 * tmp;

			_lineSprite.graphics.clear();
			_lineSprite.graphics.lineStyle(1, 0x000000, 1, true, "normal", null, JointStyle.MITER);
			_lineSprite.graphics.moveTo(width * 2*_margin, height * _margin);
			_lineSprite.graphics.lineTo(width * 2*_margin, height * (1 - _margin));
			_lineSprite.graphics.lineTo(width * (1 - _margin), height * (1 - _margin));
			
			var tick:int;
			if (_ymax - _ymin > 300) tick = 100;
			else if (_ymax - _ymin > 120) tick = 50;
			else if (_ymax - _ymin > 60) tick = 20;
			else if (_ymax - _ymin > 30) tick = 10;
			else if (_ymax - _ymin > 12) tick = 5;
			else if (_ymax - _ymin > 6) tick = 2;
			else tick = 1;
			for (var i:int = int(_ymin) - 1; i < _ymax; i++) {
				if (i > _ymin && i % tick == 0) break;
			}
			_lineSprite.graphics.lineStyle(1, 0x000000, 0.2, true, "normal", null, JointStyle.MITER);
			while (i < _ymax) {
				var pt:Point = _trans(new Point(_xmin, i));
				_lineSprite.graphics.moveTo(pt.x, pt.y);
				_lineSprite.graphics.lineTo(width * (1 - _margin), pt.y);
				var tickLabel:TextField = new TextField();
				tickLabel.autoSize = "right";
				tickLabel.defaultTextFormat = new TextFormat("Meiryo UI", 11, 0x000000, true);
				tickLabel.selectable = false;
				tickLabel.text = String(i);
				tickLabel.x = 8;
				tickLabel.y = pt.y - 11;
				_lineSprite.addChild(tickLabel);
				i += tick;
			}
			
			_lineSprite.graphics.lineStyle(1, 0xff0000, 1, true, "normal", null, JointStyle.MITER);
			
			pt = _trans(_points[0]);
			_lineSprite.graphics.moveTo(pt.x, pt.y);
			for each (p in _points) {
				pt = _trans(p);
				_lineSprite.graphics.lineTo(pt.x, pt.y);
				var pSprite:Sprite = new Sprite();
				pSprite.graphics.beginFill(0xff0000, 1);
				pSprite.graphics.drawCircle(pt.x, pt.y, 3);
				pSprite.graphics.endFill();
				pSprite.addEventListener(MouseEvent.MOUSE_OVER, _handleMouseOver);
				pSprite.addEventListener(MouseEvent.MOUSE_OUT, _handleMouseOut);
				addChild(pSprite);
			}
			_label.autoSize = "left";
			_label.defaultTextFormat = new TextFormat("Meiryo UI", 14, 0x00aa00, true);
			_label.selectable = false;
			addChild(_label);
		}
		
		private function _handleMouseOver(e:MouseEvent):void {
			_label.x = e.localX - 18;
			_label.y = e.localY - 25;
			for (var i:int = 0; i < numChildren; i++) {
				if (getChildAt(i) == e.target) {
					_label.text = String(_points[i - 1].y);
					break;
				}
			}
		}
		
		private function _handleMouseOut(e:MouseEvent):void {
			_label.text = "";
		}
		
		private function _trans(p:Point):Point {
			var x:Number = 2*_margin * width + (1 - 2 * _margin) * width * (p.x - _xmin) / (_xmax - _xmin);
			var y:Number = _margin * height + (1 - 2 * _margin) * height * (p.y - _ymax) / (_ymin - _ymax);
			return new Point(x, y);
		}
		
	}
	
}