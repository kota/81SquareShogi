package 
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLVariables;
	import flash.net.sendToURL;
	import flash.net.URLRequestMethod;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import flash.events.EventDispatcher;
	import mx.controls.Alert;
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	public class InfoFetcher extends EventDispatcher
	{
		private var _urlLoader:URLLoader = new URLLoader();
		private const SOURCE:String = "http://81dojo.com/dojo/";
		public var newestVer:String;
		public var titleUser:Array;
		public var titleName:Array;
		public var titleSubName:Array;
		public var titleAvatar:Array;
//		public static const rank_thresholds:Array = new Array(2900, 1900, 1380, 1340, 1300, 1260, 1220, 1180, 1140, 1100, 1060, 1020, 980, 940, 900, 860, 820, 780, 740, 700, 660, 620, 0);
		public static const rank_thresholds:Array = new Array(15000, 10000, 7000, 5000, 4000, 3000, 2000, 1000, 500, 200, 100, 50, 20, 0);
		public static const rank_names:Array = new Array('GOD', 'KING', 'MINISTER', 'SENATOR', 'SAGE', 'MASTER', 'PROFESSOR', 'DOCTOR', 'TEACHER', 'STUDENT','KID', 'INFANT', 'BABY', 'EGG')
		public var country_codes:Array;
		public static var country_names:Array;
		public static var country_names3:Array;
		public static var tournament_codes:Array = new Array('81', 'CO', 'AS', 'SN', 'SS', 'DM', 'KY', 'LA');
		public static var tournament_name_en:Array = new Array('81Ou', 'CosmOu', 'Aeon Saint', 'Supernova', 'Shooting Star', 'Dark Matter', 'Kyosha', 'LATINO');
		public static var tournament_name_jp:Array = new Array('八一王戦', '宇宙王戦', '永聖戦', '新星戦', '流星戦', '冥将戦', '香車戦', '中南米戦');
		public var cheaters:Array;
		public var banned:Array;
		public var initMessage:String = "";
		public var gameMessage:String = "";
		public var serverMaintenanceTime:Date;
		public static var clock_differences:Array;
		private var _urlRequest:URLRequest = new URLRequest();
		private var _httpService:HTTPService = new HTTPService();
		public var userSettings:Object = new Object();
		private var _login_name:String;
		[Embed(source = "/images/gold_medal.png")]
		private static var gold_medal:Class;
		[Embed(source = "/images/silver_medal.png")]
		private static var silver_medal:Class;
		[Embed(source = "/images/bronze_medal.png")]
		private static var bronze_medal:Class;
		public static const horizontalTextBars:Array = new Array('　', '▏', '▎', '▍', '▌', '▋', '▊', '▉', '█');
		public static const verticalTextBars:Array = new Array('　', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█');
		
		public function InfoFetcher()
		{
			_urlLoader.addEventListener(Event.COMPLETE, _parseInfo);
			_urlRequest.url = SOURCE + "users/write.php";
			_urlRequest.method = URLRequestMethod.GET;
			_httpService.url = SOURCE + "users/userConfig.xml";
			refresh();
		}
		
		public function refresh():void {
			titleUser = new Array();
			titleName = new Array();
			titleSubName = new Array();
			titleAvatar = new Array();
//			rank_thresholds = new Array();
//			rank_names = new Array();
			country_codes = new Array();
			country_names = new Array();
			country_names3 = new Array();
			cheaters = new Array();
			banned = new Array();
			clock_differences = new Array();
			var nowDate:Date = new Date(); 
			_urlLoader.load(new URLRequest(SOURCE + "infoData.txt?" + nowDate.getTime().toString()));
		}
		
		private function _parseInfo(e:Event):void {
			var response:String = _urlLoader.data
			var filter:String;
			for each(var line:String in response.split("\n")) {
				if (line.match(/^###/)) {
					filter = line.substr(3);
				} else {
					switch(filter) {
						case "NEWEST_VERSION34":
							newestVer = line;
							break;
						case "INITIAL_MESSAGE34":
							initMessage += line + "\n";
							break;
						case "GAME_MESSAGE34":
							gameMessage += line + "\n";
							break;
						case "TITLE_HOLDERS":
							titleUser.push(line.split("\t")[0]);
							titleName.push(line.split("\t")[1]);
							titleSubName.push(line.split("\t")[2]);
							titleAvatar.push(line.split("\t")[3]);
							break;
						case "COUNTRY_NAMES":
							country_codes.push(parseInt(line.split("\t")[0]));
							country_names[parseInt(line.split("\t")[0])] = line.split("\t")[1];
							country_names3[parseInt(line.split("\t")[0])] = line.split("\t")[2];
							break;
						case "CHEAT":
							cheaters.push(line);
							break;
						case "BANNED":
							banned.push(line);
							break;
						case "MAINTENANCE":
							if (line != "*") {
								serverMaintenanceTime = new Date();
								serverMaintenanceTime.setTime(Date.parse(line));
							}
							break;
						case "CLOCK_DIFFERENCE":
							for each (var diff:String in line.split(",")) {
								clock_differences.push(parseInt(diff));
							}
							break;
						default:
					}
				}
			}
		}
		
	    public static function makeRankFromRating(i:int):String {
			for (var j:int = 0; j < rank_thresholds.length; j++) {
				if (i >= rank_thresholds[j]) return rank_names[j];
			}
			return "";
	    }
		
		public static function makeColorFromRating(i:int):uint {
			if (i >= rank_thresholds[1]) {
				return 0x000000;
			} else if (i >= rank_thresholds[3]) {
				return 0xFF0000;
			} else if (i >= rank_thresholds[5]) {
				return 0xEE8800;
			} else if (i >= rank_thresholds[8]) {
				return 0x009300;
			} else if (i >= rank_thresholds[10]) {
				return 0x1166FF;
			} else if (i >= rank_thresholds[12]) {
				return 0xAA55FF;
			} else {
				return 0x777777;
			}
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
			case "hcrooksilver":
				return "Rook-Silver Handicap (Non-rated)";
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
			case "vamini":
				return "Mini Shogi";
			case "va5656":
				return "Goro-Goro Shogi";
			case "vazoo":
				return "3x4 Shogi";
			}
			return "";
		}
		
		public static function gameTypeShort(str:String):String {
			switch (str) {
			case "r":
				return "-";
			case "nr":
				return "-";
			case "hclance":
				return "Lance HC";
			case "hcbishop":
				return "Bishop HC";
			case "hcrook":
				return "Rook HC";
			case "hcrooklance":
				return "1.5";
			case "hcrooksilver":
				return "1.75";
			case "hc2p":
				return "2-piece HC";
			case "hc4p":
				return "4-piece HC";
			case "hc6p":
				return "6-piece HC";
			case "hc8p":
				return "8-piece HC";
			case "hctombo":
				return "Dragonfly";
			case "hc10p":
				return "10-piece HC";
			case "hcfu3":
				return "Three Pawns";
			case "hcnaked":
				return "Naked King";
			case "mini":
			case "vamini":
				return "Mini Shogi";
			case "va5656":
				return "Goro-Goro";
			case "vazoo":
				return "3x4 Shogi";
			}
			return "";
		}
		
		public static function gameTypeJp(str:String):String {
			switch (str) {
			case "hclance":
				return "香落ち";
			case "hcbishop":
				return "角落ち";
			case "hcrook":
				return "飛車落ち";
			case "hcrooklance":
				return "一丁半";
			case "hcrooksilver":
				return "飛銀落ち";
			case "hc2p":
				return "二枚落ち";
			case "hc4p":
				return "四枚落ち";
			case "hc6p":
				return "六枚落ち";
			case "hc8p":
				return "八枚落ち";
			case "hctombo":
				return "トンボ";
			case "hc10p":
				return "十枚落ち";
			case "hcfu3":
				return "歩三兵";
			case "hcnaked":
				return "裸玉";
			case "vamini":
				return "5五将棋";
			case "va5656":
				return "ゴロゴロ";
			case "vazoo":
				return "３×４";
			}
			return "";
		}
		
		public static function gameTypeKIF(str:String):String {
			var type_str:String = "手合割："
			switch (str) {
			case "r":
				type_str += "平手"; break;
			case "nr":
				type_str += "平手"; break;
			case "hclance":
				type_str += "香落ち"; break;
			case "hcbishop":
				type_str += "角落ち"; break;
			case "hcrook":
				type_str += "飛車落ち"; break;
			case "hcrooklance":
				type_str += "飛香落ち"; break;
			case "hcrooksilver":
				type_str += "その他\r\n";
				type_str += "上手の持駒：なし\r\n";
				type_str += "９ ８ ７ ６ ５ ４ ３ ２ １\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "|v香v桂v銀v金v玉v金 ・v桂v香|一\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・v角 ・|二\r\n";
				type_str += "|v歩v歩v歩v歩v歩v歩v歩v歩v歩|三\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|四\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|五\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|六\r\n";
				type_str += "| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七\r\n";
				type_str += "| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八\r\n";
				type_str += "| 香 桂 銀 金 玉 金 銀 桂 香|九\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "上手番"; break;
			case "hc2p":
				type_str += "二枚落ち"; break;
			case "hc4p":
				type_str += "四枚落ち"; break;
			case "hc6p":
				type_str += "六枚落ち"; break;
			case "hc8p":
				type_str += "八枚落ち"; break;
			case "hctombo":
				type_str += "その他\r\n";
				type_str += "上手の持駒：なし\r\n";
				type_str += "９ ８ ７ ６ ５ ４ ３ ２ １\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "| ・ ・ ・ ・v玉 ・ ・ ・ ・|一\r\n";
				type_str += "| ・v飛 ・ ・ ・ ・ ・v角 ・|二\r\n";
				type_str += "|v歩v歩v歩v歩v歩v歩v歩v歩v歩|三\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|四\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|五\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|六\r\n";
				type_str += "| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七\r\n";
				type_str += "| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八\r\n";
				type_str += "| 香 桂 銀 金 玉 金 銀 桂 香|九\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "上手番"; break;
			case "hc10p":
				type_str += "十枚落ち"; break;
			case "hcfu3":
				type_str += "その他\r\n";
				type_str += "上手の持駒：歩三\r\n";
				type_str += "９ ８ ７ ６ ５ ４ ３ ２ １\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "| ・ ・ ・ ・v玉 ・ ・ ・ ・|一\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|二\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|三\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|四\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|五\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|六\r\n";
				type_str += "| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七\r\n";
				type_str += "| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八\r\n";
				type_str += "| 香 桂 銀 金 玉 金 銀 桂 香|九\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "上手番"; break;
			case "hcnaked":
				type_str += "その他\r\n";
				type_str += "上手の持駒：なし\r\n";
				type_str += "９ ８ ７ ６ ５ ４ ３ ２ １\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "| ・ ・ ・ ・v玉 ・ ・ ・ ・|一\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|二\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|三\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|四\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|五\r\n";
				type_str += "| ・ ・ ・ ・ ・ ・ ・ ・ ・|六\r\n";
				type_str += "| 歩 歩 歩 歩 歩 歩 歩 歩 歩|七\r\n";
				type_str += "| ・ 角 ・ ・ ・ ・ ・ 飛 ・|八\r\n";
				type_str += "| 香 桂 銀 金 玉 金 銀 桂 香|九\r\n";
				type_str += "+---------------------------+\r\n";
				type_str += "上手番"; break;
			}
			return type_str;
		}

		public static function openingNameJp(str:String):String {
			var match:Array;
			var ranging_sg:String = "▲";
			var ranging_file:String;
			if ((match = str.match(/opposition_(black|white)(\d)/))) {
				if (match[1] == "white") ranging_sg = "△"
				switch (parseInt(match[2])) {
					case 2:
						ranging_file = "向"; break;
					case 3:
						ranging_file = "三"; break;
					case 4:
						ranging_file = "四"; break;
					case 5:
						ranging_file = "中"; break;
					default:
						return "";
				}
				return "対抗" + ranging_sg + ranging_file;
			} else {
				switch (str) {
				case "*":
					return "";
				case "unknown":
					return "力戦";
				case "side_pawn":
					return "横歩取り";
				case "double_wing":
					return "相掛かり";
				case "bishop_exchange":
					return "角換り";
				case "yagura":
					return "矢倉";
				case "double_ranging":
					return "相振り";
				}
			}
			return "";
		}

		public static function openingNameEn(str:String):String {
			var match:Array;
			var ranging_sg:String = "Black's";
			var ranging_file:String;
			if ((match = str.match(/opposition_(black|white)(\d)/))) {
				if (match[1] == "white") ranging_sg = "White's"
				switch (parseInt(match[2])) {
					case 2:
						ranging_file = "Opposing"; break;
					case 3:
						ranging_file = "3rd-file"; break;
					case 4:
						ranging_file = "4th-file"; break;
					case 5:
						ranging_file = "Central"; break;
					default:
						return "";
				}
				return "Opposition, " + ranging_sg + " " + ranging_file + " Rook";
			} else {
				switch (str) {
				case "*":
					return "";
				case "unknown":
					return "Free-style";
				case "side_pawn":
					return "Side Pawn Picker";
				case "double_wing":
					return "Double Wing Attack";
				case "bishop_exchange":
					return "Bishop Exchange";
				case "yagura":
					return "Yagura";
				case "double_ranging":
					return "Double Ranging Rook";
				}
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
			userSettings.chatSound3 = true;
			userSettings.pmAutoOpen = false;
			userSettings.grabPiece = true;
			userSettings.endSound = true;
			userSettings.pieceType = 0;
			userSettings.pieceType34 = 0;
			userSettings.highlightMovable = true;
			userSettings.byoyomi = 1;
			userSettings.acceptArrow = true;
			userSettings.arrowColor = 0x00CC00;
			userSettings.ignoreList = "";
			userSettings.favoriteList = "";
			for (var i:int = 0; i < userData.length; i++) {
				if (userData[i].name == _login_name) {
					userSettings = userData[i];
					if (userData[i].acceptArrow == null) userSettings.acceptArrow = true;
					if (userData[i].arrowColor == null) userSettings.arrowColor = 0x00CC00;
					if (userData[i].chatSound3 == null) userSettings.chatSound3 = true;
					if (userData[i].ignoreList == null) userSettings.ignoreList = "";
					if (userData[i].favoriteList == null) userSettings.favoriteList = "";
					if (userData[i].pmAutoOpen == null) userSettings.pmAutoOpen = false;
					if (userData[i].grabPiece == null) userSettings.grabPiece = true;
					if (userData[i].pieceType34 == null) userSettings.pieceType34 = 0;
					if (userData[i].highlightMovable == null) userSettings.highlightMovable = false;
					break;
				}
			}
			dispatchEvent(new Event("loadComplete"));
		}
		
		public static function medalCanvas(user:Object):Canvas {
			var canvas:Canvas = new Canvas();
			canvas.x = 2;
			canvas.y = 96;
			var i:int = 1;
			var medal:Image;
			if (user.titleName != "" && !user.titleName.match(/(!!!|livebot|師範)/)) {
				medal = new Image();
				medal.source = silver_medal;
				medal.toolTip = "Non-major Title Holder";
				medal.x = 24 * (i - 1);
				i += 1;
				if (user.titleName == "八一王" || user.titleName == "宇宙王") {
					medal.source = gold_medal;
					medal.toolTip = "Major Title Holder";
				} else if (user.titleName == "admin" || user.titleName.match(/bot/)) {
					medal.source = bronze_medal;
					medal.toolTip = "admin status";
				}
				canvas.addChild(medal);
			}
			if (user.wins + user.losses >= 30 && user.rating >= rank_thresholds[7]) {
				medal = new Image();
				medal.source = bronze_medal;
				medal.toolTip = "Low-Dan Holder";
				medal.x = 24 * (i - 1);
				i += 1;
				if (user.rating >= rank_thresholds[3]) {
					medal.source = gold_medal;
					medal.toolTip = "High-Dan Holder";
				} else if (user.rating >= rank_thresholds[5]) {
					medal.source = silver_medal;
					medal.toolTip = "Mid-Dan Holder";
				}
				canvas.addChild(medal);
			}
			if (user.wins >= 100) {
				medal = new Image();
				medal.source = bronze_medal;
				medal.toolTip = "100 wins";
				medal.x = 24 * (i - 1);
				i += 1;
				if (user.wins >= 300) {
					medal.source = gold_medal;
					medal.toolTip = "300 wins";
				} else if (user.wins >= 200) {
					medal.source = silver_medal;
					medal.toolTip = "200 wins";
				}
				canvas.addChild(medal);
			}
			if (user.streak_best >= 5) {
				medal = new Image();
				medal.source = bronze_medal;
				medal.toolTip = "5 streak wins";
				medal.x = 24 * (i - 1);
				i += 1;
				if (user.streak_best >= 15) {
					medal.source = gold_medal;
					medal.toolTip = "15 streak wins";
				} else if (user.streak_best >= 10) {
					medal.source = silver_medal;
					medal.toolTip = "10 streak wins";
				}
				canvas.addChild(medal);
			}
			if ((user.wins + user.losses >= 10) && ((user.wins / (user.wins + user.losses)) >= 0.6)) {
				medal = new Image();
				medal.source = bronze_medal;
				medal.toolTip = "60% winning percentage";
				medal.x = 24 * (i - 1);
				i += 1;
				if ((user.wins/(user.wins + user.losses)) >= 0.8) {
					medal.source = gold_medal;
					medal.toolTip = "80% winning percentage";
				} else if ((user.wins/(user.wins + user.losses)) >= 0.7) {
					medal.source = silver_medal;
					medal.toolTip = "70% winning percentage";
				}
				canvas.addChild(medal);
			}	
			return canvas;
		}
		
		public static function ratingDif(you:int, opponent:int, multiply:Number, v:int):int {
			var winner:int;
			var loser:int;
			if (v > 0) {
				winner = you;
				loser = opponent;
			} else if (v < 0) {
				winner = opponent;
				loser = you;
			} else {
				return 0;
			}
			var dif:Number = winner - loser;
			return Math.round(multiply * Math.min(31, Math.max(1, 32*(0.5 - 1.4217e-3*dif + 2.4336e-7*dif*Math.abs(dif) + 2.514e-9*dif*dif*dif - 1.991e-12*dif*dif*dif*Math.abs(dif)))));
		}
		
		public static function textBar(v:int):String {
			var i:int = v / 10;
			if (i > 8) i = 8;
			return verticalTextBars[i];
		}
		
		public static function fetchTournamentEn(s:String):String {
			for (var i:int = 0; i < tournament_codes.length; i++ ) {
				if (tournament_codes[i] == s) return tournament_name_en[i];
			}
			return "";
		}
		
		public static function fetchTournamentJp(s:String):String {
			for (var i:int = 0; i < tournament_codes.length; i++ ) {
				if (tournament_codes[i] == s) return tournament_name_jp[i];
			}
			return "";
		}
		
	}

}