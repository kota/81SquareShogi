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
		private const SOURCE:String = "http://www.81squareuniverse.com/dojo/initMessage.txt";
		private const rank_names:Array = new Array('Novice', '15-kyu', '14-kyu', '13-kyu', '12-kyu', '11-kyu', '10-kyu', '9-kyu', '8-kyu', '7-kyu', '6-kyu', '5-kyu', '4-kyu', '3-kyu', '2-kyu', '1-kyu', '1-dan', '2-dan', '3-dan', '4-dan', '5-dan', '6-dan');
		public var initMessage:String
		
		public function InfoFetcher()
		{
	  _urlLoader.addEventListener(Event.COMPLETE, _parseInfo);
	  _urlLoader.load(new URLRequest(SOURCE));	
		}
		
		private function _parseInfo(e:Event):void {
			initMessage = _urlLoader.data
		}
		
	    public function makeRankFromRating(i:int):String {
		    if (i < 790) return rank_names[0];     //smaller rank range (temporarily)
		    else if (i < 1190) return rank_names[int((i - 770) / 20)];
		    else return rank_names[21];
	        // if (i < 1550) return rank_names[int((i + 50) / 100)];
	        // else if (i < 2300) return rank_names[int((i + 1700) / 200)];
	        // else if (i < 2450) return rank_names[20];
	        // else return rank_names[21];
	    }
	}
	
}