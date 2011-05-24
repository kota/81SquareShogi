/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.system.System;
	import flash.utils.Timer;
	import mx.containers.HBox;
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	import mx.events.StateChangeEvent;
	import mx.managers.CursorManager;
	import BoardArrow;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.CloseEvent;

  public class Board extends Canvas {
    
    public static const BAN_WIDTH:int = 300;
    public static const BAN_HEIGHT:int = 400;
    public static const BAN_LEFT_MARGIN:int = 200;
	public static const BAN_TOP_MARGIN:int = 130;
	public static const BAN_EDGE_PADDING:int = 0;
    public static const KOMA_WIDTH:int = 100;
    public static const KOMA_HEIGHT:int = 100;
    public static const KOMADAI_WIDTH:int = 700;
    public static const KOMADAI_HEIGHT:int = 100;
	public static const MY_HAND_X:int = 0;
	public static const MY_HAND_Y:int = BAN_TOP_MARGIN + BAN_HEIGHT + (BAN_TOP_MARGIN - KOMA_HEIGHT)/2;
	public static const HIS_HAND_X:int = 0;
	public static const HIS_HAND_Y:int = (BAN_TOP_MARGIN - KOMA_HEIGHT)/2;
	public static const MAX_ARROWS:int = 8;
	public static const ARROWS_SELF:int = 0;
	public static const ARROWS_PUBLIC:int = 1;
	public static const HOVER:String = "hover";
    
    [Bindable]
//    [Embed(source = "/images/ban_kaya_a.png")]
//    private var board_back:Class
    [Bindable]
    [Embed(source = "/images/masu_dot.png")]
    private var board_masu:Class
    [Embed(source = "/images/empty.png")]
    private var emptyImage:Class
    [Embed(source = "/images/dead.png")]
    private var deadSquare:Class
    [Embed(source = "/images/kitao/Scoord.png")]
    private var scoord1:Class
    [Embed(source = "/images/kitao/Gcoord.png")]
    private var gcoord1:Class
    [Embed(source = "/images/hidetchi/Scoord.png")]
    private var scoord3:Class
    [Embed(source = "/images/hidetchi/Gcoord.png")]
    private var gcoord3:Class
    [Embed(source = "/images/fujita/Scoord.png")]
    private var scoord4:Class
    [Embed(source = "/images/fujita/Gcoord.png")]
    private var gcoord4:Class
//    [Embed(source = "/images/Shand.png")]
//    private var board_shand:Class
//    [Embed(source = "/images/Ghand.png")]
//    private var board_ghand:Class
    [Embed(source = "/images/kitao/ban.png")]
	private var board_bg1:Class
    [Embed(source = "/images/hidetchi/ban.png")]
	private var board_bg3:Class
    [Embed(source = "/images/fujita/ban.png")]
	private var board_bg4:Class
    [Embed(source = "/images/white.png")]
    private var white:Class
    [Embed(source = "/images/white_r.png")]
    private var white_r:Class
    [Embed(source = "/images/black.png")]
    private var black:Class
    [Embed(source = "/images/black_r.png")]
    private var black_r:Class
    [Embed(source = "/images/gold_medal.png")]
	private var Medal:Class;

	private var _bg_images:Array = new Array(board_bg1, board_bg1, board_bg3, board_bg4, board_bg1, board_bg1, board_bg1);
	private var _scoord_images:Array = new Array(scoord1, scoord1, scoord3, scoord4, scoord1, scoord1, scoord1);
	private var _gcoord_images:Array = new Array(gcoord1, gcoord1, gcoord3, gcoord4, gcoord1, gcoord1, gcoord1);
	private var pSrc:PieceSource = new PieceSource();

	[Embed(source = "/sound/piece.mp3")]
	private var sound_piece:Class;
	private var _sound_piece:Sound = new sound_piece();
	[Embed(source = "/sound/piece_double.mp3")]
	private var sound_piece_double:Class;
	private var _sound_piece_double:Sound = new sound_piece_double();
	private const IMAGE_DIRECTORY:String = "http://81dojo.com/dojo/images/";

    public var handBoxes:Array;
	public var infoBoxes:Array;
    public var name_labels:Array;
    private var _info_labels:Array;
    private var _turn_symbols:Array;
	public var timers:Array;
	private var _avatar_images:Array;
	private var _player_flags:Array;

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
	private var _timerLagCallback:Function;
	private var _addMyArrowCallback:Function;
	private var _hoverPieceCallback:Function;
	private var _grabPieceCallback:Function;

    [Bindable]
    public var kifu_list:Array;
	public var kifu_list_self:Array;
	private var _arrows:Array = new Array();
    private var _from:Point;
    private var _to:Point;
    private var _position:Kyokumen;
	private var _last_pos:Kyokumen;

	private var _player_infos:Array = new Array;
    private var _my_turn:int;
    private var _in_game:Boolean;
	private var _move_sent:Boolean = false;
	private var _client_timeout:Boolean;

    private var _selected_square:Square;
    private var _last_to_square:Square;
	private var _last_from_square:Square;
	private var _oppo_selected_square:Square;
	private var _arrow_from_type:int;
	private var _arrow_from:Point;
	private var _arrow_to:Point = new Point();
	private var _pieceGrab:Boolean = false;
	private var _hoverImage:Image = new Image();
	private var _hoverOwner:int;
	private var _hoverPiece:int;
	private var _centerX:int;
	private var _centerY:int;
	private var _hoverTimer:Timer = new Timer(100, 1);
	public var kid:int;
	public var opening:String = "";
	public var piece_type:int = 0;
    public var piece_type34:int = 0;
	public var hold_piece:Boolean = true;
	public var highlight_movable:Boolean = false;
	public var gameType:String;
	public var superior:int = Kyokumen.SENTE;
    public var piece_sound_play:Boolean = true;
	public var post_game:Boolean = false;
	public var isPlayer:Boolean = false;
	public var isStudyHost:Boolean = false;
	public var onListen:Boolean = false;
	public var viewing:Boolean = false;
	public var studyOrigin:int;
	public var study_list:Array;
	public var since_last_move:int = 0;
	public var studyOn:Boolean = false;
	public var rematch:Array = new Array(2);
	public var sendHover:Boolean = true;

	private var _time_sente:int;
	private var _time_gote:int;
	private const filterTournament:ColorMatrixFilter = new ColorMatrixFilter([1, 0, 0, 0, 10, 0, 1, 0, 0, 0, 0, 0, 1, 0, 70, 0, 0, 0, 1, 0 ]);
    
    //TODO Define the layout with mxml.
    public function Board() {
      super();
      _cells = new Array(4);
      for (var i:int; i < 4; i++ ) {
        _cells[i] = new Array(3);
      }
      
      this.width = BAN_WIDTH;
      this.height = BAN_HEIGHT;

      _board_bg_image.source = _bg_images[piece_type34];
//      _board_bg_image.setStyle('borderStyle','solid');
//      _board_bg_image.setStyle('borderColor', 0x888888);
      
//      _board_back_image.width = _board_bg_image.width;
//      _board_back_image.height = _board_bg_image.height;

      _board_back_image.width = 700;
      _board_back_image.height = 660;
      
//      _board_masu_image.source = board_masu;
//      _board_masu_image.width = _board_back_image.width;
//      _board_masu_image.height = _board_back_image.height;

      _board_coord_image.width = 700;
      _board_coord_image.height = 660;
      
//      _board_shand_image.source = board_shand;
//      _board_shand_image.x = BAN_LEFT_MARGIN + BAN_WIDTH + 5
//      _board_shand_image.y = BAN_TOP_MARGIN + BAN_HEIGHT - KOMADAI_HEIGHT
//      _board_ghand_image.source = board_ghand;
//      _board_ghand_image.x = 10
//      _board_ghand_image.y = 10
      
      addChild(_board_bg_image);
      addChild(_board_back_image);
//      _board_back_image.addChild(_board_masu_image);
      addChild(_board_coord_image);
//      addChild(_board_shand_image);
//      addChild(_board_ghand_image);
	
      handBoxes = new Array(2);
	  infoBoxes = new Array(2);
      name_labels = new Array(2);
      _info_labels = new Array(2);
      _turn_symbols = new Array(2);
      timers = new Array(2);
	  _avatar_images = new Array(2);
	  _player_flags = new Array(2);
      for(i=0;i<2;i++){
        var hand:Canvas = new Canvas();
        
        hand.width = KOMADAI_WIDTH;
        hand.height = KOMADAI_HEIGHT;
        hand.x = i == 0 ? MY_HAND_X : HIS_HAND_X;
        hand.y = i == 0 ? MY_HAND_Y : HIS_HAND_Y;
        handBoxes[i] = hand;
        
 		var timer:GameTimer = new GameTimer();
		timer.addEventListener(GameTimer.CHECK_TIMEOUT, _checkTimeout);
		timer.addEventListener(GameTimer.TIMER_LAG, _checkTimerLag);
		timer.x = 50;
		timer.y = BAN_TOP_MARGIN + BAN_HEIGHT/2 + (i == 1 ? -70 : 40);
		timers[i] = timer;
		addChild(timer);
		var flag_loader:SWFLoader = new SWFLoader();
		flag_loader.width = 56;
		flag_loader.height = 44;
		flag_loader.x = 65;
		flag_loader.y = BAN_TOP_MARGIN + BAN_HEIGHT/2 + (i == 1 ? -220 : 180);
		_player_flags[i] = flag_loader;

        var turn_symbol:Image = new Image();
        turn_symbol.x = 2;
        turn_symbol.y = i == 1 ? 137 : 0;
        _turn_symbols[i] = turn_symbol;
		var avatar_image:Canvas = new Canvas();
		avatar_image.x = 9;
		avatar_image.y = i == 1 ? 6 : 47;
		avatar_image.width = KOMADAI_WIDTH - 42
		avatar_image.height = avatar_image.width
		_avatar_images[i] = avatar_image;
        var name_label:Label = new Label();
        name_label.setStyle('fontSize', 12);
        name_label.setStyle('fontWeight', 'bold');
        name_label.x = turn_symbol.x + 20;
        name_label.y = turn_symbol.y + 5;
		name_label.doubleClickEnabled = true;
        name_labels[i] = name_label;
        var info_label:Label = new Label();
        info_label.setStyle('fontSize', 11);
        info_label.x = name_label.x;
        info_label.y = name_label.y + 20;
        _info_labels[i] = info_label;

        var i_box:Canvas = new Canvas();
        i_box.setStyle('backgroundColor',0xffeeaa);
        i_box.setStyle('borderStyle', 'solid');
//		i_box.setStyle('borderThickness', 2);
		i_box.horizontalScrollPolicy = "off";
		i_box.verticalScrollPolicy = "off";
        i_box.width = 152;
        i_box.height = 185;
        i_box.x = BAN_LEFT_MARGIN + BAN_WIDTH + 45;
        i_box.y = i == 0 ? BAN_TOP_MARGIN + BAN_HEIGHT - 152 : BAN_TOP_MARGIN - 33;
        i_box.addChild(turn_symbol);
        i_box.addChild(name_label);
        i_box.addChild(info_label);
		i_box.addChild(avatar_image);
		infoBoxes[i] = i_box;
        addChild(i_box);
		
        addChild(hand);
		addChild(flag_loader);
      }
	  _arrows[ARROWS_SELF] = new Array();
	  _arrows[ARROWS_PUBLIC] = new Array();
	  _hoverImage.alpha = 0.3;
	  _hoverImage.filters = [new ColorMatrixFilter([0, 0, 0, 0, 0, 0.25, 0.5, 0.25, 0, 0 , 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ])];
      _centerX = BAN_LEFT_MARGIN + BAN_EDGE_PADDING + 4.5 * KOMA_WIDTH + 1;
      _centerY = BAN_TOP_MARGIN + BAN_EDGE_PADDING + 4.5 * KOMA_HEIGHT + 1;
    }

    public function resetBoard():void{
     if (_my_turn == Kyokumen.SENTE) {
        _board_coord_image.source = _scoord_images[piece_type34];
      } else {
        _board_coord_image.source = _gcoord_images[piece_type34];
      }

      for (var i:int = 0; i < 4; i++ ) {
        for (var j:int = 0; j < 3;j++ ){
          if(_cells[i][j] != null){
            removeChild(_cells[i][j]);
          }
        }
      }
      for (i = 0; i < 4; i++ ) {
        for (j = 0; j < 3;j++ ){
          var square:Square;
          if(_my_turn == Kyokumen.SENTE){
            square = new Square(9-j,i+1);
            _cells[i][j] = square;
          } else {
            square = new Square(7 + j,4 - i);
            _cells[3-i][2-j] = square;
          }

//		  if (_my_turn == Kyokumen.SENTE) {
//			  if (i >= 4 || j >= 3) square.dead = true;
//		  } else {
//			  if (i <= 4 || j <= 5) square.dead = true;
//		  }

          square.x = BAN_LEFT_MARGIN + BAN_EDGE_PADDING + j * KOMA_WIDTH + 1;
          square.y = BAN_TOP_MARGIN + BAN_EDGE_PADDING + i * KOMA_HEIGHT + 1;
		  square.addEventListener(MouseEvent.MOUSE_DOWN, _squareMouseDownHandler);
          square.addEventListener(MouseEvent.MOUSE_UP, _squareMouseUpHandler);
		  square.addEventListener(MouseEvent.ROLL_OUT, _squareMouseOutHandler);
		  square.addEventListener(MouseEvent.ROLL_OVER, _squareMouseOverHandler);
		  square.addEventListener(Square.STAY, _squareStayHandler);
          addChild(square);
        }
      }
    }
	
	public function initializeKifu():void {
	  kifu_list = new Array();
	  kifu_list_self = new Array();
      var kifuMove:Object = new Object();
      kifuMove.num = "0";
      kifuMove.move = "Start";
      kifu_list.push(kifuMove);
	  study_list = new Array();
	}

	private function _initializeKyokumen(str:String):void {
		_position = new Kyokumen(str);
		_last_pos = new Kyokumen(str);
	}

    public function setPosition(pos:Kyokumen):void {
      _position = pos
      for(var y:int=0;y<4;y++){
        for(var x:int=0;x<3;x++){
          var koma:Koma = _position.getKomaAt(new Point(x,y));
          if(koma != null){
            var images:Array = koma.ownerPlayer == _my_turn ? pSrc.koma_images_sente[piece_type34] : pSrc.koma_images_gote[piece_type34];
            var image_index:int = koma.type;// + (koma.isPromoted() ? 8 : 0)
//			if (image_index == Koma.OU && koma.ownerPlayer == superior) image_index += Koma.PROMOTE;
            _cells[y][x].source = images[image_index];
          } else {
            _cells[y][x].source = emptyImage;
          }
		  if (_cells[y][x].dead) _cells[y][x].source = deadSquare;
        }
      }
      handBoxes[0].removeAllChildren();
      handBoxes[1].removeAllChildren();
      for(var i:int=0;i<2;i++){
        var hand:Komadai = _position.getKomadai(i);
		var hand_sum:int = hand.getNumOfKoma(0) + hand.getNumOfKoma(1) + hand.getNumOfKoma(2) + hand.getNumOfKoma(3);
		var hand_count:int = 0;
        for(var j:int=0;j<4;j++){
          if(hand.getNumOfKoma(j) > 0){
            for(var k:int=0;k<hand.getNumOfKoma(j);k++){
              var handPiece:Square = new Square(Kyokumen.HAND + j, Kyokumen.HAND + j);
			  handPiece.addEventListener(MouseEvent.MOUSE_DOWN, _handMouseDownHandler);
              handPiece.addEventListener(MouseEvent.MOUSE_UP,_handMouseUpHandler);
              images = i == _my_turn ? pSrc.koma_images_sente[piece_type34] : pSrc.koma_images_gote[piece_type34];
              handPiece.source = images[j];
              handPiece.x = KOMADAI_WIDTH / 2 - KOMA_WIDTH / 2 * hand_sum + KOMA_WIDTH * hand_count;
              handPiece.y = 0;
              handBoxes[i == _my_turn ? 0 : 1].addChild(handPiece);
			  hand_count += 1;
            }
          }
        }
      }
    }

    public function makeMove(move:String, actual:Boolean, withSound:Boolean):void {
		var isSoundDouble:Boolean;
		_move_sent = false;
		if (!actual) {
			var mv:Movement = _position.generateMovementFromString(move);
			var kifuMove:Object = new Object();
			kifuMove.num = "*" + kifu_list_self.length;										//No. of the Move
			kifuMove.move = _position.generateWesternNotationFromMovement(mv);	//Western Notation
			kifuMove.moveStr = move;												//CSA
			kifuMove.moveKIF = _position.generateKIFTextFromMovement(mv);			//Japanese Notation
			kifu_list_self.push(kifuMove);
		} else {
			mv = _last_pos.generateMovementFromString(move);
			if (!viewing) {
				var running_timer:int = _my_turn == _last_pos.turn ? 0 : 1;
				var time:int = mv.time;
				timers[running_timer].accumulateTime(time);
				timers[running_timer].suspend();
				timers[1 - running_timer].resume();
			}
			kifuMove = new Object();
			kifuMove.num = kifu_list.length;										//No. of the Move
			kifuMove.move = _last_pos.generateWesternNotationFromMovement(mv);	//Western Notation
			kifuMove.moveStr = move;												//CSA
			kifuMove.moveKIF = _last_pos.generateKIFTextFromMovement(mv);			//Japanese Notation
			kifu_list.push(kifuMove);
		}
		if (actual) {
			_last_pos.move(mv);
			if (piece_sound_play && withSound) isSoundDouble = _last_pos.isSoundDouble(mv.to);
			if (onListen) _position.loadFromString(_last_pos.toString());
		} else {
			_position.move(mv);
			if (piece_sound_play && withSound) isSoundDouble = _position.isSoundDouble(mv.to);
		}
		if (_oppo_selected_square) {
			_oppo_selected_square.setStyle('backgroundColor', undefined);
			_oppo_selected_square = null;
		}
		if (!actual || onListen){
			if (_last_to_square != null) _last_to_square.setStyle('backgroundColor', undefined);
			if (_last_from_square != null) _last_from_square.setStyle('backgroundColor', undefined);
			setPosition(_position);
			if (_selected_square != null) _selected_square.showPiece();
			_last_to_square = _cells[mv.to.y][mv.to.x];
			_last_to_square.setStyle('backgroundColor', '0xFF5555');
			if (mv.from.x < Kyokumen.HAND) {
				_last_from_square = _cells[mv.from.y][mv.from.x];
				_last_from_square.setStyle('backgroundColor', '0xFF5555'); 
			}
			if (contains(_hoverImage)) removeChild(_hoverImage);
			_from = null;
		}
//		if (_pieceGrab) {
//			_pieceGrab = false;
//			if (_selected_square != null) _selected_square.setStyle('backgroundColor', undefined);
//			if (hold_piece) CursorManager.removeCursor(CursorManager.currentCursorID);
//		}
        if (piece_sound_play && withSound) {
			if (isSoundDouble) {
				_sound_piece_double.play();
			} else {
				_sound_piece.play();
			}
		}
	  }

    public function setMoveCallback(callback:Function):void{
      _playerMoveCallback = callback;
    }

    public function setTimeoutCallback(callback:Function):void{
      _timeoutCallback = callback;
    }
	
    public function setTimerLagCallback(callback:Function):void{
      _timerLagCallback = callback;
    }
	
	public function setAddMyArrowCallback(callback:Function):void {
		_addMyArrowCallback = callback;
	}
	
	public function setHoverPieceCallback(callback:Function):void {
		_hoverPieceCallback = callback;
	}
	
	public function setGrabPieceCallback(callback:Function):void {
		_grabPieceCallback = callback;
	}

    public function startGame(kyokumen_str:String, my_turn:int, player_infos:Array, time_total:int, time_byoyomi:int, moves:Array = null):void {
      trace("game started");
	  rematch[0] = false;
	  rematch[1] = false;
	  isPlayer = true;
	  _player_infos = player_infos;
	  _player_infos[0].labelColor = 0x000000;
	  _player_infos[1].labelColor = 0x000000;
      _my_turn = my_turn;
	  if (_player_infos[_my_turn].game_name.match(/\-\-..\-\d+\-\d+$/)) _board_bg_image.filters = [filterTournament];
      resetBoard();
	  trace("OK");
	  initializeKifu();
      _initializeKyokumen(kyokumen_str);
      setPosition(_position);
	  _arrangeInfos();
	  timers[0].reset(time_total,time_byoyomi);
	  timers[1].reset(time_total,time_byoyomi);
	  timers[_my_turn == _position.turn ? 0 : 1].start();
      if (moves) {
		  if (moves.length > 0) {
			for each(var move:Object in moves) {
				if (move.move == "%TORYO") {
					var kifuMove:Object = new Object();
					kifuMove.num = kifu_list.length;										//No. of the Move
					kifuMove.move = (_last_pos.turn == Kyokumen.SENTE ? "▲" : "△") + "Resign (" + move.time.substr(1) + ")";	//Western Notation
					kifuMove.moveStr = "%TORYO";												//CSA
					kifuMove.moveKIF = "投了   ( " + int(move.time.substr(1)/60) + ":" + move.time.substr(1) % 60 + "/)";			//Japanese Notation
					kifu_list.push(kifuMove);
					timers[_my_turn == _last_pos.turn ? 0 : 1].accumulateTime(parseInt(move.time.substr(1)));
				} else {
					makeMove(move.move + "," + move.time, true, false);
				}
			}
		  }
	  }
      _in_game = true;
	  _client_timeout = false;
	  studyOrigin = 0;
    }
	
	private function _arrangeInfos():void {
      _turn_symbols[0].source = _my_turn == Kyokumen.SENTE ? black : white;
      _turn_symbols[1].source = _my_turn == Kyokumen.SENTE ? white_r : black_r;
      name_labels[0].text = _player_infos[_my_turn].name;
      name_labels[1].text = _player_infos[1 - _my_turn].name;
      _info_labels[0].text = "R:" + _player_infos[_my_turn].rating + ", " + (_player_infos[_my_turn].titleName == "" ? _player_infos[_my_turn].rank : _player_infos[_my_turn].titleName);
      _info_labels[1].text = "R:" + _player_infos[1 - _my_turn].rating + ", " + (_player_infos[1 - _my_turn].titleName == "" ? _player_infos[1 - _my_turn].rank : _player_infos[1 - _my_turn].titleName);
	  var avatar:Image = new Image();
	  avatar.source =  IMAGE_DIRECTORY + "avatars34/" + (_player_infos[_my_turn].avatar ? _player_infos[_my_turn].avatar : _player_infos[_my_turn].rank) + ".jpg";
	  _avatar_images[0].addChild(avatar);
	  if (!viewing) _avatar_images[0].addChild(InfoFetcher.medalCanvas(_player_infos[_my_turn]));
	  avatar = new Image();
	  avatar.source =  IMAGE_DIRECTORY + "avatars34/" + (_player_infos[1 - _my_turn].avatar ? _player_infos[1 - _my_turn].avatar : _player_infos[1 - _my_turn].rank) + ".jpg";
	  _avatar_images[1].addChild(avatar);
	  if (!viewing) _avatar_images[1].addChild(InfoFetcher.medalCanvas(_player_infos[1 - _my_turn]));
	  _player_flags[0].source = IMAGE_DIRECTORY + "flags_m/" + String(_player_infos[_my_turn].country_code + 1000).substring(1) + ".swf";
	  _player_flags[1].source = IMAGE_DIRECTORY + "flags_m/" + String(_player_infos[1 - _my_turn].country_code + 1000).substring(1) + ".swf";
	}
	
	public function flipBoard():void {
		var infoBoxBorderColor:Array = new Array(2);
		var nameLabelColor:Array = new Array(2);
		for (var i:int = 0; i < 2; i++) {
			infoBoxBorderColor[i] = infoBoxes[i].getStyle('borderColor');
			nameLabelColor[i] = name_labels[i].getStyle('color');
		}
		while (_avatar_images[0].numChildren > 0) _avatar_images[0].removeChildAt(0);
		while (_avatar_images[1].numChildren > 0) _avatar_images[1].removeChildAt(0);
		if (_last_to_square != null) {
			var i_last_to:int = _last_to_square.coord_x;
			var j_last_to:int = _last_to_square.coord_y;
		}
		if (_last_from_square != null) {
			var i_last_from:int = _last_from_square.coord_x;
			var j_last_from:int = _last_from_square.coord_y;
		}
		var timer_tmp:GameTimer = timers[0];
		timers[0] = timers[1];
		timers[1] = timer_tmp;
		for (i = 0; i < 2; i++) {
			timers[i].y = BAN_TOP_MARGIN + BAN_HEIGHT/2 + (i == 1 ? -40 : 10);
		}
		_my_turn = 1 - _my_turn;
		_arrangeInfos();
		for (i = 0; i < 2; i++) {
			infoBoxes[i].setStyle('borderColor', infoBoxBorderColor[1 - i]);
			name_labels[i].setStyle('color', nameLabelColor[1 - i]);
		}
		resetBoard();
		setPosition(_position);
		if (_last_to_square != null) {
			_last_to_square = _cells[j_last_to - 1][9 - i_last_to];
			_last_to_square.setStyle('backgroundColor', '0xCC3333');
		}
		if (_last_from_square != null) {
			_last_from_square = _cells[j_last_from - 1][9 - i_last_from];
			_last_from_square.setStyle('backgroundColor', '0xFF5555');
		}
		cancelSquareSelect();
		
		var arrow_type:int;
		if (isStudyHost || onListen) {
			arrow_type = ARROWS_PUBLIC;
		} else {
			arrow_type = ARROWS_SELF;
		}
		for each(var arrow:BoardArrow in _arrows[arrow_type]) {
			arrow.erase();
			removeChild(arrow);
			arrow.drawArrow(_my_turn);
			addChild(arrow);
		}
//		if (_hoverImage.visible) _hoverImage.source = _my_turn == _hoverOwner ? pSrc.koma_images_sente[piece_type34][_hoverPiece] : pSrc.koma_images_gote[piece_type34][_hoverPiece];
		if (contains(_hoverImage)) _hoverImage.source = null;
	}

    public function endGame():void{
      trace("game end");
			timers[0].stop();
			timers[1].stop();
		    name_labels[0].setStyle('color', _player_infos[_my_turn].labelColor);
		    name_labels[1].setStyle('color', _player_infos[1 - _my_turn].labelColor);
		cancelSquareSelect();
      _in_game = false;
	  _client_timeout = false;
    }
	
	public function cancelSquareSelect():void {
	   if(_selected_square != null){
        _selected_square.setStyle('backgroundColor', undefined);
		_selected_square.showPiece();
//		_hoverBoardCallback("OFF", "");
		if (isPlayer && !post_game) _grabPieceCallback(0, 0);
		CursorManager.removeCursor(CursorManager.currentCursorID);
		if (highlight_movable) hideMovableSquares();
		_pieceGrab = false;
        _from = null;
        _selected_square = null;
      }
	}
	
    public function closeGame():void {
	  replayMoves(0, true);
	  for (var i:int = 0; i <= 1; i++) {
		  infoBoxes[i].setStyle('borderColor', undefined);
		  _player_infos[i] = null;
		  timers[i].stop();
		  name_labels[i].setStyle("color", 0x000000);
		  name_labels[i].text = "";
		  _info_labels[i].text = "";
		  while (_avatar_images[i].numChildren > 0) _avatar_images[i].removeChildAt(0);
		  _player_flags[i].source = null;
	  }
	  isPlayer = false;
	  study_list = new Array();
	  post_game = false;
	  since_last_move = 0;
	  studyOn = false;
	  isStudyHost = false;
	  clearArrows(ARROWS_PUBLIC);
	  clearArrows(ARROWS_SELF);
	  cancelSquareSelect();
	  if (contains(_hoverImage)) removeChild(_hoverImage);
	  _hoverImage.source = null;
	  if (_oppo_selected_square) {
		  _oppo_selected_square.setStyle('backgroundColor', undefined);
		  _oppo_selected_square = null;
	  }
	  _board_bg_image.filters = null;
    }

		public function timeout():void{
			var running_timer:int = _my_turn == _position.turn ? 0 : 1;
			timers[running_timer].timeout();
		}
		
		public function clientTimeout():void {
			_client_timeout = true;
		}

  	public function get inGame():Boolean{
  		return _in_game;
  	}

	public function get playerInfos():Array{
  		return _player_infos;
  	}

  	public function get my_turn():int{
  		return _my_turn;
  	}
	
	public function set my_turn(v:int):void {
		this._my_turn = v;
	}

    public function get position():Kyokumen{
      return _position;
    }
	
	public function get last_pos():Kyokumen {
		return _last_pos;
	}
	
    public function setPieceType(i:int):void{
    	piece_type34 = i;
		_board_bg_image.source = _bg_images[i];
		 if (_my_turn == Kyokumen.SENTE) {
			_board_coord_image.source = _scoord_images[piece_type34];
		  } else {
			_board_coord_image.source = _gcoord_images[piece_type34];
		  }
    	if (_position != null) setPosition(_position);
    }

    public function monitor(game_info:String, watch_game:Object):void{
      var match:Array;
      if ((match = game_info.split("\n")[0].match(/^##\[MONITOR2\]\[(.*)\] V2$/))) {
		kid = parseInt(match[1]);
        _startMonitor(game_info, watch_game);
      } else if((match = game_info.split("\n")[0].match(/^##\[MONITOR2\]\[.*\] ([-+][0-9]{4}.{2})$/))) {
        var time:String = game_info.split("\n")[1].match(/^##\[MONITOR2\]\[.*\] (T.*)$/)[1];
		if (since_last_move > 0) {
			timers[_my_turn == _last_pos.turn ? 0 : 1].accumulateTime(- since_last_move);
			since_last_move = 0;
		}
        makeMove(match[1] + ',' + time, true, true);
      } else if (game_info.split("\n")[0].match(/^##\[MONITOR2\]\[.*\] %TORYO$/)) { //||
//               game_info.split("\n")[0].match(/^##\[MONITOR2\]\[.*\] #TIME_UP$/)) {
//    	  watch_game_end = true;
//    		timers[0].stop();
//   		timers[1].stop();
		  time = game_info.split("\n")[1].match(/^##\[MONITOR2\]\[.*\] (T.*)$/)[1];
		  var kifuMove:Object = new Object();
		  kifuMove.num = kifu_list.length;										//No. of the Move
		  kifuMove.move = (_last_pos.turn == Kyokumen.SENTE ? "▲" : "△") + "Resign (" + time.substr(1) + ")";	//Western Notation
		  kifuMove.moveStr = "%TORYO";												//CSA
		  kifuMove.moveKIF = "投了   ( " + int(parseInt(time.substr(1))/60) + ":" + parseInt(time.substr(1)) % 60 + "/)";			//Japanese Notation
		  kifu_list.push(kifuMove);
      } else {
        return;
      }
    }

    private function _startMonitor(game_info:String, watch_game:Object):void {
      var total_time:int;
      var byoyomi:int;
      var current_turn:int;
      var last_move:Point;
      var moves:Array = new Array();
      for each(var line:String in game_info.split("\n")){
        var match:Array = line.match(/^##\[MONITOR2\]\[.*\] (.*)$/);
        if (match != null && match[1]) {
          var token:String = match[1];
          if(token.match(/^([-+][0-9]{4}.{2}|%TORYO)$/)) {
            var move_and_time:Object = new Object();
            move_and_time.move = token
            moves.push(move_and_time);
          } else if (token.match(/^(T.*)$/)){
            Object(moves[moves.length - 1]).time = token;
          } else if (token.match(/SINCE_LAST_MOVE/)) {
		  }
        }
      }

	  match = watch_game.id.split("+")[1].match(/^([0-9a-z]+?)_(.*)-([0-9]*)-([0-9]*)$/);
	  total_time = parseInt(match[3]);
	  byoyomi = parseInt(match[4]);
	  if (match[2].match(/\-\-..$/)) _board_bg_image.filters = [filterTournament];
	  
      var kyokumen_str:String = _parsePosition(game_info);
      if(kyokumen_str != ""){
        resetBoard();
		initializeKifu();
		_initializeKyokumen(kyokumen_str);
        setPosition(_position);
      }
	  rematch[0] = false;
	  rematch[1] = false;
//      watch_game_end = false;

	  var blackInfo:Object = {
		  'name':watch_game.blackName,
		  'rating':watch_game.blackRating,
		  'rank':watch_game.blackRank,
		  'avatar':watch_game.blackAvatar,
		  'titleName':watch_game.blackTitle,
		  'country_code':watch_game.blackCountryCode,
		  'labelColor':watch_game.blackColor,
		  'wins':watch_game.blackWins,
		  'losses':watch_game.blackLosses,
		  'streak_best':watch_game.blackStreakBest
	  }
	  var whiteInfo:Object = {
		  'name':watch_game.whiteName,
		  'rating':watch_game.whiteRating,
		  'rank':watch_game.whiteRank,
		  'avatar':watch_game.whiteAvatar,
		  'titleName':watch_game.whiteTitle,
		  'country_code':watch_game.whiteCountryCode,
		  'labelColor':watch_game.whiteColor,
		  'wins':watch_game.whiteWins,
		  'losses':watch_game.whiteLosses,
		  'streak_best':watch_game.whiteStreakBest
	  }
	  _player_infos[0] = blackInfo;
	  _player_infos[1] = whiteInfo;
	  _arrangeInfos();
      timers[0].reset(total_time,byoyomi);
      timers[1].reset(total_time,byoyomi);

      var running_timer:int = _position.turn == _my_turn ? 0 : 1;
      timers[running_timer].start();
      timers[1-running_timer].stop();
      if (moves.length > 0) {
        for each(var move:Object in moves) {
			if (move.move == "%TORYO") {
				var kifuMove:Object = new Object();
				kifuMove.num = kifu_list.length;										//No. of the Move
				kifuMove.move = (_last_pos.turn == Kyokumen.SENTE ? "▲" : "△") + "Resign (" + move.time.substr(1) + ")";	//Western Notation
				kifuMove.moveStr = "%TORYO";												//CSA
				kifuMove.moveKIF = "投了   ( " + int(move.time.substr(1)/60) + ":" + move.time.substr(1) % 60 + "/)";			//Japanese Notation
				kifu_list.push(kifuMove);
				timers[_my_turn == _last_pos.turn ? 0 : 1].accumulateTime(parseInt(move.time.substr(1)));
			} else {
				makeMove(move.move + "," + move.time, true, false);
			}
        }
      }
	  studyOrigin = 0;
    }
	
    public function startView(kifu_contents:String):void {
      var moves:Array = new Array();
	  var kyokumen_str:String = "";
	  kifu_list = new Array();
	  kifu_list_self = new Array();
      for each(var line:String in kifu_contents.split("\n")) {
		  if (line.match(/^To_Move/)) {
			  kyokumen_str += "P0" + line.substring(8) + "\n";
		  } else if (line.match(/^P[0-9\+\-]/)) {
			  kyokumen_str += line + "\n";
		  } else if (line.match(/^N\+.+$/)) {
			  _player_infos[0] = new Object();
			  _player_infos[0].name = line.substring(2);
			  _player_infos[0].titleName = "";
		  } else if (line.match(/^N\-.+$/)) {
			  _player_infos[1] = new Object();
			  _player_infos[1].name = line.substring(2);
			  _player_infos[1].titleName = "";
		  } else if (line.match(/^I\+.+$/)) {
			  _player_infos[0].rating = line.substring(2).split(",")[0];
			  if (_player_infos[0].rating.match(/^\*/)) {
				  _player_infos[0].rank = "-";
			  } else {
				  _player_infos[0].rating = parseInt(_player_infos[0].rating);
				  _player_infos[0].rank = InfoFetcher.makeRankFromRating(_player_infos[0].rating);
			  }
			  _player_infos[0].country_code = parseInt(line.substring(2).split(",")[1]);
		  } else if (line.match(/^I\-.+$/)) {
			  _player_infos[1].rating = line.substring(2).split(",")[0];
			  if (_player_infos[1].rating.match(/^\*/)) {
				  _player_infos[1].rank = "-";
			  } else {
				  _player_infos[1].rating = parseInt(_player_infos[1].rating);
				  _player_infos[1].rank = InfoFetcher.makeRankFromRating(_player_infos[1].rating);
			  }
			  _player_infos[1].country_code = parseInt(line.substring(2).split(",")[1]);
		  } else if(line.match(/^([-+][0-9]{4}.{2}$)/) || line == "%TORYO") {
            var move_and_time:Object = new Object();
            move_and_time.move = line;
			move_and_time.comment = "";
            moves.push(move_and_time);
          } else if (line.match(/^(T.*)$/)) {
            Object(moves[moves.length - 1]).time = line;
//          } else if (line.match(/^#(RESIGN|TIME_UP|ILLEGAL_MOVE|SENNICHITE|DISCONNECT|JISHOGI)/)) {
//			  break;
		  } else if (line.match(/^'\*/)) {
			  Object(moves[moves.length - 1]).comment += line + "\n";
		  } else if (line.match(/summary/)) {
			  opening = line.split(":")[5] ? InfoFetcher.openingNameEn(line.split(":")[5]) : "";
		  }
      }
	  
      if (kyokumen_str != "") {
		trace(kyokumen_str);
        resetBoard();
		initializeKifu();
		_initializeKyokumen(kyokumen_str);
        setPosition(_position);
      }

	  _my_turn = Kyokumen.SENTE;
//      name_labels[0].text = _player_infos[_my_turn].name;
//      name_labels[1].text = _player_infos[1-_my_turn].name;
//      _info_labels[0].text = "";
//      _info_labels[1].text = "";
//      _turn_symbols[0].source = _my_turn == Kyokumen.SENTE ? black : white;
//      _turn_symbols[1].source = _my_turn == Kyokumen.SENTE ? white_r : black_r;
	  _arrangeInfos();
	  timers[0].reset(0, 0);
	  timers[1].reset(0, 0);

      if (moves.length > 0) {
        for each(var move:Object in moves) {
		  if (move.move != "%TORYO") {
			  makeMove(move.move + "," + move.time, true, false);
			  trace(move.move + "," + move.time);
		  } else {
			  var kifuMove:Object = new Object();
			  kifuMove.num = kifu_list.length
			  kifuMove.move = (_last_pos.turn == Kyokumen.SENTE ? "▲" : "△") + "Resign (" + move.time.substring(1) + ")";
			  kifuMove.moveKIF = "投了   ( " + int(move.time.substr(1) / 60) + ":" + move.time.substr(1) % 60 + "/)";
			  kifu_list.push(kifuMove);
		  }
		  Object(kifu_list[kifu_list.length - 1]).comment = move.comment;
        }
      }
    }

    private function _parsePosition(game_info:String):String{
      var lines:Array = game_info.split("\n");
      var kyokumen_str:String = "";
      for each (var line:String in lines ) {
		var match:Array = line.match(/##\[MONITOR2\]\[.*\] To_Move:([\+\-])/);
		if (match != null) {
			kyokumen_str += "P0" + match[1] + "\n";
		} else {
			match = line.match(/##\[MONITOR2\]\[.*\] (P[0-9+-].*)/);
			if(match != null) kyokumen_str += match[1] + "\n";
        }
      }
      return kyokumen_str;
    }
	
    private function _squareMouseDownHandler(e:MouseEvent):void {
		_arrow_from_type = BoardArrow.FROM_BOARD;
		_arrow_from = new Point(Square(e.currentTarget).coord_x, Square(e.currentTarget).coord_y);
	}

    private function _squareMouseUpHandler(e:MouseEvent):void {
	  if (_pieceGrab) e.currentTarget.mouseOut();
	  if (_arrow_from == null) return;
	  _arrow_to.x = Square(e.currentTarget).coord_x;
	  _arrow_to.y = Square(e.currentTarget).coord_y;
	  if (_arrow_from.x != _arrow_to.x || _arrow_from.y != _arrow_to.y) {
		  if ((isPlayer && !post_game) || (post_game && onListen && !studyOn)) return;
		  _addMyArrowCallback(_arrow_from_type, _arrow_from, _arrow_to);
		  cancelSquareSelect();
		  _arrow_from = null;
		  return;
	  }
      if((_in_game && _position.turn == _my_turn && !_move_sent) || !onListen) { // || (post_game && (isWinner || (isLoser && onListen && _position.turn == _my_turn && study_list.length > 0)))){
        var x:int = e.currentTarget.coord_x;
        var y:int = e.currentTarget.coord_y;
		if (e.currentTarget.dead) return;
//		if (gameType == "mini") {
//			if (x <= 2 || x >= 8 || y <= 2 || y >= 8) return;
//		}
        if(_from == null){
		  if (_last_from_square != null) {
			  _last_from_square.setStyle('backgroundColor', undefined);
			  _last_from_square = null;
		  }
          var koma:Koma = _position.getKomaAt(Kyokumen.translateHumanCoordinates(new Point(x,y)));
          if( koma != null && koma.ownerPlayer == _position.turn){
            e.currentTarget.setStyle('backgroundColor', '0x33CCCC');
			if (hold_piece) {
				e.currentTarget.hidePiece();
				CursorManager.setCursor(e.currentTarget.source, 2, - Square.KOMA_WIDTH / 2, - Square.KOMA_HEIGHT / 2);
//				CursorManager.setCursor(e.currentTarget.source, 2, - e.localX, - e.localY);
			}
			if (isPlayer && !post_game) _grabPieceCallback(x, y);
			_pieceGrab = true;
            _selected_square = Square(e.currentTarget);
            _from = new Point(x, y);
			if (highlight_movable) _showMovableSquares(_from);
          }
        } else {
          koma = _position.getKomaAt(Kyokumen.translateHumanCoordinates(new Point(x,y)));
          if( koma != null && (koma.ownerPlayer == _position.turn || _from.x >= Kyokumen.HAND)){
			cancelSquareSelect();
          } else {
            _to = new Point(x,y);
            if (_from.x < Kyokumen.HAND && _position.cantMove(_position.getKomaAt(Kyokumen.translateHumanCoordinates(_from)), _from, _to)) {
				cancelSquareSelect();
			    _to = null;
            } else if (_position.canPromote(_from, _to)) {
				if (hold_piece) CursorManager.removeCursor(CursorManager.currentCursorID);
				_pieceGrab = false;
				if (_position.mustPromote(_from, _to)) {
					if (!_client_timeout) {
						if (isPlayer) timers[0].suspend();
						_move_sent = true;
						_playerMoveCallback(_from, _to, true);
					}
					_to = null;
				} else {
					var koma_type:int = _position.getKomaAt(Kyokumen.translateHumanCoordinates(_from)).type;
					var cls:Class = _my_turn == _position.turn ? pSrc.koma_images_sente[piece_type34][koma_type + Koma.PROMOTE] : pSrc.koma_images_gote[piece_type34][koma_type + Koma.PROMOTE];
					var alt:Alert = Alert.show("Promote?", "", Alert.YES | Alert.NO, this, _promotionHandler, cls);
					alt.validateNow();
					alt.width *= 0.8;
					alt.x = mouseX - alt.width / 2 + 5;
					alt.y = mouseY - 90;
				}
            } else if (isPlayer && (_player_infos[_my_turn].game_name.match(/^(nr)_/) || ((_player_infos[_my_turn].game_name.match(/^(hc|va)/) && _my_turn == Kyokumen.SENTE))) && _position.isNifu(_from, _to)) {
					Alert.show("Nifu. (Double Pawn.)", "Illegal move!!");
					cancelSquareSelect();
					_to = null;
			} else {
			  if (hold_piece) CursorManager.removeCursor(CursorManager.currentCursorID);
			  _pieceGrab = false;
			  if (!_client_timeout){
				  if (isPlayer) timers[0].suspend();
				  _move_sent = true;
				  _playerMoveCallback(_from, _to, false);
			  }
			  _to = null;
            }
          }
        }
      }
	  _arrow_from = null;
    }

    private function _promotionHandler(e:CloseEvent):void {
      if (! _client_timeout) {
		  timers[0].suspend();
		  _move_sent = true;
		  _playerMoveCallback(_from, _to, e.detail == Alert.YES);
	  }
	  _to = null;
    }
	
	private function _squareMouseOutHandler(e:MouseEvent):void {
		if (_pieceGrab) e.currentTarget.mouseOut();
	}
	
	private function _squareMouseOverHandler(e:MouseEvent):void {
		if (_pieceGrab) {
			e.currentTarget.mouseOver();
			if (isPlayer && !post_game && sendHover) e.currentTarget.startTimer();
		}
	}
	
	private function _squareStayHandler(e:Event):void {
		if (_pieceGrab && !post_game) _hoverPieceCallback(e.currentTarget.coord_x, e.currentTarget.coord_y);
	}
	
    private function _handMouseDownHandler(e:MouseEvent):void {
		if (e.currentTarget.parent == handBoxes[0]) {
			_arrow_from_type = _my_turn == Kyokumen.SENTE ? Kyokumen.SENTE : Kyokumen.GOTE;
		} else {
			_arrow_from_type = _my_turn == Kyokumen.SENTE ? Kyokumen.GOTE: Kyokumen.SENTE;
		}
		_arrow_from = new Point(e.currentTarget.x + KOMA_WIDTH / 2, e.currentTarget.y + KOMA_HEIGHT / 2);
	}

    private function _handMouseUpHandler(e:MouseEvent):void{
      if ((_in_game && _position.turn == _my_turn && !_move_sent) || !onListen) { // || (post_game && (isWinner || (isLoser && onListen && _position.turn == _my_turn && study_list.length > 0)))) {
		if (e.currentTarget.parent != handBoxes[_my_turn == Kyokumen.SENTE ? _position.turn : (1 - _position.turn)]) return;
        if(_from == null){
		  if (_last_from_square != null) {
			  _last_from_square.setStyle('backgroundColor', undefined);
			  _last_from_square = null;
		  }
          e.currentTarget.setStyle('backgroundColor', '0x33CCCC');
		  if (hold_piece) {
			e.currentTarget.hidePiece();
			CursorManager.setCursor(e.currentTarget.source, 2, - Square.KOMA_WIDTH / 2, - Square.KOMA_HEIGHT / 2);
		  }
		  if (isPlayer && !post_game) _grabPieceCallback(e.currentTarget.coord_x, _position.turn);
		  _pieceGrab = true;
          _selected_square = Square(e.currentTarget);
		  _from = new Point(e.currentTarget.coord_x, e.currentTarget.coord_y);
        } else {
//            _selected_square.setStyle('backgroundColor',undefined);
//            _from = null;
//            _selected_square = null;
			cancelSquareSelect();
        }
      }
	  _arrow_from = null;
    }
	
	public function handleHover(x:int, y:int):void {
		var sq:Square = _cells[y - 1][9 - x];
		_hoverImage.x = sq.x;
		_hoverImage.y = sq.y;
		if (!contains(_hoverImage)) addChild(_hoverImage);
	}
	
	public function handleGrab(x:int, y:int):void {
		 if (_last_from_square != null) {
			_last_from_square.setStyle('backgroundColor', undefined);
			_last_from_square = null;
		}
		if (x == 0) {
			if (contains(_hoverImage)) removeChild(_hoverImage);
			if (_oppo_selected_square) {
				_oppo_selected_square.setStyle('backgroundColor', undefined);
				_oppo_selected_square = null;
			}
		} else if (x >= 100) {
			for each (var sq:Square in handBoxes[_position.turn == _my_turn ? 0 : 1].getChildren()) {
				if (sq.coord_x == x) {
//						_hoverImage.x = sq.parent.x + sq.x;
//						_hoverImage.y = sq.parent.y + sq.y;
//						if (!contains(_hoverImage)) addChild(_hoverImage);
					sq.setStyle('backgroundColor', '0x33CCCC');
					_oppo_selected_square = sq;
					_hoverImage.source = sq.source;
					break;
				}
			}
		} else {
			sq = _cells[y - 1][9 - x];
			sq.setStyle('backgroundColor', '0x33CCCC');
			_oppo_selected_square = sq;
			_hoverImage.source = sq.source;
		}
	}
	
	public function clearArrows(target:int, sender:String = "*"):Boolean {
		trace("Cleared " + target);
		var found:Boolean = false;
		if (_arrows[target].length > 0) {
			for (var i:int = _arrows[target].length - 1; i >= 0; i--) {
				var arrow:BoardArrow = _arrows[target][i];
				if (sender == "*" || sender == arrow.sender) {
					found = true;
					removeChild(arrow);
					arrow = null;
					_arrows[target].splice(i, 1);
				}
			}
		}
		return found;
	}
	
	public function addArrow(fromType:int, from:Point, to:Point, color:uint, sender:String, target:int, showNow:Boolean = false):void {
		trace("Added to " + target + " as " + showNow);
		if (_arrows[target].length >= MAX_ARROWS) {
			removeChild(_arrows[target].shift());
		}
		var arrow:BoardArrow = new BoardArrow(fromType, from, to, color, sender);
		_arrows[target].push(arrow);
		addChild(arrow);
		if (showNow) arrow.drawArrow(_my_turn);
	}
	
	public function eraseArrows(target:int):void {
		trace("Erased " + target);
		if (_arrows[target].length > 0) {
			for each (var arrow:BoardArrow in _arrows[target]) {
				if (arrow.isDrawn) {
					arrow.erase();
				}
			}
		}
	}
	
	public function showArrows(target:int):void {
		trace("Shown " + target);
		if (_arrows[target].length > 0) {
			for each (var arrow:BoardArrow in _arrows[target]) {
				if (!arrow.isDrawn) {
					arrow.drawArrow(_my_turn);
				}
			}
		}
	}

	private function _showMovableSquares(from:Point):void {
		var koma:Koma = _position.getKomaAt(Kyokumen.translateHumanCoordinates(from));
		for (var i:int = 0; i < 4; i++) {
			for (var j:int = 0; j < 3; j++) {
				if (!_position.cantMove(koma, from, new Point(_cells[i][j].coord_x, _cells[i][j].coord_y))) _cells[i][j].showMovable();
			}
		}
	}
	
	public function hideMovableSquares():void {
		for (var i:int = 0; i < 4; i++) {
			for (var j:int = 0; j < 3; j++) {
				_cells[i][j].hideMovable();
			}
		}
	}

		private function _checkTimeout(e:Event):void {
			if (_in_game) _timeoutCallback();
		}

		private function _checkTimerLag(e:Event):void {
			if (_in_game && e.target == timers[0]) _timerLagCallback();
		}
		
	  public function replayMoves(n:int, actual:Boolean = true):void {
		  if (!_position) return;
		  var mv:Movement;
		  if (_last_to_square != null){
		  	_last_to_square.setStyle('backgroundColor',undefined);
		  	_last_to_square = null;
		  }
		  if (_last_from_square != null){
		  	_last_from_square.setStyle('backgroundColor',undefined);
		  	_last_from_square = null;
		  }
//		  _position.turn = Kyokumen.SENTE;
		  _position.getKomadai(0).clearKoma();
		  _position.getKomadai(1).clearKoma();
		  _position.loadFromString(_position.initialPositionStr);
		  if (n >= 1){
			  for (var i:int = 1; i <= n; i++ ) {
			      var mvtmp:Movement;
				  mvtmp = actual ? _position.generateMovementFromString(kifu_list[i].moveStr) : _position.generateMovementFromString(kifu_list_self[i].moveStr);
				  if (!mvtmp) continue;
				  mv = mvtmp;
				  if (i == n) _position.generateWesternNotationFromMovement(mv);
			      _position.move(mv);
			  }
			  if (mv) {
				  _last_to_square = _cells[mv.to.y][mv.to.x];
				  _last_to_square.setStyle('backgroundColor', '0xCC3333');
				  if (mv.from.x < Kyokumen.HAND) {
					_last_from_square = _cells[mv.from.y][mv.from.x];
					_last_from_square.setStyle('backgroundColor', '0xFF5555');
				  }
			  }
		  }
		  setPosition(_position);
		  if (viewing && actual) {
			  if (kifu_list[n].comment) parentApplication.userMessage2.htmlText = kifu_list[n].comment;
			  else parentApplication.userMessage2.htmlText = "";
		  }
	  }
  }
}
