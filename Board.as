/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.system.System;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.CloseEvent;

  public class Board extends Canvas {
    
    public static const BAN_WIDTH:int = 410;
    public static const BAN_HEIGHT:int = 454;
    public static const BAN_LEFT_MARGIN:int = 185;
		public static const BAN_TOP_MARGIN:int = 10

    public static const KOMA_WIDTH:int = 43;
    public static const KOMA_HEIGHT:int = 48;
    public static const KOMADAI_WIDTH:int = 170;
    public static const KOMADAI_HEIGHT:int = 200;    
    
    [Bindable]
    [Embed(source = "/images/ban_kaya_a.png")]
    private var board_back:Class
    [Bindable]
    [Embed(source = "/images/masu_dot.png")]
    private var board_masu:Class
    [Embed(source = "/images/empty.png")]
    private var emptyImage:Class
    [Embed(source = "/images/Scoord_e.png")]
    private var board_scoord_e:Class
    [Embed(source = "/images/Gcoord_e.png")]
    private var board_gcoord_e:Class
    [Embed(source = "/images/Shand.png")]
    private var board_shand:Class
    [Embed(source = "/images/Ghand.png")]
    private var board_ghand:Class
    [Embed(source = "/images/bg_tatami.png")]
	private var board_bg:Class
    
    [Embed(source = "/images/white.png")]
    private var white:Class
    [Embed(source = "/images/white_r.png")]
    private var white_r:Class
    [Embed(source = "/images/black.png")]
    private var black:Class
    [Embed(source = "/images/black_r.png")]
    private var black_r:Class

	private var pSrc:PieceSource = new PieceSource();

	[Embed(source = "/sound/piece.mp3")]
	private var sound_piece:Class;
	private var _sound_piece:Sound = new sound_piece();

    public var handBoxes:Array;
    private var _name_labels:Array;
    private var _info_labels:Array;
    private var _turn_symbols:Array;
		private var _timers:Array;

    private var _cells:Array;
    private var _board_bg_image:Image = new Image();
    private var _board_back_image:Image = new Image();
    private var _board_masu_image:Image = new Image();
    private var _board_coord_image:Image = new Image();
    private var _board_shand_image:Image = new Image();
    private var _board_ghand_image:Image = new Image();
    
    private var _board_corrdinate:Array = new Array();

    private var _playerMoveCallback:Function;
    private var _timeoutCallback:Function;

    [Bindable]
    public var kifu_list:Array;

    private var _from:Point;
    private var _to:Point;
    private var _position:Kyokumen;

    private var _my_turn:int;

    private var _game_started:Boolean;

    private var _selected_square:Square;
    private var _last_square:Square;
    public var _piece_type:int = 0;
    public var _piece_sound_play:Boolean = true;

		private var _time_sente:int;
		private var _time_gote:int;
    
    //TODO Define the layout with mxml.
    public function Board() {
      super();
      _cells = new Array(9);
      for (var i:int; i < 9; i++ ) {
        _cells[i] = new Array(9);
      }
      
      this.width = BAN_WIDTH;
      this.height = BAN_HEIGHT;
      
      _board_bg_image.source = board_bg;
      _board_bg_image.setStyle('borderStyle','solid');
      _board_bg_image.setStyle('borderColor',0x888888);
      
      _board_back_image.width = BAN_WIDTH;
      _board_back_image.height = BAN_HEIGHT;
      _board_back_image.source = board_back;
      _board_back_image.x = BAN_LEFT_MARGIN;
      _board_back_image.y = BAN_TOP_MARGIN;
      
      _board_masu_image.source = board_masu;
      _board_masu_image.width = BAN_WIDTH;
      _board_masu_image.height = BAN_HEIGHT;

      _board_coord_image.width = BAN_WIDTH;
      _board_coord_image.height = BAN_HEIGHT;
      
      _board_shand_image.source = board_shand;
      _board_shand_image.x = BAN_LEFT_MARGIN + BAN_WIDTH + 5
      _board_shand_image.y = BAN_TOP_MARGIN + BAN_HEIGHT - KOMADAI_HEIGHT
      _board_ghand_image.source = board_ghand;
      _board_ghand_image.x = 10
      _board_ghand_image.y = 10
      
      addChild(_board_bg_image);
      addChild(_board_back_image);
      _board_back_image.addChild(_board_masu_image);
      _board_back_image.addChild(_board_coord_image);
      addChild(_board_shand_image);
      addChild(_board_ghand_image);
	
      handBoxes = new Array(2);
      _name_labels = new Array(2);
      _info_labels = new Array(2);
      _turn_symbols = new Array(2);
      _timers = new Array(2);
      for(i=0;i<2;i++){
        var hand:Canvas = new Canvas();
        
        hand.width = KOMADAI_WIDTH;
        hand.height = KOMADAI_HEIGHT;
        hand.x = i == 0 ? BAN_LEFT_MARGIN + BAN_WIDTH + 5 : 10;
        hand.y = i == 0 ? BAN_TOP_MARGIN + BAN_HEIGHT - hand.height : 10;
        handBoxes[i] = hand;
        addChild(hand);
        
 		var timer:GameTimer = new GameTimer();
		timer.addEventListener(GameTimer.CHECK_TIMEOUT,_checkTimeout);
		timer.x = hand.x + KOMADAI_WIDTH/2 - 40
		timer.y = BAN_TOP_MARGIN + BAN_HEIGHT/2 - 15 ;
		_timers[i] = timer;
		addChild(timer)

        var turn_symbol:Image = new Image();
        turn_symbol.x = 2
        turn_symbol.y = i == 0 ? 122 : 2
        _turn_symbols[i] = turn_symbol;
        var name_label:Label = new Label();
        name_label.setStyle('fontSize',12)
        name_label.setStyle('fontWeight','bold')
        name_label.x = turn_symbol.x + 20
        name_label.y = turn_symbol.y + 5
        _name_labels[i] = name_label;
        var info_label:Label = new Label();
        info_label.setStyle('fontSize',11)
        info_label.x = name_label.x
        info_label.y = name_label.y + 20
        _info_labels[i] = info_label;       

        var h_box:Canvas = new Canvas();
        h_box.setStyle('backgroundColor',0xddee88);
        h_box.setStyle('borderStyle','solid');
        h_box.width = KOMADAI_WIDTH - 10
        h_box.height = KOMADAI_HEIGHT - 30
        h_box.x = i == 0 ? hand.x + 10 : hand.x
        h_box.y = i == 0 ? BAN_TOP_MARGIN + 28 : BAN_TOP_MARGIN + hand.height + 55 ;
        h_box.addChild(turn_symbol);
        h_box.addChild(name_label);
        h_box.addChild(info_label);
        addChild(h_box);
      }
    }

    public function reset():void{
     if(_my_turn == Kyokumen.SENTE){
        _board_coord_image.source = board_scoord_e
      } else {
        _board_coord_image.source = board_gcoord_e
      }

      for (var i:int = 0; i < 9; i++ ) {
        for (var j:int = 0; j < 9;j++ ){
          if(_cells[i][j] != null){
            removeChild(_cells[i][j]);
          }
        }
      }
      for (i = 0; i < 9; i++ ) {
        for (j = 0; j < 9;j++ ){
          var square:Square;
          if(_my_turn == Kyokumen.SENTE){
            square = new Square(9-j,i+1);
            _cells[i][j] = square;
          } else {
            square = new Square(10-(9-j),10-(i+1));
            _cells[8-i][8-j] = square;
          }
          square.x = BAN_LEFT_MARGIN + 10 + j * KOMA_WIDTH;
          square.y = BAN_TOP_MARGIN + 10 + i * KOMA_HEIGHT;
          square.addEventListener(MouseEvent.MOUSE_UP,_squareMouseUpHandler);
          addChild(square);
        }
      }
      kifu_list = new Array();
      var kifuMove:Object = new Object();
      kifuMove.num = "0";
      kifuMove.move = "Start";
	  kifu_list.push(kifuMove);
    }

    public function setPosition(pos:Kyokumen):void{
      _position = pos
      for(var y:int=0;y<9;y++){
        for(var x:int=0;x<9;x++){
          var koma:Koma = _position.getKomaAt(new Point(x,y));
          if(koma != null){
            var images:Array = koma.ownerPlayer == _my_turn ? pSrc.koma_images_sente[_piece_type] : pSrc.koma_images_gote[_piece_type];
            var image_index:int = koma.type;// + (koma.isPromoted() ? 8 : 0)
            _cells[y][x].source = images[image_index];
          } else {
            _cells[y][x].source = emptyImage;
          }
        }
      }
      handBoxes[0].removeAllChildren();
      handBoxes[1].removeAllChildren();
      for(var i:int=0;i<2;i++){
        var hand:Komadai = _position.getKomadai(i);
        for(var j:int=0;j<8;j++){
          if(hand.getNumOfKoma(j) > 0){
            for(var k:int=0;k<hand.getNumOfKoma(j);k++){
              var handPiece:Square = new Square(Kyokumen.HAND+j,Kyokumen.HAND+j);
              if (i==_my_turn) handPiece.addEventListener(MouseEvent.MOUSE_UP,_handMouseUpHandler);
              images = i == _my_turn ? pSrc.koma_images_sente[_piece_type] : pSrc.koma_images_gote[_piece_type];
              handPiece.source = images[j];
              handPiece.x= 10 + (KOMADAI_WIDTH-20)/2 * ((j-1)%2) + (KOMADAI_WIDTH/(j == 7 ? 1.2 : 2)-35)*k/hand.getNumOfKoma(j)
              handPiece.y= 10 + (KOMADAI_HEIGHT-20)/4 * int((j-1)/2)
              handBoxes[i == _my_turn ? 0 : 1].addChild(handPiece);
            }
          }
        }
      }
    }

    public function makeMove(move:String,withSound:Boolean=true):void{
      var mv:Movement = _position.generateMovementFromString(move);
			var running_timer:int = _my_turn == _position.turn ? 0 : 1;

			var time:int = mv.time;

			_timers[running_timer].suspend();
			_timers[running_timer].accumulateTime(time);
			_timers[1-running_timer].resume();

      _position.move(mv);
      if (_last_square != null) _last_square.setStyle('backgroundColor',undefined);
      setPosition(_position);
      _last_square = _cells[mv.to.y][mv.to.x]
      _last_square.setStyle('backgroundColor','0xCC3333'); 
      if (_piece_sound_play && withSound) _sound_piece.play();
      
      var kifuMove:Object = new Object();
      kifuMove.num = kifu_list.length;
      kifuMove.move = _position.generateWesternNotationFromMovement(mv);
      kifuMove.moveStr = move;
      kifuMove.moveKIF = _position.generateKIFTextFromMovement(mv);
	    kifu_list.push(kifuMove);
	  }

    public function setMoveCallback(callback:Function):void{
      _playerMoveCallback = callback;
    }

    public function setTimeoutCallback(callback:Function):void{
      _timeoutCallback = callback;
    }

    public function startGame(my_turn:int,player_names:Array,time_total:int,time_byoyomi:int):void{
      trace("game started");
      _my_turn = my_turn;
      reset();
      _position = new Kyokumen();
      setPosition(_position);
      _name_labels[0].text = player_names[_my_turn]; 
      _name_labels[1].text = player_names[1-_my_turn];
      _info_labels[0].text = "R:1000, (Country)"
      _info_labels[1].text = "R:1000, (Country)"
      _turn_symbols[0].source = _my_turn == Kyokumen.SENTE ? black : white;
      _turn_symbols[1].source = _my_turn == Kyokumen.SENTE ? white_r : black_r;
			_timers[0].reset(time_total,time_byoyomi);
			_timers[1].reset(time_total,time_byoyomi);
			_timers[_my_turn == Kyokumen.SENTE ? 0 : 1].start();
      _game_started = true;
    }

    public function endGame():void{
      trace("game end");
			_timers[0].stop();
			_timers[1].stop();
	    if(_selected_square != null){
        _selected_square.setStyle('backgroundColor',undefined);
        _from = null;
        _selected_square = null;
      }
      _game_started = false;
    }
	
		public function timeout():void{
			var running_timer:int = _my_turn == _position.turn ? 0 : 1;
			_timers[running_timer].timeout();
		}

	public function get my_turn():int{
		return _my_turn;
	}
    public function get position():Kyokumen{
      return _position;
    }
    public function setPieceType(i:int):void{
    	_piece_type = i;
    	setPosition(_position);
    }

    public function monitor(game_info:String,watch_user:Object):void{
      trace("MONITOR");
      var match:Array;
      if (game_info.split("\n")[0].match(/^##\[MONITOR2\]\[.*\] V2$/)){
        _startMonitor(game_info,watch_user);
      } else if(match = game_info.split("\n")[0].match(/^##\[MONITOR2\]\[.*\] ([-+][0-9]{4}.{2})$/)) {
        var time:String = game_info.split("\n")[1].match(/^##\[MONITOR2\]\[.*\] (T.*)$/)[1];
        makeMove(match[1] + ',' + time);
      } else {
        return;
      }
    }

    private function _startMonitor(game_info:String,watch_user:Object):void{
      var names:Array = new Array(2);
      var total_time:int;
      var byoyomi:int;
      var current_turn:int;
      var last_move:Point;
      var moves:Array = new Array();
      for each(var line:String in game_info.split("\n")){
        var match:Array = line.match(/^##\[MONITOR2\]\[.*\] (.*)$/);
        if(match != null && match[1]){
          var token:String = match[1];
          if(token.indexOf("Name+") == 0){
            var name:String = token.match(/Name\+:(.*)/)[1]
            names[0] = name;
            _my_turn = name == watch_user.name ? Kyokumen.SENTE : Kyokumen.GOTE;
          } else if (token.indexOf("Name-") == 0){
            names[1] = token.match(/Name\-:(.*)/)[1];
          } else if (token.indexOf("$EVENT:") == 0) {
            var time_match:Array = token.match(/\$EVENT:(.*)\-(.*)\-(.*?)\+/)
            total_time = parseInt(time_match[2]);
            byoyomi = parseInt(time_match[3]);
          } else if (token.indexOf("Last_Move") == 0){
            var x:int = parseInt(token.substr(13,1));
            var y:int = parseInt(token.substr(14,1));
            last_move = Kyokumen.translateHumanCoordinates(new Point(x,y));
          } else if (token.match(/([-+][0-9]{4}.{2}$)/)) {
            var move_and_time:Object = new Object();
            move_and_time.move = token
            moves.push(move_and_time);
          } else if (token.match(/(T.*)$/)){
            Object(moves[moves.length - 1]).time = token;
          }
        }
      }
      var kyokumen_str:String = _parsePosition(game_info);

      if(kyokumen_str != ""){
        reset();
        _position = new Kyokumen();
        _position.loadFromString(_parsePosition(game_info));
        setPosition(_position);
      }

      _name_labels[0].text = names[_my_turn];
      _name_labels[1].text = names[1-_my_turn];
      _info_labels[0].text = "R:1000, (Country)"
      _info_labels[1].text = "R:1000, (Country)"
      _turn_symbols[0].source = _my_turn == Kyokumen.SENTE ? black : white;
      _turn_symbols[1].source = _my_turn == Kyokumen.SENTE ? white_r : black_r;
      trace("Byoyomi="+byoyomi.toString());
      _timers[0].reset(total_time,byoyomi);
      _timers[1].reset(total_time,byoyomi);

			var turn:int = Kyokumen.SENTE;
      var running_timer:int = turn == _my_turn ? 0 : 1;
      _timers[running_timer].start();
      _timers[1-running_timer].stop();
      if(moves.length > 0){
        for each(var move:Object in moves){
          makeMove(move.move + "," + move.time,false);
        }
      }
      if(last_move){
        var _last_square:Square = _cells[last_move.y][last_move.x];
        _last_square.setStyle('backgroundColor','0xCC3333');      
      }
    }

    private function _parsePosition(game_info:String):String{
      var lines:Array = game_info.split("\n");
      var kyokumen_str:String = "";
      for each (var line:String in lines ){
        var match:Array = line.match(/##\[MONITOR2\]\[.*\] (P[0-9+-].*)/);
        if(match != null){
          kyokumen_str += match[1] + "\n";
        }
      }
      return kyokumen_str;
    }

    private function _squareMouseUpHandler(e:MouseEvent):void {
      if(_game_started && _position.turn == _my_turn){
        var x:int = e.currentTarget.coord_x;
        var y:int = e.currentTarget.coord_y;
        if(_from == null){
          var koma:Koma = _position.getKomaAt(Kyokumen.translateHumanCoordinates(new Point(x,y)));
          if( koma != null && koma.ownerPlayer == _my_turn){
            e.currentTarget.setStyle('backgroundColor','0x33CCCC');
            _selected_square = Square(e.currentTarget);
            _from = new Point(x,y);
          }
        } else {
          koma = _position.getKomaAt(Kyokumen.translateHumanCoordinates(new Point(x,y)));
          _selected_square.setStyle('backgroundColor',undefined);
          if( koma != null && koma.ownerPlayer == _my_turn){
          	_from = null;
          	_selected_square = null;
          } else {
            _to = new Point(x,y);
            if(_position.cantMove(_from,_to)){
            	_from = null;
            	_to = null;
            	_selected_square = null;
            } else if(_position.canPromote(_from,_to)){
              Alert.show("Promote?","",Alert.YES | Alert.NO,Canvas(e.currentTarget),_promotionHandler);
            } else {
              _playerMoveCallback(_from,_to,false);
              _from = null;
              _to = null;
            }
          }
        }
      }
    }

    private function _promotionHandler(e:CloseEvent):void{
      _playerMoveCallback(_from,_to,e.detail == Alert.YES);
      _from = null;
      _to = null;
    }

    private function _handMouseUpHandler(e:MouseEvent):void{
      if(_game_started && _position.turn == _my_turn){
        if(_from == null){
          e.currentTarget.setStyle('backgroundColor','0x33CCCC');
          _selected_square = Square(e.currentTarget);
          _from = new Point(e.currentTarget.coord_x,e.currentTarget.coord_y);
        } else {
          if(_selected_square == e.currentTarget){
            _selected_square.setStyle('backgroundColor',undefined);
            _from = null;
            _selected_square = null;
          }
        }
      }
    }

		private function _checkTimeout(e:Event):void{
			_timeoutCallback();
		}
		
	public function replayMoves(n:int):void{
		  if (_last_square != null){
		  	_last_square.setStyle('backgroundColor',undefined);
		  	_last_square = null;
		  }
		  _position.turn = Kyokumen.SENTE;
		  _position.getKomadai(0).clearKoma();
		  _position.getKomadai(1).clearKoma();
		  _position.loadFromString(_position.initialPositionStr());
		  if (n >= 1){
			  for (var i:int = 1; i <= n; i++ ) {
			      var mv:Movement = _position.generateMovementFromString(kifu_list[i].moveStr);
			      _position.move(mv);		  	
			  }
		      _last_square = _cells[mv.to.y][mv.to.x]
		      _last_square.setStyle('backgroundColor','0xCC3333');
		  }
      	  setPosition(_position);
	}
	
	public function copyKIFtoClipboard():void{
		var KIFDataText:String = "";
		KIFDataText += "開始日時:\n";
		KIFDataText += "棋戦:the 81-square Universe\n";
		KIFDataText += "手合割:平手\n";
		KIFDataText += "先手:" + _name_labels[0].text + "\n";
		KIFDataText += "後手:" + _name_labels[1].text + "\n";
		KIFDataText += "手数----指手---------消費時間--\n";
		for (var i:int = 1; i < kifu_list.length ; i++){
			KIFDataText += "   " + String(i) + " ";
			KIFDataText += kifu_list[i].moveKIF + "\n";
		}
		System.setClipboard(KIFDataText);
	}

  }
}
