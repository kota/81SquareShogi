package{
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.controls.Alert;
	import flash.events.Event;

	public class ApiClient extends EventDispatcher {
		
		public static var KIFU_SEARCH:String = 'kifu_search';
		public static var KIFU_DETAIL:String = 'kifu_detail';
		public static var PLAYER_SEARCH:String = 'player_search';
		public static var RANKING_RATE:String = 'ranking_rate';
		public static var RANKING_WINS:String = 'ranking_wins';
		public static var RANKING_TOTAL:String = 'ranking_total';
		public static var RANKING_STREAK:String = 'ranking_streak';
		public static var RANKING_PERCENTAGE:String = 'ranking_percentage';
		
		public var bufferData:ArrayCollection;
		public var kifuContents:String;
    
		private var _kifuSearchService:HTTPService = new HTTPService();
		private var _kifuDetailService:HTTPService = new HTTPService();
		private var _playerSearchService:HTTPService = new HTTPService();
		private var _rankingService:HTTPService = new HTTPService();
		
		//private var _host:String = '127.0.0.1';
		private var _host:String = '81dojo.dyndns.org';
		//private var _host:String = '81squareuniverse.com';
		//private var _port:int = 4081;
		private var _port:int = 2195;

		public function ApiClient() {
			_kifuSearchService.addEventListener(ResultEvent.RESULT, _handleKifuSearch);
			_kifuDetailService.addEventListener(ResultEvent.RESULT, _handleKifuDetail);
			_playerSearchService.addEventListener(ResultEvent.RESULT, _handlePlayerSearch);
			_rankingService.addEventListener(ResultEvent.RESULT, _handleRanking);
		}
		
		public function kifuSearch(name:String, from:Date, to:Date):void {
			var fromStr:String = from.getFullYear() + "-" + String(from.getMonth() + 101).substring(1) + "-" + String(from.getDate() + 100).substring(1);
			var toStr:String = to.getFullYear() + "-" + String(to.getMonth() + 101).substring(1) + "-" + String(to.getDate() + 100).substring(1);
			_kifuSearchService.url = "http://" + _host + ":" + _port + "/api/kifus/search/" + name + "/" + fromStr + "/" + toStr;
			trace("send: " + _kifuSearchService.url);
			_kifuSearchService.send();
		}
		
		private function _handleKifuSearch(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.kifus) {
				Alert.show("Data not found.");
				return;
			} else {
				bufferData = e.result.kifus.kifu as ArrayCollection;
				dispatchEvent(new Event(KIFU_SEARCH));
			}
		}
		
		public function kifuDetail(id:int):void {
			_kifuDetailService.url = "http://" + _host + ":" + _port + "/api/kifus/" + id + ".xml";
			trace("send: " + _kifuDetailService.url);
			_kifuDetailService.send();
		}
		
		private function _handleKifuDetail(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.kifu) {
				Alert.show("Data not found.");
				return;
			} else {
				kifuContents = e.result.kifu.contents;
				dispatchEvent(new Event(KIFU_DETAIL));
			}
		}
		
		private function _handlePlayerSearch(e:ResultEvent):void {
			trace(e.result);
		}

		private function _handleRanking(e:ResultEvent):void {
			trace(e.result);
		}
	
	public function setHostToLocal():void {
		_host = '127.0.0.1';
		_port = 3000;
	}

	}
}
