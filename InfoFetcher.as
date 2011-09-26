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
		private const SOURCE:String = "http://49.212.52.151/dojo/";
		public var newestVer:String;
		public static var titleUser:Array;
		public static var titleName:Array;
		public static var titleSubName:Array;
		public static var titleAvatar:Array;
//		public static const rank_thresholds:Array = new Array(2900, 1900, 1480, 1420, 1360, 1300, 1240, 1180, 1140, 1100, 1060, 1020, 980, 940, 900, 860, 820, 780, 740, 700, 660, 620, 0);
		public static const rank_thresholds:Array = new Array(2900, 1800, 1640, 1520, 1400, 1300, 1200, 1100, 1050, 1000, 950, 900, 850, 800, 750, 700, 650, 600, 550, 500, 450, 400, 0);
		public static const rank_names:Array = new Array('PRO', '7-Dan', '6-Dan', '5-Dan', '4-Dan', '3-Dan', '2-Dan', '1-Dan', '1-kyu', '2-kyu', '3-kyu', '4-kyu', '5-kyu', '6-kyu', '7-kyu', '8-kyu', '9-kyu', '10-kyu', '11-kyu', '12-kyu', '13-kyu', '14-kyu', '15-kyu');
		public static const rank_thresholds34:Array = new Array(15000, 10000, 7000, 5000, 3000, 2000, 1000, 500, 200, 100, 50, 20, 5, 0);
		public static const rank_names34:Array = new Array('GOD', 'KING', 'MINISTER', 'SENATOR', 'SAGE', 'MASTER', 'PROFESSOR', 'DOCTOR', 'TEACHER', 'STUDENT', 'KID', 'INFANT', 'BABY', 'EGG');
		public static var country_codes:Array;
		public static var country_names:Array;
		public static var country_names3:Array;
		public static var country_list_names:Array;
		public static var country_maps:Array;
		public static var tournament_codes:Array = new Array('81', 'CO', 'AS', 'SN', 'SS', 'RZ', 'DM', 'KY', 'LA', 'RL',
																				'PM', 'PR', 'PI', 'PO', 'PS', 'PK', 'PZ', 'PT', 'PN', 'PA', 'PJ',
																				'JM', 'JZ', 'JI', 'JO', 'JF', 'JV');
		public static var tournament_name_en:Array = new Array('81Ou', 'CosmOu', 'Aeon Saint', 'Supernova', 'Shooting Star', 'Renza', 'Dark Matter', 'Kyosha', 'LATINO', 'Relay Shogi',
																				'Meijin', 'Ryu-ou', 'Ou-i', 'Oushou', 'Kisei', 'Kiou', 'Ouza', 'Masters Tournament', 'Rookies Tournament', 'Asahi Cup', 'JT Series',
																				'Women Meijin', 'Women Ouza', 'Woman Ou-i', 'Women Oushou', 'Kurashiki Azalea', 'MyNavi Women Open');
		public static var tournament_name_jp:Array = new Array('八一王戦', '宇宙王戦', '永聖戦', '新星戦', '流星戦', '連座戦', '冥将戦', '香車戦', '中南米戦', 'リレー',
																				'名人戦', '竜王戦', '王位戦', '王将戦', '棋聖戦', '棋王戦', '王座戦', '達人戦', '新人王戦', '朝日杯', 'JT杯',
																				'女流名人', '女流王座', '女流王位', '女流王将', '倉敷藤花', 'マイナビ');
		public static const pie_chart_order:Array = new Array("opposition_static", "yagura", "bishop_exchange", "side_pawn", "double_wing", "unknown", "double_ranging", "opposing_rook", "3rd_file_rook", "4th_file_rook", "central_rook");
		public static const radar_chart_order:Array = new Array("opposition_static","yagura_and_bishop","side_and_wing","unknown","double_ranging","opposition_ranging");
		public static const adminsLv1:Array = new Array('kota', 'hidetchi', 'test1', 'test2', 'test3');
		public static const adminsLv2:Array = new Array('berni314', 'tkaneko', 'test4');
		
		public var cheaters:Array;
		public var banned:Array;
		public var initMessage:String = "";
		public var gameMessage:String = "";
		public var serverMaintenanceTime:Date;
		public static var clock_differences:Array;
		private var _urlRequest:URLRequest = new URLRequest();
		private var _loadOptionService:HTTPService = new HTTPService();
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
			country_list_names = new Array('== ALL ==');
			country_maps = new Array();
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
						case "NEWEST_VERSION":
							newestVer = line;
							break;
						case "INITIAL_MESSAGE":
							initMessage += line + "\n";
							break;
						case "GAME_MESSAGE":
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
							country_list_names.push(line.split("\t")[1]);
							country_maps.push(line.split("\t")[3]);
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
		
	    public static function makeRank34FromExp(i:int):String {
			for (var j:int = 0; j < rank_thresholds34.length; j++) {
				if (i >= rank_thresholds34[j]) return rank_names34[j];
			}
			return "";
	    }
		
		public static function makeColorFromRating(i:int):uint {
			if (i >= rank_thresholds[1]) {
				return 0x000000;
			} else if (i >= rank_thresholds[4]) {
				return 0xFF0000;
			} else if (i >= rank_thresholds[7]) {
				return 0xEE8800;
			} else if (i >= rank_thresholds[10]) {
				return 0x009300;
			} else if (i >= rank_thresholds[13]) {
				return 0x1166FF;
			} else if (i >= rank_thresholds[16]) {
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
				case "opposition_static":
					return "居飛車 対抗";
				case "central_rook":
					return "中飛車";
				case "4th_file_rook":
					return "四間飛車";
				case "3rd_file_rook":
					return "三間飛車";
				case "opposing_rook":
					return "向かい飛車";
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
					return "Double Swinging Rook";
				case "opposition_static":
					return "Static Rook, Opposition";
				case "central_rook":
					return "Central Rook";
				case "4th_file_rook":
					return "4th-file Rook";
				case "3rd_file_rook":
					return "3rd-file Rook";
				case "opposing_rook":
					return "Opposing Rook";
				}
			}
			return "";
		}

		public static function infoOpeningColor(str:String):uint {
			switch (str) {
			case "opposition_static":
				return 0xff0000;
			case "yagura":
				return 0xff6600;
			case "bishop_exchange":
				return 0x990000;
			case "double_wing":
				return 0xff66ff;
			case "side_pawn":
				return 0x9900cc;
			case "unknown":
				return 0xffff00;
			case "double_ranging":
				return 0x669933;
			case "opposing_rook":
				return 0x000066;
			case "3rd_file_rook":
				return 0x00ffcc;
			case "4th_file_rook":
				return 0x0000ff;
			case "central_rook":
				return 0x3399cc;
			}
			return 0x000000;
		}
		
		public function writeSettings(v:URLVariables):void {
			_urlRequest.data = v;
			sendToURL(_urlRequest);
		}
		
		public function loadSettings(name:String):void{
			_loadOptionService.url = SOURCE + "users/read.php?name=" + name.toLowerCase();
			_loadOptionService.addEventListener(ResultEvent.RESULT, _handleSettings);
			_loadOptionService.send();
		}
		
		private function _handleSettings(e:ResultEvent):void {
			if (e.result.user) {
				userSettings = e.result.user;
				if (userSettings.acceptArrow == null) userSettings.acceptArrow = true;
				if (userSettings.arrowColor == null) userSettings.arrowColor = 0x00CC00;
				if (userSettings.chatSound3 == null) userSettings.chatSound3 = true;
				if (userSettings.ignoreList == null) userSettings.ignoreList = "";
				if (userSettings.favoriteList == null) userSettings.favoriteList = "";
				if (userSettings.pmAutoOpen == null) userSettings.pmAutoOpen = false;
				if (userSettings.grabPiece == null) userSettings.grabPiece = true;
				if (userSettings.pieceType34 == null) userSettings.pieceType34 = 0;
				if (userSettings.highlightMovable == null) userSettings.highlightMovable = true;
				if (userSettings.notation == null) userSettings.notation = 0;
				dispatchEvent(new Event("loadComplete"));
			}
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
				if (["八一王", "宇宙王", "永聖", "二冠"].indexOf(user.titleName) >= 0) {
					medal.source = gold_medal;
					medal.toolTip = "Major Title Holder";
				} else if (["admin", "livebot", "replaybot", "AI-bot", "師範", "プロ"].indexOf(user.titleName) >= 0) {
					medal.source = bronze_medal;
					medal.toolTip = "admin status";
				}
				canvas.addChild(medal);
			}
			if (user.total >= 30 && user.rating >= rank_thresholds[7]) {
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
			if (user.total >= 10 && user.percentage >= 60) {
				medal = new Image();
				medal.source = bronze_medal;
				medal.toolTip = "60% winning percentage";
				medal.x = 24 * (i - 1);
				i += 1;
				if (user.percentage >= 80) {
					medal.source = gold_medal;
					medal.toolTip = "80% winning percentage";
				} else if (user.percentage >= 70) {
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
		
		public static function isAdminLv1(login:String):Boolean {
			return (adminsLv1.indexOf(login.toLowerCase()) >= 0);
		}
		
		public static function isAdminLv2(login:String):Boolean {
			return (adminsLv2.indexOf(login.toLowerCase()) >= 0);
		}
		
	}

}