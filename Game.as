package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	import flash.filters.ColorMatrixFilter;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	 
	public class Game
	{
		private static const filterDefault:ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 ]);
		private static const filterGrey:ColorMatrixFilter = new ColorMatrixFilter([0.5, 0.25, 0.25, 0, 120, 0.25, 0.5, 0.25, 0, 120, 0.25, 0.25, 0.5, 0, 120, 0, 0, 0, 1, 0 ]);
		
		public var id:String;
		public var black:ObjectProxy;
		public var white:ObjectProxy;
		public var game_name:String;
		public var game_tag:String;
		public var total:int;
		public var byoyomi:int;
		public var status:String = "game";
		public var moves:int = 0;
		public var isIn:Array = new Array(true, true);
		public var watchers:int = 0;
		public var opening:String = "*";
		public var watcher_names:String = "";
		public var tag:String = "N";
		
		public var exist:Boolean;
		
		public function Game(id:String, black:User, white:User) {
			this.id = id;
			game_name = id.split("+")[1];
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			game_tag = game_info[1];
			total = parseInt(game_info[3]);
			byoyomi = parseInt(game_info[4]);
			this.black = new ObjectProxy(black);
			this.white = new ObjectProxy(white);
		}
		
		public function setFromList(moves:int, status:String, isInBlack:Boolean, isInWhite:Boolean, watchers:int, opening:String):void {
			this.moves = moves;
			this.status = status;
			isIn[0] = isInBlack;
			isIn[1] = isInWhite;
			this.watchers = watchers;
			this.opening = opening;
			exist = true;
		}
		
		public function get openingJp():String {
			if (game_tag.match(/^(hc|va)/)) {
				return InfoFetcher.gameTypeJp(game_tag);
			} else {
				return InfoFetcher.openingNameJp(opening);
			}
		}

		public function get openingEn():String {
			if (game_tag.match(/^(hc|va)/)) {
				return InfoFetcher.gameTypeShort(game_tag);
			} else {
				return InfoFetcher.openingNameEn(opening);
			}
		}
		
		public function get statusMark():String {
			if (status == "game" || status == "suspend") {
				return String(moves);
			} else {
				return "End";
			}
		}
		
		public function get description():String {
			if (id.match(/^STUDY/)) return "STUDY";
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			if (game_info[2].match(/\-\-..$/)) {
				return InfoFetcher.fetchTournamentJp(game_info[2].substr(game_info[2].length - 2, 2));
			} else {
				var str:String;
				if (game_info[1] == "r") {
					str = "R";
				} else if (game_info[1].match(/^hc/)) {
					str = "HC";
				} else {
					str = "NR";
				}
				return str + ": " + (parseInt(game_info[3]) >= 600 ? "" : " ") + (parseInt(game_info[3]) / 60) + "-" + game_info[4];
			  }
		}

		public function get descriptionTip():String {
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			if (game_info[2].match(/\-\-..$/)) {
					return InfoFetcher.fetchTournamentEn(game_info[2].substr(game_info[2].length - 2, 2));
			  } else {
					return "";
			  }
		}
		
		public function get maxRating():int {
			if (!isIn[0] || !isIn[1]) {
				return Math.max(black.rating, white.rating) - 3000;
			} else {
				return Math.max(black.rating, white.rating);
			}
		}
		
		public function get superior():int {
			if (game_tag.match(/^hc/) || black.isProvisional) {
				 return Kyokumen.GOTE;
			 } else if (white.isProvisional) {
				 return Kyokumen.SENTE;
			 } else if (black.rating > white.rating) {
				 return Kyokumen.SENTE;
			 } else {
				 return Kyokumen.GOTE;
			 }
		}
		
		public function nameColor(turn:int):uint {
			if (id.match(/^STUDY/)) return 0x999999;
			return isIn[turn] ? 0x000000 : 0x999999;
		}
		
		public function flagFilter(turn:int):ColorMatrixFilter {
			if (id.match(/^STUDY/)) return filterGrey;
			return isIn[turn] ? filterDefault : filterGrey;
		}
		
		public function nameDecoration(turn:int):String {
			if (turn == 0 && status == "win" || turn == 1 && status == "lose") {
				return "underline";
			} else {
				return undefined
			}
		}
		
		public function isStudyHost(name:String):Boolean {
			if (id.match(/^STUDY/)) {
				var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
				return name == game_info[2];
			} else {
				return false;
			}
		}
		
	}
}