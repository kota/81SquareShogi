package{
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.controls.Alert;
	import flash.events.Event;
  import flash.system.Security;

	public class ApiClient extends EventDispatcher {
		
		public static var KIFU_SEARCH:String = 'kifu_search';
		public static var KIFU_DETAIL:String = 'kifu_detail';
		public static var PLAYER_SEARCH:String = 'player_search';
		public static var PLAYER_DETAIL:String = 'player_detail';
		public static var RANKING_SEARCH:String = 'ranking_search';
		public static var READ_SERVER:String = 'read_server';
		public static var LOAD_HISTORY:String = 'load_history';
		public static var NOT_FOUND:String = 'not_found';
		public static var ADMIN_MONITOR:String = 'admin_monitor';
		private var _isAdmin:Boolean = false;
		
		public var bufferData:ArrayCollection;
		public var kifuContents:String;
		public var bufferXML:XML;
    
		private var _kifuSearchService:HTTPService = new HTTPService();
		private var _kifuDetailService:HTTPService = new HTTPService();
		private var _playerSearchService:HTTPService = new HTTPService();
		private var _playerDetailService:HTTPService = new HTTPService();
		private var _rankingService:HTTPService = new HTTPService();
		private var _readServerService:HTTPService = new HTTPService();
		private var _loadHistoryService:HTTPService = new HTTPService();
		
		//private var _host:String = '127.0.0.1';
		//private var _host:String = '81dojo.dyndns.org';
		private var _host:String = 'account.81dojo.com';
		private var _port:int = 80;

		public function ApiClient() {
			Security.loadPolicyFile('http://' + _host + ':' + _port + '/crossdomain.xml?110801b');
			_kifuSearchService.addEventListener(ResultEvent.RESULT, _handleKifuSearch);
			_kifuDetailService.addEventListener(ResultEvent.RESULT, _handleKifuDetail);
			_playerSearchService.addEventListener(ResultEvent.RESULT, _handlePlayerSearch);
			_playerDetailService.addEventListener(ResultEvent.RESULT, _handlePlayerDetail);
			_rankingService.addEventListener(ResultEvent.RESULT, _handleRanking);
			_readServerService.addEventListener(ResultEvent.RESULT, _handleReadServer);
			_loadHistoryService.addEventListener(ResultEvent.RESULT, _handleLoadHistory);
		}
		
		public function readServer():void {
			_readServerService.url = "http://" + _host + ":" + _port + "/api/servers.xml";
			trace("send: " + _readServerService.url);
			_readServerService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _readServerService.url +"\n"));
		}
		
		private function _handleReadServer(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			bufferData = e.result.servers.server as ArrayCollection;
			dispatchEvent(new Event(READ_SERVER));
			trace("dispatch api response");
		}
		
		public function kifuSearch(name1:String, name2:String, from:Date, to:Date):void {
			if (name2 == "") name2 = "*";
			var fromStr:String = from.getFullYear() + "-" + String(from.getMonth() + 101).substring(1) + "-" + String(from.getDate() + 100).substring(1);
			var toStr:String = to.getFullYear() + "-" + String(to.getMonth() + 101).substring(1) + "-" + String(to.getDate() + 100).substring(1);
			_kifuSearchService.url = "http://" + _host + ":" + _port + "/api/kifus/search/" + name1 + "/" + name2 + "/" + fromStr + "/" + toStr;
			trace("send: " + _kifuSearchService.url);
			_kifuSearchService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _kifuSearchService.url +"\n"));
			
		}
		
		private function _handleKifuSearch(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.kifus) {
				Alert.show("Data not found.");
				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				bufferData = e.result.kifus.kifu as ArrayCollection;
				if (!bufferData) {
					var kifus:Array = new Array();
					kifus.push(e.result.kifus.kifu);
					bufferData = new ArrayCollection(kifus);
				}
				dispatchEvent(new Event(KIFU_SEARCH));
				trace("dispatch api response");
			}
		}
		
		public function kifuDetail(id:int):void {
			_kifuDetailService.url = "http://" + _host + ":" + _port + "/api/kifus/" + id + ".xml";
			trace("send: " + _kifuDetailService.url);
			_kifuDetailService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _kifuDetailService.url +"\n"));
		}
		
		private function _handleKifuDetail(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.kifu) {
				Alert.show("Data not found.");
				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				kifuContents = e.result.kifu.contents;
				dispatchEvent(new Event(KIFU_DETAIL));
				trace("dispatch api response");
			}
		}
		
		public function playerSearch(name:String):void {
			_playerSearchService.url = "http://" + _host + ":" + _port + "/api/players/search/" + name;
			trace("send: " + _playerSearchService.url);
			_playerSearchService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _playerSearchService.url +"\n"));
		}
		
		private function _handlePlayerSearch(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.players) {
				Alert.show("Data not found.");
				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				bufferData = e.result.players.player as ArrayCollection;
				if (!bufferData) {
					var players:Array = new Array();
					players.push(e.result.players.player);
					bufferData = new ArrayCollection(players);
				}
				dispatchEvent(new Event(PLAYER_SEARCH));
				trace("dispatch api response");
			}
		}
		
		public function playerDetail(name:String):void {
			_playerDetailService.url = "http://" + _host + ":" + _port + "/api/players/detail/" + name;
			trace("send: " + _playerDetailService.url);
			_playerDetailService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _playerDetailService.url +"\n"));
		}
		
		private function _handlePlayerDetail(e:ResultEvent):void {
			if (!e.result.players) {
				Alert.show("Data not found.");
				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				var players:Array = new Array();
				players.push(e.result.players.player);
				bufferData = new ArrayCollection(players);
				dispatchEvent(new Event(PLAYER_DETAIL));
				trace("dispatch api response");
			}
		}
		
		public function rankingSearch(country:String, type:String):void {
			_rankingService.url = "http://" + _host + ":" + _port + "/api/players/ranking/" + country + "/" + type;
			_rankingService.resultFormat = "e4x";
			trace("send: " + _rankingService.url);
			_rankingService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _rankingService.url +"\n"));
		}

		private function _handleRanking(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.ranking) {
				Alert.show("Data not found.");
				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				bufferXML = new XML(e.result);
				dispatchEvent(new Event(RANKING_SEARCH));
				trace("dispatch api response");
			}
		}

		public function loadHistory(name:String):void {
			_loadHistoryService.url = "http://" + _host + ":" + _port + "/api/rate_change_histories/search/" + name;
			trace("send: " + _loadHistoryService.url);
			_loadHistoryService.send();
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "SENT>>> " + _loadHistoryService.url +"\n"));
		}

		private function _handleLoadHistory(e:ResultEvent):void {
			bufferData = new ArrayCollection();
			if (!e.result.rate_change_histories) {
//				Alert.show("Data not found.");
//				dispatchEvent(new Event(NOT_FOUND));
				return;
			} else {
				bufferData = e.result.rate_change_histories.rate_change_history as ArrayCollection;
				if (!bufferData) {
					var rate_change_histories:Array = new Array();
					rate_change_histories.push(e.result.rate_change_histories.rate_change_history);
					bufferData = new ArrayCollection(rate_change_histories);
				}
				dispatchEvent(new Event(LOAD_HISTORY));
				trace("dispatch api response");
			}
		}
	
	public function setHostToLocal():void {
		_host = '127.0.0.1';
		_port = 3000;
	}
	
	public function adminOn():void {
		_isAdmin = true;
	}

	}
}
