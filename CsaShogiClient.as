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
		public static var GAME_STARTED:String = 'game_started';
		public static var SERVER_MESSAGE:String = 'receive_message';
    
    public static var STATE_CONNECTED:int     = 0;
    public static var STATE_GAME_WAITING:int  = 1;
    public static var STATE_AGREE_WAITING:int = 2;
    public static var STATE_START_WAITING:int = 3;
    public static var STATE_GAME:int          = 4;
    public static var STATE_FINISHED:int      = 5;

		private var _socket:Socket;
		
		//private var host:String = '127.0.0.1';
		private var _host:String = '81square-shogi.homeip.net';
		private var _port:int = 2195;

    private var _current_state:int;
    private var _my_turn:int;

		public function CsaShogiClient(){
		}

		public function connect():void{
		  _socket = new Socket();
		  _socket.addEventListener(Event.CONNECT,handleConnect);
		  _socket.addEventListener(Event.CLOSE,handleClose);
		  _socket.addEventListener(ProgressEvent.SOCKET_DATA,handleSocketData);
		  _socket.addEventListener(IOErrorEvent.IO_ERROR,handleIOError);
		  _socket.connect(_host,_port);
		}

		public function close():void{
			_socket.close();
			_socket.removeEventListener(Event.CONNECT,handleConnect);
			_socket.removeEventListener(Event.CLOSE,handleClose);
		  _socket.removeEventListener(ProgressEvent.SOCKET_DATA,handleSocketData);
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

		private function handleConnect(e:Event):void{
			trace("connected.");
			dispatchEvent(new Event(CsaShogiClient.CONNECTED));
		}

		private function handleClose(e:Event):void{
			trace("closed.");
			_socket.removeEventListener(Event.CONNECT,handleConnect);
			_socket.removeEventListener(Event.CLOSE,handleClose);
		  _socket.removeEventListener(ProgressEvent.SOCKET_DATA,handleSocketData);
		}

		private function handleSocketData(e:ProgressEvent):void{
			var response:String = e.target.readUTFBytes(e.target.bytesAvailable);
      trace(response);
      switch(_current_state)
      {
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
            _current_state = STATE_GAME;
			      dispatchEvent(new Event(CsaShogiClient.GAME_STARTED));
          }
          break;
        case STATE_START_WAITING:
          break;
        case STATE_GAME:
          break;
        case STATE_FINISHED:
          break;
      }
			dispatchEvent(new ServerMessageEvent(SERVER_MESSAGE,response));
    }

		private function handleIOError(e:IOErrorEvent):void{
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
