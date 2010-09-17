package 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLVariables;
	import flash.net.sendToURL;
	import flash.net.URLRequestMethod;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	public class InfoFetcher extends EventDispatcher
	{
		private var _urlLoader:URLLoader = new URLLoader();
		private const SOURCE:String = "http://www.81squareuniverse.com/dojo/";
		public var newestVer:String;
		public var titleUser:Array = new Array;
		public var titleName:Array = new Array;
		private var rank_thresholds:Array = new Array;
		private var rank_names:Array = new Array;
		public var country_names:Array = new Array;
		public var initMessage:String
		private var _urlRequest:URLRequest = new URLRequest();
		private var _httpService:HTTPService = new HTTPService();
		public var userSettings:Object = new Object();
		private var _login_name:String;
		
		public function InfoFetcher()
		{
	  _urlLoader.addEventListener(Event.COMPLETE, _parseInfo);
	  var nowDate:Date = new Date(); 
	  _urlLoader.load(new URLRequest(SOURCE + "infoData.txt?" + nowDate.getTime().toString()));
	  _urlRequest.url = SOURCE + "users/write.php";
	  _urlRequest.method = URLRequestMethod.GET;
	  _httpService.url = SOURCE + "users/userConfig.xml";
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
		
		public static function gameType(str:String):String {
			switch (str) {
			case "r":
				return "Rated";
			case "nr":
				return "Non-rated";
			case "hclance":
				return "Lance Handicap (Non-rated)";
			case "hcbishop":
				return "Bishop Handicap (Non-rated)";
			case "hcrook":
				return "Rook Handicap (Non-rated)";
			case "hcrooklance":
				return "Rook-Lance Handicap (Non-rated)";
			case "hc2p":
				return "2-piece Handicap (Non-rated)";
			case "hc4p":
				return "4-piece Handicap (Non-rated)";
			case "hc6p":
				return "6-piece Handicap (Non-rated)";
			case "hc8p":
				return "8-piece Handicap (Non-rated)";
			case "hctombo":
				return "Dragonfly Handicap (Non-rated)";
			case "hc10p":
				return "10-piece Handicap (Non-rated)";
			case "hcfu3":
				return "Three Pawns Handicap (Non-rated)";
			case "hcnaked":
				return "Naked King Handicap (Non-rated)";
			}
			return "";
		}
		
		public function writeSettings(v:URLVariables):void {
			_urlRequest.data = v;
			sendToURL(_urlRequest);
		}
		
		public function loadSettings(str:String):void{
			_login_name = str;
			_httpService.addEventListener(ResultEvent.RESULT, _handleSettings);
			_httpService.send();
		}
		
		private function _handleSettings(e:ResultEvent):void {
			var userData:ArrayCollection = new ArrayCollection();
			userData = e.result.users.user as ArrayCollection;
			userSettings.pieceSound = true;
			userSettings.chatSound1 = true;
			userSettings.chatSound2 = true;
			userSettings.endSound = true;
			userSettings.pieceType = 0;
			userSettings.byoyomi = 1;
			for (var i:int = 0; i < userData.length; i++) {
				if (userData[i].name == _login_name) {
					userSettings = userData[i];
					break;
				}
			}
			dispatchEvent(new Event("loadComplete"));
		}
		
	}
	
}