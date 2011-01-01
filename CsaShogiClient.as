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
    public static var WHO:String = 'who';
    public static var MONITOR:String = 'monitor';
    public static var START_WATCH:String = 'start_watch';
    public static var LIST:String = 'list';
    public static var GAME_SUMMARY:String = 'game_summary';
    public static var REJECT:String = 'reject';
    public static var WATCHERS:String = 'watchers';
	public static var ENTER:String = 'enter';
	public static var LEAVE:String = 'leave';
    
    public static var STATE_CONNECTED:int     = 0;
    public static var STATE_GAME_WAITING:int  = 1;
    public static var STATE_AGREE_WAITING:int = 2;
    public static var STATE_START_WAITING:int = 3;
    public static var STATE_GAME:int          = 4;
    public static var STATE_FINISHED:int      = 5;
    public static var STATE_NOT_CONNECTED:int = 6;

		private var _socket:Socket;

		//private var _host:String = '127.0.0.1';
		private var _host:String = '81dojo.dyndns.org';
		private var _port:int = 4081;

    private var _current_state:int;
    private var _my_turn:int;
    private var _player_names:Array;
	private var _login_name:String;
	private var _waiting_gamename:String;

    private var _buffer:String;
    private var _buffers:Object;
    private var _reading_game_summary_flag:Boolean;

		public function CsaShogiClient(){
      _current_state = STATE_NOT_CONNECTED;
      _player_names = new Array(2);
      _buffer = "";
      _buffers = new Object();
      for each(var key:String in [WHO,LIST,MONITOR,GAME_END,GAME_SUMMARY,WATCHERS]){
        _buffers[key] = "";
      }
		}

		public function connect():void{
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
		}

    public function login(login_name:String,password:String):void {
			_login_name = login_name;
      send("LOGIN " + login_name + " " + password +" x1");//connect with extended mode.
    }
	
	public function logout():void {
		send("LOGOUT");
	}

    public function waitForGame(total:int=1500,byoyomi:int=30,handicap:String="r"):void {
      _current_state = STATE_GAME_WAITING;
	  if (handicap.match(/^hc/)) {
		  _waiting_gamename = handicap + "_" + _login_name + "-" + total.toString() + "-" + byoyomi.toString() + " -";
	  } else if (Math.round(Math.random()) == 1) {
		  _waiting_gamename = handicap + "_" + _login_name + "-" + total.toString() + "-" + byoyomi.toString() + " +";
	  } else {
		  _waiting_gamename = handicap + "_" + _login_name + "-" + total.toString() + "-" + byoyomi.toString() + " -";
	  }
	  send("%%GAME " + _waiting_gamename);
    }
	
	public function waitAgain():void {
		_current_state = STATE_GAME_WAITING;
		send("%%GAME " + _waiting_gamename);
	}
	
	public function stopWaiting():void {
		if (_current_state == STATE_GAME_WAITING){
			_current_state = STATE_CONNECTED;
			send("%%GAME");
		}
	}

	public function challenge(user:Object):void {
      if(user.game_name){
        _current_state = STATE_GAME_WAITING;
		if (user.turn == "+") {
			send("%%GAME " + user.game_name + " -");
		} else if (user.turn == "-") {
			send("%%GAME " + user.game_name + " +");
		} else {
			send("%%GAME " + user.game_name + " *");
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

    public function list():void{
      send("%%LIST");
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
			_buffer = _buffer + response;
			trace("Response: " + _buffer + "***");
			var lines:Array = _buffer.split("\n");
			if (_buffer.match(/(^##\[MONITOR2\]|^##\[LIST\]|^##\[WHO\])/)) {
				if (!_buffer.match(/(\+OK$|##\[CHAT\].+$|##\[GAMECHAT\].+$|##\[PRIVATECHAT\].+$|START\:.+$|REJECT\:.+$|[-+][0-9]{4}[A-Z]{2},T\d+$|Game_Summary$)/)) {
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
		} else if ((match = line.match(/^##\[ENTER\]\[(.+)\]/))) {
			dispatchEvent(new ServerMessageEvent(ENTER, match[1]));
		} else if ((match = line.match(/^##\[LEAVE\]\[(.+)\]/))) {
			dispatchEvent(new ServerMessageEvent(LEAVE, match[1]));
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
              if(line.match(/^##\[MONITOR2\]/)){
                _buffer_response(MONITOR,line);
                if(line.match(/##\[MONITOR2\]\[.*\] \+OK/)){
			            _dispatchServerMessageEvent(MONITOR);
                }
              } else if (line.match(/^LOGOUT:completed/)) {
				_current_state = STATE_NOT_CONNECTED;
				dispatchEvent(new ServerMessageEvent(LOGOUT_COMPLETED, "Logout Completed"));
			  } else if (line.match(/^##\[SETRATE\] \+OK/)) {
				  Alert.show("Rate successfully updated.");
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
			Alert.show(e.toString());
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

	}
}
