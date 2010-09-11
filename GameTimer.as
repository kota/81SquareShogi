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
		
		public static var soundType:int = 1;
		
		[Embed(source = "/sound/timer.mp3")]
		private static var sound_timer:Class;
		private static var _sound_timer:Sound = new sound_timer();
		[Embed(source = "/sound/jp_voice/01.mp3")]
		private static var Voice01:Class;
		private static var _voice01:Sound = new Voice01();
		[Embed(source = "/sound/jp_voice/02.mp3")]
		private static var Voice02:Class;
		private static var _voice02:Sound = new Voice02();
		[Embed(source = "/sound/jp_voice/03.mp3")]
		private static var Voice03:Class;
		private static var _voice03:Sound = new Voice03();
		[Embed(source = "/sound/jp_voice/04.mp3")]
		private static var Voice04:Class;
		private static var _voice04:Sound = new Voice04();
		[Embed(source = "/sound/jp_voice/05.mp3")]
		private static var Voice05:Class;
		private static var _voice05:Sound = new Voice05();
		[Embed(source = "/sound/jp_voice/06.mp3")]
		private static var Voice06:Class;
		private static var _voice06:Sound = new Voice06();
		[Embed(source = "/sound/jp_voice/07.mp3")]
		private static var Voice07:Class;
		private static var _voice07:Sound = new Voice07();
		[Embed(source = "/sound/jp_voice/08.mp3")]
		private static var Voice08:Class;
		private static var _voice08:Sound = new Voice08();
		[Embed(source = "/sound/jp_voice/09.mp3")]
		private static var Voice09:Class;
		private static var _voice09:Sound = new Voice09();
		[Embed(source = "/sound/jp_voice/10.mp3")]
		private static var Voice10:Class;
		private static var _voice10:Sound = new Voice10();
		[Embed(source = "/sound/jp_voice/20.mp3")]
		private static var Voice20:Class;
		private static var _voice20:Sound = new Voice20();
		[Embed(source = "/sound/jp_voice/30.mp3")]
		private static var Voice30:Class;
		private static var _voice30:Sound = new Voice30();
		[Embed(source = "/sound/jp_voice/40.mp3")]
		private static var Voice40:Class;
		private static var _voice40:Sound = new Voice40();
		[Embed(source = "/sound/jp_voice/50.mp3")]
		private static var Voice50:Class;
		private static var _voice50:Sound = new Voice50();
		[Embed(source = "/sound/jp_voice/byoyomi.mp3")]
		private static var VoiceByoyomi:Class;
		private static var _voiceByoyomi:Sound = new VoiceByoyomi();
		private static var _voices:Array;

		public function GameTimer() {
			this.width = 85;
			this.horizontalScrollPolicy = "no";
			this.setStyle('borderStyle','solid');
			this.setStyle('borderColor',0x000000);
			this.setStyle('textAlign','center');
			this.setStyle('backgroundColor',0xffffff);
			_label = new Label();
			_label.setStyle('textAlign','center');
			_label.setStyle('fontSize',18);
			_label.setStyle('fontWeight', 'bold');
			_label.x = 0;
			_label.width = 85;
			addChild(_label);
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, _tickHandler);
			_voices = new Array(null,_voice01, _voice02, _voice03, _voice04, _voice05, _voice06, _voice07, _voice08, _voice09,_voice10,_voice20,_voice30,_voice40,_voice50);
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
			if (_byoyomi_flag) {
				if (_byoyomi <= 10) this.setStyle('backgroundColor',0xFF5500);
					else this.setStyle('backgroundColor',0xFFFF00);
			}
			else this.setStyle('backgroundColor',0xFFFFFF);
			_display();
		}

		public function suspend():void{
			if(_timer.running){
				_timer.stop();
				if (_byoyomi_flag) {
					if (_byoyomi <= 10) this.setStyle('backgroundColor',0xFF5500);
					else this.setStyle('backgroundColor',0xFFFF00);
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
			} else {
				_byoyomi_flag = true;
				this.setStyle('backgroundColor',0xFFFF00);
				_time_left = _byoyomi;
				_display();
			}
		}

		public function timeout():void{
			_time_left = 0;
			_display();
		}

		private function _tickHandler(e:TimerEvent):void{
			//if(_timeout_flag){
				//dispatchEvent(new Event(CHECK_TIMEOUT));
			//}
			_time_left--;
			if(_time_left <= 0){
				_time_left = 0;
				if(_byoyomi > 0 && !_byoyomi_flag){
					_byoyomi_flag = true;
					this.setStyle('backgroundColor',0xFFFF00);
					_time_left = _byoyomi;
					if (soundType == 1) {
						_sound_timer.play();
					} else if (soundType == 2) {
						_voiceByoyomi.play();
					}
				} else {
          //time's up
					_timeout_flag = true;
					this.setStyle('backgroundColor',0xFF0000);
					dispatchEvent(new Event(CHECK_TIMEOUT));
					//_timer.stop();
				}
			} else if (_byoyomi_flag) {
				if (_time_left % 10 == 0) {
					if (soundType == 2) {
						_voices[9 + int((_byoyomi - _time_left)/10)].play();
					}
				}
				if(_time_left == 10){
					this.setStyle('backgroundColor', 0xFF5500);
					if (soundType == 1) _sound_timer.play();
				}
				if (_time_left <= 9 && _time_left >= 1) {
					if (soundType == 1 && _time_left <= 5) {
						_sound_timer.play();
					} else if (soundType == 2) {
						_voices[10 - _time_left].play();
					}
				}
			}
			_display();
		}

		private function _display():void{
			var time:String = "";
			var sec:int = _time_left % 60;
			time = int(_time_left / 60).toString() + ":" + (sec < 10 ? '0' : '') + sec.toString();
			_label.text = time;
		}
		
	}
}
