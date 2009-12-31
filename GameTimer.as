package {
	import mx.controls.Label;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class GameTimer extends Label {
		private var _total:int;
		private var _byoyomi:int;
		private var _time_left:int;

		private var _accumulated_time:int;
		private var _byoyomi_flag:Boolean;

		private var _timer:Timer;

		public function GameTimer() {
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

			_display();
		}

		public function suspend():void{
			if(_timer.running){
				_timer.stop();
			}
		}

		public function resume():void{
			if(!_timer.running){
				_timer.start();
			}
			if(_byoyomi_flag){
				_time_left = _byoyomi;
			}
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

		private function _tickHandler(e:TimerEvent):void{
			_time_left--;
			if(_time_left <= 0){
				if(!_byoyomi_flag){
					_byoyomi_flag = true;
					_time_left = _byoyomi;
				} else {
					_timer.stop();
				}
			}
			_display();
		}

		private function _display():void{
			var time:String = "";
			if(_time_left > 60){
				time = int(_time_left / 60).toString() + ":" + (_time_left % 60).toString();
			} else {
				time = _time_left.toString();
			}
			this.text = time;
		}

	}
}
