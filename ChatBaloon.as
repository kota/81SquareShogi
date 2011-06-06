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
	import mx.controls.TextArea;
	
	public class ChatBaloon extends TextArea {

		private static const FRAMES:int = 30;
		private var _holdTimer:Timer = new Timer(5000, 1);
		private var _fadeTimer:Timer = new Timer(50, FRAMES);
		
		public function ChatBaloon() {
			this.setStyle('focusRoundedCorners', "tl tr bl br");
			this.setStyle('cornerRadius', 15);
			this.alpha = 0;
			this.verticalScrollPolicy = "off";
			this.setStyle('paddingLeft', 10);
			this.setStyle('paddingRight', 10);
			this.setStyle('paddingBottom', 10);
			this.setStyle('borderThicknes', 2);
			this.setStyle('dropShadowEnabled', true);
			this.setStyle('backgroundColor', 0xffffee);
			this.selectable = false;
			this.editable = false;
			this.setStyle('fontFamily', 'Meiryo UI');
			this.setStyle('leading', 3);
			_holdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleHoldTimer);
			_fadeTimer.addEventListener(TimerEvent.TIMER, _handleFadeTimer);
		}
		
		public function update(message:String, face:Boolean):void {
			if (face) {
				setStyle('fontSize', 23);
				setStyle('textAlign', 'center');
				setStyle('paddingTop', 20);
			} else {
				setStyle('fontSize', 13);
				setStyle('textAlign', 'left');
				this.setStyle('paddingTop', 10);
			}
			text = message;
			alpha = 1.0;
			_fadeTimer.reset();
			_holdTimer.reset();
			_holdTimer.start();
		}
		
		private function _handleHoldTimer(e:TimerEvent):void {
			_fadeTimer.start();
		}
		
		private function _handleFadeTimer(e:TimerEvent):void {
			alpha -= 1 / FRAMES;
		}
		
		public function hide():void {
			_holdTimer.stop();
			_fadeTimer.stop();
			alpha = 0;
		}
		
	}
	
}