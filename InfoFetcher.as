package 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	public class InfoFetcher
	{
		private var _urlLoader:URLLoader = new URLLoader();
		private const SOURCE:String = "http://www.81squareuniverse.com/dojo/infoData.txt?";
		public var newestVer:String;
		public var titleUser:Array = new Array;
		public var titleName:Array = new Array;
		private var rank_thresholds:Array = new Array;
		private var rank_names:Array = new Array;
		public var country_names:Array = new Array;
		public var initMessage:String
		
		public function InfoFetcher()
		{
	  _urlLoader.addEventListener(Event.COMPLETE, _parseInfo);
	  var nowDate:Date = new Date(); 
	  _urlLoader.load(new URLRequest(SOURCE + nowDate.getTime().toString()));	
		}
		
		private function _parseInfo(e:Event):void { 
			var response:String = _urlLoader.data
			var match:Array = response.match(/^###NEWEST_VERSION\n(.+)\n###INITIAL_MESSAGE\n(.+)\n###TITLE_HOLDERS\n(.+)\n###RANK_THRESHOLDS\n(.+)\n###COUNTRY_NAMES\n(.+)\n###/s);
			newestVer = match[1];
			initMessage = match[2];
			var lines:Array = match[3].split("\n");
			for each(var line:String in lines) {
				titleUser.push(line.split("\t")[0]);
				titleName.push(line.split("\t")[1]);
			}
			lines = match[4].split("\n");
			for each(line in lines) {
				rank_thresholds.push(line.split("\t")[0]);
				rank_names.push(line.split("\t")[1]);
			}
			lines = match[5].split("\n");
			for each(line in lines) {
				country_names[line.split("\t")[0]] = line.split("\t")[1];
			}
		}
		
	    public function makeRankFromRating(i:int):String {
			for (var j:int = 0; j < rank_thresholds.length; j++) {
				if (i >= rank_thresholds[j]) return rank_names[j];
			}
			return "";
//		    if (i < 790) return rank_names[0];     //smaller rank range (temporarily)
//		    else if (i < 1190) return rank_names[int((i - 770) / 20)];
//		    else return rank_names[21];

	        // if (i < 1550) return rank_names[int((i + 50) / 100)];
	        // else if (i < 2300) return rank_names[int((i + 1700) / 200)];
	        // else if (i < 2450) return rank_names[20];
	        // else return rank_names[21];
	    }
	}
	
}