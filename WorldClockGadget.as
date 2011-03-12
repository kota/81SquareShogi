/**
* ...
* @author Default
* @version 0.1
*/

package  {
	
	import flash.events.TimerEvent;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import flash.utils.Timer;

	public class WorldClockGadget extends HBox {
		
		private static const names:Array = new Array('UTC', 'Frankfurt', 'Moscow', 'Mumbai', 'Bangkok', 'Tokyo', 'Los Angeles', 'New York', 'Sao Paulo');
//		private static const differences:Array = new Array(0, 1, 3, 5, 7, 9, -8, -5, -3);
		private static const half_hour:Array = new Array(false, false, false, true, false, false, false, false, false);
		private static const days:Array = new Array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');

		private var _boxes:Array = new Array();
		private var _clocks:Array = new Array();
		private var _timer:Timer = new Timer(60000);
    
		public function WorldClockGadget():void {
			super();
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy = "off";
			this.setStyle('horizontalAlign', 'center');
			this.setStyle('verticalAlign', 'middle');
			this.setStyle('fontSize', 12);
			this.setStyle('horizontalGap', 15);
			
			for (var i:int = 0; i < names.length; i++) {
				var vbox:VBox = new VBox();
				vbox.setStyle('verticalGap', 0);
				vbox.setStyle('horizontalAlign', 'center');
				var label:Label = new Label();
				label.text = names[i];
				label.setStyle('fontWeight', 'bold');
				vbox.addChild(label);
				var hbox:HBox = new HBox();
				hbox.width = 90;
				hbox.setStyle('borderStyle', 'solid');
				hbox.setStyle('borderColor', 0x555555);
				hbox.setStyle('horizontalAlign', 'center');
//				hbox.setStyle('fontSize', 13);
				label = new Label();
				_clocks.push(label);
				_boxes.push(hbox);
				hbox.addChild(label);
				vbox.addChild(hbox);
				addChild(vbox);
			}
		 }
		 
		 public function start():void {
			update();
			_timer.addEventListener(TimerEvent.TIMER, _handleTimer);
			_timer.start();
		 }
		 
		 public function update():void {
			 var nowDate:Date = new Date();
			 var UTCDay:int = nowDate.getUTCDay();
			 var UTCHours:int = nowDate.getUTCHours();
			 var UTCMinutes:int = nowDate.getUTCMinutes();			 

			if (nowDate.getUTCSeconds() >= 30) UTCMinutes += 1;
			 for (var i:int = 0; i < _clocks.length; i++) {
				 var minutes:int = UTCMinutes + (half_hour[i] ? 30 : 0)
				 var hours:int = UTCHours + InfoFetcher.clock_differences[i];
				 if (minutes >= 60) {
					 minutes -= 60;
					 hours += 1;
				 }
				 if (hours < 0) {
					 _clocks[i].text = days[(UTCDay - 1) % 7] + " " + (hours + 24 + 100).toString().substring(1) + ":" + (minutes + 100).toString().substring(1);
				 } else if (hours >= 24) {
					 _clocks[i].text = days[(UTCDay + 1) % 7] + " " + (hours - 24 + 100).toString().substring(1) + ":" + (minutes + 100).toString().substring(1);
				 } else {
					 _clocks[i].text = days[UTCDay] + " " + (hours + 100).toString().substring(1) + ":" + (minutes + 100).toString().substring(1);
				 }
				 if (hours >= 18 || hours <= 5) {
					 _boxes[i].setStyle('backgroundColor', 0x000044);
					 _boxes[i].setStyle('color', 0xFFFFCC);
				 } else {
					 _boxes[i].setStyle('backgroundColor', 0xFFFFCC);
					 _boxes[i].setStyle('color', undefined);
				 }
			 }
		 }
		 
		 private function _handleTimer(e:TimerEvent):void {
			 update();
		 }

	}
  
}
