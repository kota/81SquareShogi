package {
	import flash.display.Graphics;
	import flash.display.Shape;
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;

	public class GameTimer extends Canvas{

		public static var CHECK_TIMEOUT:String = 'check_timeout';
		public static var TIMER_LAG:String = 'timer_lag';

		private var _label:Label;
		private var _box:Canvas;
		private var _arrows:Image;
		private var _total:int;
		private var _byoyomi:int;
		private var _time_left:int;

		private var _accumulated_time:int;
		private var _byoyomi_flag:Boolean;
		private var _timeout_flag:Boolean;

		private var _timer:Timer;
		private var _startTime:Number;
		private var _thisCount:int;
		private var _lagging:Boolean;
		
		public static var soundType:int = 1;

		[Embed(source = "/images/timer_arrows.png")]
		private static var arrows:Class;
		[Embed(source = "/sound/timer.mp3")]
		private static var sound_timer:Class;
		private static var _sound_timer:Sound = new sound_timer();
		[Embed(source = "/sound/madoka_kitao/01.mp3")]
		private static var Voice01:Class;
		private static var _voice01:Sound = new Voice01();
		[Embed(source = "/sound/madoka_kitao/02.mp3")]
		private static var Voice02:Class;
		private static var _voice02:Sound = new Voice02();
		[Embed(source = "/sound/madoka_kitao/03.mp3")]
		private static var Voice03:Class;
		private static var _voice03:Sound = new Voice03();
		[Embed(source = "/sound/madoka_kitao/04.mp3")]
		private static var Voice04:Class;
		private static var _voice04:Sound = new Voice04();
		[Embed(source = "/sound/madoka_kitao/05.mp3")]
		private static var Voice05:Class;
		private static var _voice05:Sound = new Voice05();
		[Embed(source = "/sound/madoka_kitao/06.mp3")]
		private static var Voice06:Class;
		private static var _voice06:Sound = new Voice06();
		[Embed(source = "/sound/madoka_kitao/07.mp3")]
		private static var Voice07:Class;
		private static var _voice07:Sound = new Voice07();
		[Embed(source = "/sound/madoka_kitao/08.mp3")]
		private static var Voice08:Class;
		private static var _voice08:Sound = new Voice08();
		[Embed(source = "/sound/madoka_kitao/09.mp3")]
		private static var Voice09:Class;
		private static var _voice09:Sound = new Voice09();
		[Embed(source = "/sound/madoka_kitao/10.mp3")]
		private static var Voice10:Class;
		private static var _voice10:Sound = new Voice10();
		[Embed(source = "/sound/madoka_kitao/20.mp3")]
		private static var Voice20:Class;
		private static var _voice20:Sound = new Voice20();
		[Embed(source = "/sound/madoka_kitao/30.mp3")]
		private static var Voice30:Class;
		private static var _voice30:Sound = new Voice30();
		[Embed(source = "/sound/madoka_kitao/40.mp3")]
		private static var Voice40:Class;
		private static var _voice40:Sound = new Voice40();
		[Embed(source = "/sound/madoka_kitao/50.mp3")]
		private static var Voice50:Class;
		private static var _voice50:Sound = new Voice50();
		[Embed(source = "/sound/madoka_kitao/byoyomi.mp3")]
		private static var VoiceByoyomi:Class;
		private static var _voiceByoyomi:Sound = new VoiceByoyomi();
		private static var _voices:Array;

		public function GameTimer() {
			this.width = 100;
			this.horizontalScrollPolicy = "no";
			_box = new Canvas();
			_box.x = 7
			_box.width = 85;
			_box.horizontalScrollPolicy = "no";
			_box.setStyle('borderStyle','solid');
			_box.setStyle('borderColor',0x000000);
			_box.setStyle('textAlign','center');
			_box.setStyle('backgroundColor', 0xffffff);
			_label = new Label();
			_label.setStyle('textAlign','center');
			_label.setStyle('fontSize',18);
			_label.setStyle('fontWeight', 'bold');
			_label.x = 0;
			_label.width = 85;
			_box.addChild(_label);
			addChild(_box);
			_arrows = new Image();
			_arrows.source = arrows;
			_arrows.y = 2
			addChild(_arrows);
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, _tickHandler);
			_voices = new Array(null,_voice01, _voice02, _voice03, _voice04, _voice05, _voice06, _voice07, _voice08, _voice09,_voice10,_voice20,_voice30,_voice40,_voice50);
		}

		public function start():void{
			if(!_timer.running){
				_timer.start();
				_arrows.visible = true;
				_lagging = false;
				_thisCount = 0;
				_startTime = Number(new Date());
			}
		}

		public function stop():void{
			if(_timer.running){
				_timer.stop();
				_arrows.visible = false;
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
				if (_byoyomi <= 10) _box.setStyle('backgroundColor',0xFF5500);
					else _box.setStyle('backgroundColor',0xFFFF00);
			}
			else _box.setStyle('backgroundColor', 0xFFFFFF);
			_arrows.visible = false;
			_display();
		}

		public function suspend():void{
			if(_timer.running){
				_timer.stop();
				if (_byoyomi_flag) {
					if (_byoyomi <= 10) _box.setStyle('backgroundColor',0xFF5500);
					else _box.setStyle('backgroundColor',0xFFFF00);
					_time_left = _byoyomi;
				}
			}
			_arrows.visible = false;
			_display();
		}

		public function resume():void{
			if(!_timer.running){
				_timer.start();
				_lagging = false;
				_thisCount = 0;
				_startTime = Number(new Date());
			}
			_arrows.visible = true;
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
				_box.setStyle('backgroundColor',0xFFFF00);
				_time_left = _byoyomi;
			}
			_display();
		}

		public function timeout():void{
			_time_left = 0;
			_box.setStyle('backgroundColor', 0xFF0000);
			_display();
		}

		private function _tickHandler(e:TimerEvent):void {
			_time_left--;
			if (++_thisCount % 5 == 0 && _time_left <= 60) {
				if (!_lagging && Number(new Date()) - _startTime > (_thisCount + 5) * 1000) {
					dispatchEvent(new Event(TIMER_LAG));
					_lagging = true;
				}
			}
			if(_time_left <= 0){
//				_time_left = 0;
				if(_byoyomi > 0 && !_byoyomi_flag){
					_byoyomi_flag = true;
					_box.setStyle('backgroundColor',0xFFFF00);
					_time_left = _byoyomi;
					if (soundType == 1) {
						_sound_timer.play();
					} else if (soundType == 2 && _byoyomi > 10) {
						_voiceByoyomi.play();
					}
				} else {
          //time's up
					_timeout_flag = true;
					_box.setStyle('backgroundColor',0xFF0000);
					dispatchEvent(new Event(CHECK_TIMEOUT));
					//_timer.stop();
				}
			} else if (_byoyomi_flag) {
				if (soundType == 1) {
					if ((_time_left >= 1 && _time_left <= 5) || _time_left == 7 || _time_left == 9) _sound_timer.play();
				} else if (soundType == 2) {
					if (_time_left == 10 || _time_left == 20 || _time_left == 30) _voices[9 + int((_byoyomi - _time_left) / 10)].play();
					else if (_time_left >= 1 && _time_left <= 9) _voices[10 - _time_left].play();
				}
				if (_time_left == 9) _box.setStyle('backgroundColor', 0xFF5500);
			}
			_display();
		}

		private function _display():void{
			var time:String = "";
			var sec:int = _time_left % 60;
			if (_time_left <= -3) {
				_label.text = "Delay";
			} else if (_time_left < 0) {
				_label.text = "0:00";
			} else {
				time = int(_time_left / 60).toString() + ":" + (sec < 10 ? '0' : '') + sec.toString();
				_label.text = time;
			}
		}
		
	}
}
