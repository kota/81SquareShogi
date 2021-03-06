package{
	import flash.events.EventDispatcher;
  import ServerMessageEvent;

	public class CsaShogiClient extends EventDispatcher{
		import flash.events.*;
		import flash.net.*;
		import flash.errors.*;
		import mx.controls.Alert;
    import flash.system.Security;

		public static var CONNECTED:String = 'connected';
		public static var LOGIN:String = 'login';
		public static var LOGIN_FAILED:String = 'login_failed';
		public static var LOGOUT_COMPLETED:String = 'logout_completed';
		public static var GAME_STARTED:String = 'game_started';
		public static var GAME_END:String = 'game_end';
		public static var SERVER_MESSAGE:String = 'receive_message';
    public static var MOVE:String = 'move';
    public static var CHAT:String = 'chat';
	public static var GAMECHAT:String = 'gamechat';
	public static var PRIVATECHAT:String = 'privatechat';
	public static var OFFLINE_PM:String = 'offline_pm';
    public static var WHO:String = 'who';
    public static var MONITOR:String = 'monitor';
	public static var RECONNECT:String = 'reconnect';
    public static var START_WATCH:String = 'start_watch';
    public static var LIST:String = 'list';
    public static var GAME_SUMMARY:String = 'game_summary';
    public static var REJECT:String = 'reject';
    public static var WATCHERS:String = 'watchers';
	public static var ENTER:String = 'enter';
	public static var LEAVE:String = 'leave';
	public static var DISCONNECT:String = 'disconnect';
	public static var CHALLENGE:String = 'challenge';
	public static var ACCEPT:String = 'accept';
	public static var DECLINE:String = 'decline';
	public static var LOBBY_IN:String = 'lobby_in';
	public static var LOBBY_OUT:String = 'lobby_out';
	public static var GAME:String = 'game';
	public static var START:String = 'start';
	public static var RESULT:String = 'result';
	public static var SETRATE:String = 'setrate';
	public static var ADMIN_MONITOR:String = 'admin_monitor';
    
    public static var STATE_CONNECTED:int     = 0;
    public static var STATE_GAME_WAITING:int  = 1;
    public static var STATE_AGREE_WAITING:int = 2;
    public static var STATE_START_WAITING:int = 3;
    public static var STATE_GAME:int          = 4;
    public static var STATE_FINISHED:int      = 5;
    public static var STATE_NOT_CONNECTED:int = 6;

		private var _socket:Socket;

		private var _host:String = '81dojo.com';
		private var _port:int = 4081;

		private var _isAdmin:Boolean = false;
    private var _current_state:int;
    private var _my_turn:int;
    private var _player_names:Array;
	private var _login_name:String;
	private var _waiting_gamename:String;
	private var _idle:Boolean = false;

    private var _buffer:String;
    private var _buffers:Object;
    private var _reading_game_summary_flag:Boolean;

		public function CsaShogiClient(){
      _current_state = STATE_NOT_CONNECTED;
      _player_names = new Array(2);
      _buffer = "";
      _buffers = new Object();
      for each(var key:String in [WHO,LIST,MONITOR,RECONNECT,GAME_END,GAME_SUMMARY,WATCHERS,OFFLINE_PM]){
        _buffers[key] = "";
      }
		}

		public function connect():void{
		  Security.loadPolicyFile("xmlsocket://" + _host + ":" + _port);
		  _socket = new Socket();
		  _socket.addEventListener(Event.CONNECT,_handleConnect);
		  _socket.addEventListener(Event.CLOSE,_handleClose);
		  _socket.addEventListener(ProgressEvent.SOCKET_DATA,_handleSocketData);
		  _socket.addEventListener(IOErrorEvent.IO_ERROR,_handleIOError);
		  _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,_handleSecurityError);
		  _socket.connect(_host,_port);
		}

		public function close():void{
			_socket.close();
			_socket.removeEventListener(Event.CONNECT,_handleConnect);
			_socket.removeEventListener(Event.CLOSE,_handleClose);
		  _socket.removeEventListener(ProgressEvent.SOCKET_DATA,_handleSocketData);
		  _socket.removeEventListener(IOErrorEvent.IO_ERROR,_handleIOError);
		  _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,_handleSecurityError);
			trace("socket closed");
		}

		public function send(message:String):void{
		  _socket.writeUTFBytes(message + "\n");
		  _socket.flush();
		  trace ("message sent: " + message);
		  if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, "----- SENT> " + message + "\n"));
		}

    public function login(login_name:String,password:String):void {
			_login_name = login_name;
      send("LOGIN " + login_name + " " + password +" x1");//connect with extended mode.
    }
	
	public function logout():void {
		send("LOGOUT");
	}

    public function waitForGame(total:int=1500,byoyomi:int=30,handicap:String="r",tournament:String=""):void {
      _current_state = STATE_GAME_WAITING;
	  if (handicap.match(/^hc/)) {
		  _waiting_gamename = handicap + "_" + _login_name + tournament + "-" + total.toString() + "-" + byoyomi.toString() + " -";
	  } else if (Math.round(Math.random()) == 1) {
		  _waiting_gamename = handicap + "_" + _login_name + tournament + "-" + total.toString() + "-" + byoyomi.toString() + " +";
	  } else {
		  _waiting_gamename = handicap + "_" + _login_name + tournament + "-" + total.toString() + "-" + byoyomi.toString() + " -";
	  }
	  send("%%GAME " + _waiting_gamename);
    }
	
	public function stopWaiting():void {
		if (_current_state == STATE_GAME_WAITING){
			_current_state = STATE_CONNECTED;
			send("%%GAME");
		}
	}
	
	public function study(handicap:String, black:String, white:String, moves:String):void {
		send("%%%STUDY " + handicap + " " + black + " " + white + " " + moves);
	}
	
	public function accept():void {
		send("ACCEPT");
	}
	
	public function decline(comment:String = null):void {
		send("DECLINE" + (comment ? (" " + comment) : ""));
	}

	public function challenge(name:String):void {
	  send("%%CHALLENGE " + name)
    }
	
	public function seek(user:Object):void {
      if (user.game_name) {
		if (user.turn == "+") {
			send("%%SEEK " + user.game_name + " -");
		} else if (user.turn == "-") {
			send("%%SEEK " + user.game_name + " +");
		} else {
			send("%%SEEK " + user.game_name + " *");
		}
	  }
    }
	
	public function rematch(game_name:String, turn:int):void {
		_current_state = STATE_GAME_WAITING;
		var match:Array = game_name.match(/^([0-9a-z]+?)_(.*)$/);
		if (match[0].match(/^hc/)) {
			send("%%GAME " + match[1] + "_@" + match[2] + (turn == Kyokumen.SENTE ? " +" : " -"));
		} else {
			send("%%GAME " + match[1] + "_@" + match[2] + (turn == Kyokumen.SENTE ? " -" : " +"));
		}
	}

    public function agree():void {
      trace("AGREE");
      send("AGREE");
    }
	
	public function reject():void {
		trace("REJECT");
		send("REJECT");
	}
	
	public function closeGame():void {
		trace("CLOSE");
		send("CLOSE");
	}

    public function move(movement:String):void{
      send(movement);
    }

    public function resign():void{
      send("%TORYO");
    }
	
	public function kachi():void {
		send("%KACHI");
	}
	
	public function declare():void {
		send("%%%DECLARE");
	}

    public function who():void{
      send("%%WHO");
    }

    public function chat(message:String):void{
      send("%%CHAT " + message);
    }
	
	public function privateChat(sendTo:String, message:String):void {
		send("%%PRIVATECHAT " + sendTo + " " + message);
	}
	
	public function gameChat(game_name:String, message:String):void {
		send("%%GAMECHAT " + game_name + " " + message);
	}

		public function checkTimeout():void{
			send("%%%TIMEOUT");
		}

    public function monitorOn(game_name:String):void{
      send("%%MONITOR2ON " + game_name);
    }

    public function monitorOff(game_name:String):void{
      send("%%MONITOR2OFF " + game_name);
    }
	
	public function reconnect(game_name:String):void {
		send("%%RECONNECT " + game_name);
	}

    public function list():void{
      send("%%LIST");
    }
	
	public function refresh(loadList:Boolean):void {
		if (_idle) {
			keepAlive();
		} else {
			who();
			if (loadList) list();
		}
	}
	
	public function setRate(n:int):void {
		if (_current_state == STATE_CONNECTED) {
			send("%%SETRATE " + n);
		} else {
			Alert.show("You cannot set rate while playing or waiting for a game.", "Error");
		}
	}

    public function keepAlive():void{
      send("\n");
    }
	
	public function idle(onoff:Boolean):void {
		if (_idle != onoff) {
			_idle = onoff;
			send("%%IDLE " + (onoff ? 1 : 0));
			if (!onoff) refresh(true);
		}
	}

    public function watchers(game_name:String):void{
      send("%%%WATCHERS " + game_name);
    }

		private function _handleConnect(e:Event):void{
			trace("connected.");
			dispatchEvent(new Event(CsaShogiClient.CONNECTED));
		}

		private function _handleClose(e:Event):void{
			trace("closed.");
			_socket.removeEventListener(Event.CONNECT,_handleConnect);
			_socket.removeEventListener(Event.CLOSE,_handleClose);
		  _socket.removeEventListener(ProgressEvent.SOCKET_DATA,_handleSocketData);
		  _socket.removeEventListener(IOErrorEvent.IO_ERROR,_handleIOError);
		  _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _handleSecurityError);
		  if (_current_state != STATE_NOT_CONNECTED) Alert.show("You lost connection!");
		}

		private function _handleSocketData(e:ProgressEvent):void{
			var response:String = e.target.readUTFBytes(e.target.bytesAvailable);
			if (_isAdmin) dispatchEvent(new ServerMessageEvent(ADMIN_MONITOR, response));
			_buffer = _buffer + response;
			trace("Response: " + _buffer + "***");
			var lines:Array = _buffer.split("\n");
			if (_buffer.match(/(^##\[MONITOR2\]|^##\[LIST\]|^##\[WHO\]|^##\[RECONNECT\])/)) {
				if (!_buffer.match(/(\+OK$|##\[CHAT\].+$|##\[GAMECHAT\].+$|##\[PRIVATECHAT\].+$|START\:.+$|[-+][0-9]{4}[A-Z]{2},T\d+$|Game_Summary$)/)) {
					trace("buffer doesn't deserve dispatching.");
					return;
				}
			}
      var match:Array;
      for each(var line:String in lines){
        if(_reading_game_summary_flag){
          if ((match = line.match(/^Your_Turn\:([+-])/))) {
            _my_turn = match[1] == '+' ? Kyokumen.SENTE : Kyokumen.GOTE;
          } else if((match = line.match(/^Name\+\:(.*)/))){
            _player_names[0] = match[1];
            _buffer_response(GAME_SUMMARY, match[1]);
          } else if((match = line.match(/^Name\-\:(.*)/))){
            _player_names[1] = match[1];
            _buffer_response(GAME_SUMMARY, match[1]);
		  } else if ((match = line.match(/^To_Move\:([+-])/))) {
			  _buffer_response(GAME_SUMMARY, "P0" + match[1]);
		  } else if (line.match(/^P[0-9\+\-]/)) {
			  _buffer_response(GAME_SUMMARY, line);
          } else if(line == "END Game_Summary"){
            trace("state change to agree_wating");
            _current_state = STATE_AGREE_WAITING;
            _reading_game_summary_flag = false;
            _dispatchServerMessageEvent(GAME_SUMMARY);
          }
        }
        if(line.match(/^##\[GAMECHAT\]/)){
          dispatchEvent(new ServerMessageEvent(GAMECHAT, line + "\n"));
		} else if (line.match(/^##\[PRIVATECHAT\]/)) {
		  dispatchEvent(new ServerMessageEvent(PRIVATECHAT, line + "\n"));
		} else if(line.match(/^##\[CHAT\]/)){
          dispatchEvent(new ServerMessageEvent(CHAT,line + "\n"));
        } else if(line.match(/^([-+][0-9]{4}[A-Z]{2}|%TORYO),T/)){
          dispatchEvent(new ServerMessageEvent(MOVE, line));
		} else if ((match = line.match(/^##\[LOBBY_IN\](.*)$/))) {
		  dispatchEvent(new ServerMessageEvent(LOBBY_IN, match[1]));
		} else if ((match = line.match(/^##\[LOBBY_OUT\]\[(.*)\]$/))) {
		  dispatchEvent(new ServerMessageEvent(LOBBY_OUT, match[1]));
		} else if ((match = line.match(/^##\[ENTER\]\[(.+)\]$/))) {
			dispatchEvent(new ServerMessageEvent(ENTER, match[1]));
		} else if ((match = line.match(/^##\[LEAVE\]\[(.+)\]/))) {
			dispatchEvent(new ServerMessageEvent(LEAVE, match[1]));
		} else if ((match = line.match(/^##\[DISCONNECT\]\[(.+)\]/))) {
			dispatchEvent(new ServerMessageEvent(DISCONNECT, match[1]));
        } else if(line.match(/^##\[WHO\]/) != null){
          _buffer_response(WHO,line);
          if(line.match(/^##\[WHO\] \+OK$/)){
			      _dispatchServerMessageEvent(WHO);
          }
        } else if(line.match(/^##\[LIST\]/) != null){
          _buffer_response(LIST,line);
          if(line == "##[LIST] +OK"){
			      _dispatchServerMessageEvent(LIST);
          }
        } else if(line.match(/^##\[WATCHERS\]/) != null){
          _buffer_response(WATCHERS,line);
          if(line.match(/^##\[WATCHERS\] \+OK$/)){
			      _dispatchServerMessageEvent(WATCHERS);
          }
        } else {
          switch(_current_state) {
            case STATE_NOT_CONNECTED:
              if((match = line.match(/LOGIN:(.*) OK/))){
                _current_state = STATE_CONNECTED;
			          dispatchEvent(new ServerMessageEvent(LOGIN, match[1]));
              } else if (line.match(/LOGIN:incorrect login/)){
                dispatchEvent(new ServerMessageEvent(LOGIN_FAILED,"Loginname not Found."));
              } else if (line.match(/LOGIN:incorrect password/)){
                dispatchEvent(new ServerMessageEvent(LOGIN_FAILED,"Incorrect Password."));
              }
              break;
            case STATE_CONNECTED:
              if (line == "BEGIN Game_Summary") {
                _reading_game_summary_flag = true;
              }
              if(line.match(/^##\[MONITOR2\]/)){
                _buffer_response(MONITOR,line);
                if(line.match(/##\[MONITOR2\]\[.*\] \+OK/)){
			        _dispatchServerMessageEvent(MONITOR);
                }
			  } else if(line.match(/^##\[RECONNECT\]/)){
                _buffer_response(RECONNECT, line);
				if((match = line.match(/^##\[RECONNECT\]\[.+\]\sN\+(.+)$/))){
					_player_names[0] = match[1];
					if (match[1] == _login_name) _my_turn = Kyokumen.SENTE;
				} else if ((match = line.match(/^##\[RECONNECT\]\[.+\]\sN\-(.+)$/))) {
					_player_names[1] = match[1];
					if (match[1] == _login_name) _my_turn = Kyokumen.GOTE;
				} else if (line.match(/##\[RECONNECT\]\[.*\] \+OK/)) {
					_current_state = STATE_GAME;
					if (_buffers[RECONNECT].match(/##\[RECONNECT\]\[.+\]\s#(WIN|LOSE|DRAW|RESIGN|TIME_UP|ILLEGAL_MOVE|SENNICHITE|DISCONNECT|SUSPEND)/)) _current_state = STATE_CONNECTED;
			        _dispatchServerMessageEvent(RECONNECT);
                }
			  } else if ((match = line.match(/^##\[GAME\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(GAME, match[1]));
			  } else if ((match = line.match(/^##\[START\]\[(.*)\]$/))) {
				  dispatchEvent(new ServerMessageEvent(START, match[1]));
			  } else if ((match = line.match(/^##\[ACCEPT\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(ACCEPT, match[1]));
			  } else if ((match = line.match(/^##\[DECLINE\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(DECLINE, match[1]));
			  } else if ((match = line.match(/^##\[RESULT\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(RESULT, match[1]));
              } else if (line.match(/^LOGOUT:completed/)) {
				_current_state = STATE_NOT_CONNECTED;
				dispatchEvent(new ServerMessageEvent(LOGOUT_COMPLETED, "Logout Completed"));
			  } else if ((match = line.match(/^##\[OFFLINE_PM\]/))) {
                _buffer_response(OFFLINE_PM, line);
				if (line.match(/##\[OFFLINE_PM\] \+OK$/)) {
			        _dispatchServerMessageEvent(OFFLINE_PM);
                }
			  } else if ((match = line.match(/^##\[SETRATE\](\d+)$/))) {
				  dispatchEvent(new ServerMessageEvent(SETRATE, match[1]));
			  }
              break;
            case STATE_GAME_WAITING:
              if (line == "BEGIN Game_Summary") {
                _reading_game_summary_flag = true;
              }
              if(line.match(/^##\[MONITOR2\]/)){
                _buffer_response(MONITOR,line);
                if(line.match(/##\[MONITOR2\]\[.*\] \+OK/)){
			            _dispatchServerMessageEvent(MONITOR);
                }
              } else if (line.match(/^LOGOUT:completed/)) {
				_current_state = STATE_NOT_CONNECTED;
				dispatchEvent(new ServerMessageEvent(LOGOUT_COMPLETED, "Logout Completed"));
			  } else if ((match = line.match(/^##\[GAME\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(GAME, match[1]));
			  } else if ((match = line.match(/^##\[START\]\[(.*)\]$/))) {
				  dispatchEvent(new ServerMessageEvent(START, match[1]));
			  } else if ((match = line.match(/^##\[CHALLENGE\]\[(.+)\]$/))) {
				  dispatchEvent(new ServerMessageEvent(CHALLENGE, match[1]));
			  } else if ((match = line.match(/^##\[ACCEPT\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(ACCEPT, match[1]));
			  } else if ((match = line.match(/^##\[DECLINE\](.*)$/))) {
				  dispatchEvent(new ServerMessageEvent(DECLINE, match[1]));
			  }
              break;
            case STATE_AGREE_WAITING:
              if (line.match(/^START\:/) != null){
                trace("state change to game");
                _current_state = STATE_GAME;
			          dispatchEvent(new ServerMessageEvent(GAME_STARTED,line));
              } else if (line.match(/^REJECT\:/) != null) {
                trace("state change to connected");
                _current_state = STATE_CONNECTED;
                dispatchEvent(new ServerMessageEvent(REJECT,line));
			        }
              break;
            case STATE_START_WAITING:
              break;
            case STATE_GAME:
              if((match = line.match(/^#(WIN|LOSE|DRAW|RESIGN|TIME_UP|ILLEGAL_MOVE|SENNICHITE|DISCONNECT)/))){
                _buffer_response(GAME_END,line);
                if(match[1] == "WIN" || match[1] == "LOSE" || match[1] == "DRAW"){
                  trace("state change to connected");
                  _current_state = STATE_CONNECTED
			            _dispatchServerMessageEvent(GAME_END);
                }
              }
              break;
            case STATE_FINISHED:
              break;
          }
        }
      }
	  _buffer = "";
    }

    private function _dispatchServerMessageEvent(event_name:String):void{
      trace("dispatch " + event_name + ":" + _buffers[event_name]);
			dispatchEvent(new ServerMessageEvent(event_name,_buffers[event_name]));
      _buffers[event_name] = "";
    }

    private function _buffer_response(event_name:String, response:String):void{
      _buffers[event_name] += response+"\n";
    }

		private function _handleIOError(e:IOErrorEvent):void{
			Alert.show(e.toString());
		}

		private function _handleSecurityError(e:SecurityErrorEvent):void{
			if (e.toString().match(/\#2048/)) Alert.show("Login authentication failed.\nPlease reload and use VENUS server.\n(Please also notify 81Dojo staff about the problem.)");
			else Alert.show(e.toString());
		}

		public function isConnected():Boolean{
			return _socket.connected;
		}

    public function get myTurn():int{
      return _my_turn;
    }

    public function get playerNames():Array{
      return _player_names;
    }
	
    public function get waitingGamename():String{
      return _waiting_gamename;
    }
	
	public function setHostToLocal():void {
		_host = '127.0.0.1';
	}
	
	public function setServer(host:String, port:int):void {
		_host = host;
		_port = port;
	}
	
	public function adminOn():void {
		_isAdmin = true;
	}

	}
}
