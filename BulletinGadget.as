/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.events.Event;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.containers.ViewStack;
	import mx.controls.Image;
	import mx.controls.Label;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

  public class BulletinGadget extends ViewStack {
    
	private var _urlLoader:URLLoader = new URLLoader();
	private const SOURCE:String = "http://www.81squareuniverse.com/dojo/";
    
    public function BulletinGadget() {
      super();

	  _urlLoader.addEventListener(Event.COMPLETE, _parseInfo);
	  var nowDate:Date = new Date(); 
	  _urlLoader.load(new URLRequest(SOURCE + "tournaments/official/bulletin.txt?" + nowDate.getTime().toString()));
      }
    

    private function _parseInfo(e:Event):void {
		var tokens:Array;
		var lines:Array = _urlLoader.data.split("\n");
		var type:String;
		for each(var line:String in lines) {
			if (line.match(/^TITLE:/)) {
				var page:Canvas = new Canvas();
				page.width = 175;
				page.height = 625;
				page.horizontalScrollPolicy = "off";
				page.setStyle('backgroundColor', '#EEFFCC');
				var y:int = 0;
				var n:int = 0;
				var label:Label = new Label();
				var player_end:Boolean = false;
				label.text = line.substr(6);
				label.setStyle('textAlign', 'center');
				label.y = y;
				label.width = page.width
				label.setStyle('color', '#FF0000');
				label.setStyle('fontWeight', 'bold');
				page.addChild(label);
			} else if (line.match(/^TYPE:/)) {
				y -= 15;
				if (line.match(/ROUND_ROBIN/)) {
					type = "round_robin";
				} else if (line.match(/ELIMINATION/)) {
					type = "elimination";
				}
			} else if (line.match(/^DATE:/)) {
				label = new Label();
				label.text = "as of " + line.substr(5);
				label.y = y;
				label.width = page.width;
				label.setStyle('textAlign', 'right');
				page.addChild(label);
				label = new Label();
				label.setStyle('fontWeight', 'bold');
				label.text = "Standings";
				y += 20;
				label.y = y;
				page.addChild(label);
			} else if (line.match(/^CHAMPION:/)) {
				tokens = line.substr(9).split(",");
				var row:Canvas = new Canvas();
				label = new Label();
				label.text = "C";
				label.setStyle('textAlign', 'right');
				label.width = 20;
				row.addChild(label);
				var image:Image = new Image();
				image.width = 16;
				image.height = 11;
				image.source = SOURCE + "images/flags_ss/" + tokens[1] + ".png";
				image.x = 20;
				image.y = 3;
				row.addChild(image);
				label = new Label();
				trace(parseInt(tokens[1]));
				label.text = tokens[0];
				label.x = 37;
				label.width = 120;
				row.addChild(label);
				row.y = y;
				page.addChild(row);
				y += 10;
			} else if (line.match(/^PLAYER:/)) {
				tokens = line.substr(7).split(",");
				row = new Canvas();
				if (type == "round_robin") {
					n += 1;
					label = new Label();
					label.text = String(n);
					label.setStyle('textAlign', 'right');
					label.width = 20;
					row.addChild(label);
				}
				image = new Image();
				image.width = 16;
				image.height = 11;
				image.source = SOURCE + "images/flags_ss/" + tokens[1] + ".png";
				image.x = 20;
				image.y = 3;
				row.addChild(image);
				label = new Label();
				trace(parseInt(tokens[1]));
				label.text = tokens[0];
				label.x = 37;
				label.width = 120;
				if (type == "elimination" && tokens[2] == "false") label.setStyle('color', '#999999');
				row.addChild(label);
				if (type == "round_robin") {
					label = new Label();
					label.text = tokens[2] + "pts";
					label.setStyle('textAlign', 'right');
					label.width = 50;
					label.x = 125;
					row.addChild(label);
				}
				row.y = y;
				page.addChild(row);
			} else if (line.match(/^RESULT:/)) {
				if (!player_end) {
					player_end = true;
					label = new Label();
					label.setStyle('fontWeight', 'bold');
					label.text = "Recent Games";
					y += 10;
					label.y = y;
					page.addChild(label);
					y += 15;
				}
				label = new Label();
				label.text = line.substr(7);
				label.y = y;
				label.x = 10;
				page.addChild(label);
			} else if (line.match(/^END/)) {
				addChild(page);
			}
			y += 15;
		}
		this.selectedIndex = 0;
    }
	
	public function flip():void {
		if (this.selectedIndex == this.numChildren - 1) {
			this.selectedIndex = 0;
		} else {
			this.selectedIndex += 1;
		}
	}

  }
  
}
