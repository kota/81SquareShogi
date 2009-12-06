package{
	import com.adobe.serialization.json.JSON;
	import flash.events.EventDispatcher;
  import ServerMessageEvent;

	public class CsaShogiClient extends EventDispatcher{
		import flash.events.*;
		import flash.net.*;
		import flash.errors.*;
		import mx.controls.Alert;

		public static var CONNECTED:String = 'connected';
		public static var LOGIN:String = 'login';
		public static var GAME_STARTED:String = 'game_started';
		public static var GAME_END:String = 'game_end';
		public static var SERVER_MESSAGE:String = 'receive_message';
    public static var MOVE:String = 'move';
    public static var CHAT:String = 'chat';
    
    public static var STATE_CONNECTED:int     = 0;
    public static var STATE_GAME_WAITING:int  = 1;
    public static var STATE_AGREE_WAITING:int = 2;
    public static var STATE_START_WAITING:int = 3;
    public static var STATE_GAME:int          = 4;
    public static var STATE_FINISHED:int      = 5;
    public static var STATE_NOT_CONNECTED:int = 6;

		private var _socket:Socket;
		
		//private var host:String = '127.0.0.1';
		private var _host:String = '81square-shogi.homeip.net';
		private var _port:int = 2195;

    private var _current_state:int;
    private var _my_turn:int;

		public function CsaShogiClient(){
      _current_state = STATE_NOT_CONNECTED;
		}

		public function connect():void{
		  _socket = new Socket();
		  _socket.addEventListener(Event.CONNECT,_handleConnect);
		  _socket.addEventListener(Event.CLOSE,_handleClose);
		  _socket.addEventListener(ProgressEvent.SOCKET_DATA,_handleSocketData);
		  _socket.addEventListener(IOErrorEvent.IO_ERROR,_handleIOError);
		  _socket.connect(_host,_port);
		}

		public function close():void{
			_socket.close();
			_socket.removeEventListener(Event.CONNECT,_handleConnect);
			_socket.removeEventListener(Event.CLOSE,_handleClose);
		  _socket.removeEventListener(ProgressEvent.SOCKET_DATA,_handleSocketData);
			trace("socket closed");
		}

		public function send(message:String):void{
		  _socket.writeUTFBytes(message + "\n");
		  _socket.flush();
		  trace ("message sent: " + message);
		}

    public function login(login_name:String,password:String):void{
      send("LOGIN " + login_name + " " + password +" x1");//connect with extended mode.
    }

    public function waitForGame():void{
      _current_state = STATE_GAME_WAITING;
      send("%%GAME testgame-1500-0 *");
    }

    public function agree():void{
      trace("AGREE");
      send("AGREE");
    }

    public function move(movement:String):void{
      send(movement);
    }

    public function resign():void{
      send("%TORYO");
    }

    public function who():void{
      send("%%WHO");
    }

    public function chat(message:String):void{
      send("%%CHAT " + message);
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
		}

		private function _handleSocketData(e:ProgressEvent):void{
			var response:String = e.target.readUTFBytes(e.target.bytesAvailable);
      trace(response);
      if(response.indexOf("CHAT") >= 0){
        dispatchEvent(new ServerMessageEvent(CHAT,response));
        return;
      } else if(response.charAt(0) == '+' || response.charAt(0) == '-'){
        dispatchEvent(new ServerMessageEvent(MOVE,response));
        return;
      }
      switch(_current_state)
      {
        case STATE_NOT_CONNECTED:
          if(response.indexOf("LOGIN") >= 0 && response.indexOf("OK") >= 0){
            _current_state = STATE_CONNECTED;
			      dispatchEvent(new Event(LOGIN));
          }
          break;
        case STATE_CONNECTED:
          break;
        case STATE_GAME_WAITING:
          if (response.indexOf("BEGIN Game_Summary") >= 0) {
            trace("state change to agree_wating");
            _my_turn = response.charAt(response.indexOf("Your_Turn:")+9+1) == '+' ? Kyokumen.SENTE : Kyokumen.GOTE;
            _current_state = STATE_AGREE_WAITING;
            agree(); //agree automatically for now.
          }
          break;
        case STATE_AGREE_WAITING:
          if (response.indexOf("START") >= 0){
            trace("state change to game");
            _current_state = STATE_GAME;
			      dispatchEvent(new Event(GAME_STARTED));
          }
          break;
        case STATE_START_WAITING:
          break;
        case STATE_GAME:
          if(response.indexOf("WIN") >= 0 || response.indexOf("LOSE") >= 0){
            trace("state change to connected");
            _current_state = STATE_CONNECTED
			      dispatchEvent(new ServerMessageEvent(GAME_END,response));
          }
          break;
        case STATE_FINISHED:
          break;
      }
    }

		private function _handleIOError(e:IOErrorEvent):void{
			Alert.show(e.toString());
		}

		public function isConnected():Boolean{
			return _socket.connected;
		}

    public function get myTurn():int{
      return _my_turn;
    }

	}
}
