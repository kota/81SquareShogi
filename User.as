package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	public class User
	{
		public static const STATE_CONNECTED:String = "connected";
		public static const STATE_GAME_WAITING:String = "game_waiting";
		public static const STATE_GAME:String = "game";
		public static const STATE_POSTGAME:String = "post_game";
		private static const IMAGE_DIRECTORY:String = "http://81dojo.com/dojo/images/";
		public var name:String;
		public var rating:int;
		public var country_code:int = 0;
		public var wins:int;
		public var losses:int;
		public var draws:int;
		public var status:String = STATE_CONNECTED;
		public var opponent:String = "";
		public var game_name:String = "*";
		public var turn:String = "*";
		public var monitor_game:String = "*";
		public var moves:int = 0;
		public var mark:String = "";
		public var markWidth:int = 0;
		public var idle:Boolean = false;
		public var disconnected:Boolean = false;
		public var cheater:Boolean = false;
		
		public var favorite:String = "";
		public var favoriteWidth:int = 0;
		
		public var exist:Boolean;
		
		public function User(name:String) {
			this.name = name;
		}
		
		public function initialize():void {
			status = STATE_CONNECTED;
			opponent = "";
			game_name = "*";
			turn = "*";
			monitor_game = "*";
			moves = 0;
			mark = "";
			markWidth = 0;
			idle = false;
			disconnected = false;
			cheater = false;
		}
		
		public function setFromWho(rating:int, country_code:int, wins:int, losses:int, draws:int,
									status:String, opponent:String, game_name:String, turn:String, monitor_game:String, moves:int, idle:Boolean):void {
			this.rating = rating;
			this.country_code = country_code;
			this.wins = wins;
			this.losses = losses;
			this.draws = draws;
			this.status = status;
			this.opponent = opponent;
			this.game_name = game_name;
			this.turn = turn;
			this.monitor_game = monitor_game;
			this.moves = moves;
			this.idle = idle;
			exist = true;
		}
		
		public function setFromLobbyIn(rating:int, country_code:int, wins:int, losses:int, draws:int):void {
			this.rating = rating;
			this.country_code = country_code;
			this.wins = wins;
			this.losses = losses;
			this.draws = draws;
		}
		
		public function setFromList(rating:int, country_code:int):void {
			this.rating = rating;
			this.country_code = country_code;
		}
		
		public function setFromGame(game_name:String, turn:String):void {
			this.game_name = game_name;
			this.turn = turn;
			if (game_name == "*") status = STATE_CONNECTED;
			else status = STATE_GAME_WAITING;
		}
		
		public function setFromStart(game_name:String, turn:String):void {
			this.game_name = game_name;
			this.turn = turn;
			this.status = STATE_GAME;
			this.moves = 0;
			this.idle = false;
		}
		
		public function get country():String {
			return InfoFetcher.country_names[country_code];
		}
		
		public function get country3():String {
			return InfoFetcher.country_names3[country_code];
		}
		
		public function get flag_m():String {
			return IMAGE_DIRECTORY + "flags_m/" + String(country_code + 1000).substring(1) + ".swf";
		}
		
		public function get flag_s():String {
			return IMAGE_DIRECTORY + "flags_s/" + String(country_code + 1000).substring(1) + ".gif";
		}
		
		public function get flag_ss():String {
			return IMAGE_DIRECTORY + "flags_ss/" + String(country_code + 1000).substring(1) + ".png";
		}
		
		public function get statusMark():String {
			var str:String = "";
			if (monitor_game != "*") str = "M ";
			if(status == STATE_GAME_WAITING && !game_name.match(/_@/)){
				 str += "W";
			} else if (status == STATE_POSTGAME) {
				str = "P ";
			} else if (status == STATE_GAME) {
				  str = "G " + InfoFetcher.textBar(moves);
			}
			if (disconnected) str = "D";
			return str;
		}
		
		public function get titleName():String {
			  for (var i:int = 0; i < InfoFetcher.titleUser.length; i++) {
					  if (name.toLowerCase() == InfoFetcher.titleUser[i]) {
						  return InfoFetcher.titleName[i];
					  }
			  }
			  if (cheater) return "!!!";
			  return "";
		}
		
		public function get titleSubName():String {
			  for (var i:int = 0; i < InfoFetcher.titleUser.length; i++) {
					  if (name.toLowerCase() == InfoFetcher.titleUser[i]) {
						  return InfoFetcher.titleSubName[i];
					  }
			  }
			  return "";
		}

		public function get avatar():String {
			var str:String = rank;
			  for (var i:int = 0; i < InfoFetcher.titleUser.length; i++) {
				  if (name.toLowerCase() == InfoFetcher.titleUser[i]) {
					  if (InfoFetcher.titleAvatar[i] != "*") str = InfoFetcher.titleAvatar[i];
					  break;
				  }
			  }
			  return IMAGE_DIRECTORY + "avatars34/" + str + ".jpg";
		}
		
		public function get rank():String {
				return InfoFetcher.makeRankFromRating(rating);
		}
		
		public function get rankColor():uint {
				return InfoFetcher.makeColorFromRating(rating);
		}
		
		public function get gameDescriptionRated():String {
			if (game_name == "*") return "";
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			if (game_info[1] == "r") {
				return "R";
			} else {
				return "NR";
			}
		}
		
		public function get gameDescriptionTime():String {
			if (game_name == "*") return "";
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			if (game_info[2].match(/\-\-..$/)) {
					return InfoFetcher.fetchTournamentJp(game_info[2].substr(game_info[2].length - 2, 2));
			  } else {
					return (parseInt(game_info[3]) / 60) + " min + " + game_info[4] + " sec";
			  }
		}

		public function get gameDescriptionTimeTip():String {
			if (game_name == "*") return "";
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			if (game_info[2].match(/\-\-..$/)) {
					return InfoFetcher.fetchTournamentEn(game_info[2].substr(game_info[2].length - 2, 2));
			  } else {
					return "";
			  }
		}
		
		public function get gameDescriptionHandicap():String {
			if (game_name == "*") return "";
			var game_info:Array = game_name.match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
			 return InfoFetcher.gameTypeShort(game_info[1]);
		}
		
		public function get rateStr():String {
			if (isProvisional && rating < InfoFetcher.rank_thresholds[1]) return ("*" + String(rating));
			else return String(rating);
		}
		
		public function get description():String {
			var str:String = titleName;
			return "EXP:" + rateStr + ", " + (str == "" ? rank : str);
		}
		
		public function get total():int {
			return wins + losses + draws;
		}
		
		public function get percentage():Number {
			if (total == 0) {
				return 0;
			} else {
				return (wins / total * 100);
			}
		}
		
		public function markSelf():void {
			mark = "◆";
			markWidth = 11;
		}

		public function markFavorite():void {
			mark = "★";
			markWidth = 11;
		}
		
		public function unmark():void {
			mark  "";
			markWidth = 0;
		}
		
		public function get isProvisional():Boolean {
			return false;
		}
		
	}
}