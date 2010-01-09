package {
	import mx.containers.Canvas;
	import mx.controls.Label;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;

	public class GameTimer extends Canvas{

		public static var CHECK_TIMEOUT:String = 'check_timeout';

		private var _label:Label;

		private var _total:int;
		private var _byoyomi:int;
		private var _time_left:int;

		private var _accumulated_time:int;
		private var _byoyomi_flag:Boolean;
		private var _timeout_flag:Boolean;

		private var _timer:Timer;
		
		[Embed(source = "/sound/timer.mp3")]
		private var sound_timer:Class;
		private var _sound_timer:Sound = new sound_timer();

		public function GameTimer() {
			this.width = 85;
			this.setStyle('borderStyle','solid');
			this.setStyle('borderColor',0x000000);
			this.setStyle('textAlign','center');
			this.setStyle('backgroundColor',0xffffff);
			_label = new Label();
			_label.setStyle('textAlign','right');
			_label.setStyle('fontSize',18);
			_label.setStyle('fontWeight','bold');
			_label.x = 10
			addChild(_label);
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER,_tickHandler);
		}

		public function start():void{
			if(!_timer.running){
				_timer.start();
			}
		}

		public function stop():void{
			if(_timer.running){
				_timer.stop();
			}
		}

		public function reset(total:int, byoyomi:int):void{
			_total = total;
			_byoyomi = byoyomi;
			_byoyomi_flag = _total <= 0;
			_time_left = _byoyomi_flag ? _byoyomi : _total;
			_accumulated_time = 0;
			_timeout_flag = false;
			this.setStyle('backgroundColor',0xFFFFFF);
			_display();
		}

		public function suspend():void{
			if(_timer.running){
				_timer.stop();
				if (_byoyomi_flag){
					this.setStyle('backgroundColor',0xFFFF00);
					_time_left = _byoyomi;
				}
			}
			_display();
		}

		public function resume():void{
			if(!_timer.running){
				_timer.start();
			}
			_display();
		}

		public function accumulateTime(time:int):void{
			if(_byoyomi_flag){
				return;
			}
			_accumulated_time	+= time;
			if(_accumulated_time < _total){
				trace("accumulate:"+_accumulated_time.toString());
				_time_left = _total - _accumulated_time;
			}
		}

		public function timeout():void{
			_time_left = 0;
			_display();
		}

		private function _tickHandler(e:TimerEvent):void{
			if(_timeout_flag){
				dispatchEvent(new Event(CHECK_TIMEOUT));
			}
			_time_left--;
			if(_time_left <= 0){
				_time_left = 0;
				if(_byoyomi > 0 && !_byoyomi_flag){
					_byoyomi_flag = true;
					this.setStyle('backgroundColor',0xFFFF00);
					_time_left = _byoyomi;
					_sound_timer.play();
				} else {
          //time's up
					_timeout_flag = true;
					//_timer.stop();
				}
			}
			if(_byoyomi_flag && _time_left == 10){
				this.setStyle('backgroundColor',0xFF0000);
				_sound_timer.play();
			}
			if(_byoyomi_flag && _time_left <= 5 && _time_left >= 1){
				_sound_timer.play();
			}
			_display();
		}

		private function _display():void{
			var time:String = "";
			var sec:int = _time_left % 60;
			time = int(_time_left / 60).toString() + ":" + (sec < 10 ? '0' : '') + sec.toString();
			/*if(_time_left > 60){
				time = int(_time_left / 60).toString() + ":" + (_time_left % 60).toString();
			} else {
				time = _time_left.toString();
			}*/
			_label.text = time;
		}

	}
}
