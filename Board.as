/**
* ...
* @author Default
* @version 0.1
*/

package  {
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.media.Sound;
  
  import mx.containers.Canvas;
  import mx.containers.HBox;
  import mx.controls.Alert;
  import mx.controls.Image;
  import mx.controls.Label;
  import mx.events.CloseEvent;

  public class Board extends Canvas {
    
    public static const BAN_WIDTH:int = 410;
    public static const BAN_HEIGHT:int = 454;
    public static const BAN_LEFT_MARGIN:int = 190;
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

    [Bindable]
    [Embed(source = "/images/pieces_kinki/Sou.png")]
    private var sou:Class
    [Embed(source = "/images/pieces_kinki/Shi.png")]
    private var shi:Class
    [Embed(source = "/images/pieces_kinki/Sryu.png")]
    private var sryu:Class
    [Embed(source = "/images/pieces_kinki/Skaku.png")]
    private var skaku:Class
    [Embed(source = "/images/pieces_kinki/Suma.png")]
    private var suma:Class
    [Embed(source = "/images/pieces_kinki/Skin.png")]
    private var skin:Class
    [Embed(source = "/images/pieces_kinki/Sgin.png")]
    private var sgin:Class
    [Embed(source = "/images/pieces_kinki/Sngin.png")]
    private var sngin:Class
    [Embed(source = "/images/pieces_kinki/Skei.png")]
    private var skei:Class
    [Embed(source = "/images/pieces_kinki/Snkei.png")]
    private var snkei:Class
    [Embed(source = "/images/pieces_kinki/Skyo.png")]
    private var skyo:Class
    [Embed(source = "/images/pieces_kinki/Snkyo.png")]
    private var snkyo:Class
    [Embed(source = "/images/pieces_kinki/Sfu.png")]
    private var sfu:Class
    [Embed(source = "/images/pieces_kinki/Sto.png")]
    private var sto:Class
    
    [Embed(source = "/images/pieces_kinki/Gou.png")]
    private var gou:Class
    [Embed(source = "/images/pieces_kinki/Ghi.png")]
    private var ghi:Class
    [Embed(source = "/images/pieces_kinki/Gryu.png")]
    private var gryu:Class
    [Embed(source = "/images/pieces_kinki/Gkaku.png")]
    private var gkaku:Class
    [Embed(source = "/images/pieces_kinki/Guma.png")]
    private var guma:Class
    [Embed(source = "/images/pieces_kinki/Gkin.png")]
    private var gkin:Class
    [Embed(source = "/images/pieces_kinki/Ggin.png")]
    private var ggin:Class
    [Embed(source = "/images/pieces_kinki/Gngin.png")]
    private var gngin:Class
    [Embed(source = "/images/pieces_kinki/Gkei.png")]
    private var gkei:Class
    [Embed(source = "/images/pieces_kinki/Gnkei.png")]
    private var gnkei:Class
    [Embed(source = "/images/pieces_kinki/Gkyo.png")]
    private var gkyo:Class
    [Embed(source = "/images/pieces_kinki/Gnkyo.png")]
    private var gnkyo:Class
    [Embed(source = "/images/pieces_kinki/Gfu.png")]
    private var gfu:Class
    [Embed(source = "/images/pieces_kinki/Gto.png")]
    private var gto:Class
    
    [Embed(source = "/images/white.png")]
    private var white:Class
    [Embed(source = "/images/white_r.png")]
    private var white_r:Class
    [Embed(source = "/images/black.png")]
    private var black:Class
    [Embed(source = "/images/black_r.png")]
    private var black_r:Class

	[Embed(source = "/sound/piece.mp3")]
	private var sound_piece:Class;
	private var _sound_piece:Sound = new sound_piece();

    private var koma_images_sente:Array = new Array(sou,shi,skaku,skin,sgin,skei,skyo,sfu,null,sryu,suma,null,sngin,snkei,snkyo,sto);

    private var koma_images_gote:Array = new Array(gou,ghi,gkaku,gkin,ggin,gkei,gkyo,gfu,null,gryu,guma,null,gngin,gnkei,gnkyo,gto);

    public var handBoxes:Array;
    private var _name_labels:Array;
    private var _turn_symbols:Array;

    private var _cells:Array;
    private var _board_bg_image:Image = new Image();
    private var _board_back_image:Image = new Image();
    private var _board_masu_image:Image = new Image();
    private var _board_coord_image:Image = new Image();
    private var _board_shand_image:Image = new Image();
    private var _board_ghand_image:Image = new Image();
    
    private var _board_corrdinate:Array = new Array();

    private var _playerMoveCallback:Function;

    private var _from:Point;
    private var _to:Point;
    private var _position:Kyokumen;

    private var _my_turn:int;
    private var _game_started:Boolean;

    private var _selected_square:Square;

    public function Board() {
      super();
      _cells = new Array(9);
      for (var i:int; i < 9; i++ ) {
        _cells[i] = new Array(9);
      }
      
      this.width = BAN_WIDTH;
      this.height = BAN_HEIGHT;
      
      _board_bg_image.source = board_bg;
      
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
      _board_shand_image.x = BAN_LEFT_MARGIN + BAN_WIDTH + 10
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
      _turn_symbols = new Array(2);
      for(i=0;i<2;i++){
        var hand:Canvas = new Canvas();
        
        hand.width = KOMADAI_WIDTH;
        hand.height = KOMADAI_HEIGHT;
        hand.x = i == 0 ? BAN_LEFT_MARGIN + BAN_WIDTH + 10 : 10;
        hand.y = i == 0 ? BAN_TOP_MARGIN + BAN_HEIGHT - hand.height : 10;
        handBoxes[i] = hand;
        addChild(hand);

        var name_label:Label = new Label();
        _name_labels[i] = name_label;
        var turn_symbol:Image = new Image();
        _turn_symbols[i] = turn_symbol;
        var h_box:HBox = new HBox();
        h_box.x = i == 0 ? BAN_LEFT_MARGIN + BAN_WIDTH + 10 : 10;
        h_box.y = i == 0 ? BAN_TOP_MARGIN + BAN_HEIGHT - hand.height - 25 : BAN_TOP_MARGIN + hand.height + 5 ;
        h_box.addChild(turn_symbol);
        h_box.addChild(name_label);
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
    }

    public function setPosition(pos:Kyokumen):void{
      _position = pos
      for(var y:int=0;y<9;y++){
        for(var x:int=0;x<9;x++){
          var koma:Koma = _position.getKomaAt(new Point(x,y));
          if(koma != null){
            var images:Array = koma.ownerPlayer == _my_turn ? koma_images_sente : koma_images_gote;
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
              images = i == _my_turn ? koma_images_sente : koma_images_gote;
              handPiece.source = images[j];
              handPiece.x= 10 + (KOMADAI_WIDTH-20)/2 * ((j-1)%2) + (KOMADAI_WIDTH/(j == 7 ? 1.2 : 2)-35)*k/hand.getNumOfKoma(j)
              handPiece.y= 10 + (KOMADAI_HEIGHT-20)/4 * int((j-1)/2)
              handBoxes[i == _my_turn ? 0 : 1].addChild(handPiece);
            }
          }
        }
      }
    }

    public function makeMove(move:String):void{
      var mv:Movement = _position.generateMovementFromString(move);
      _position.move(mv);
      setPosition(_position);
      _sound_piece.play();
    }

    public function setCallback(callback:Function):void{
      _playerMoveCallback = callback;
    }

    public function startGame(my_turn:int,player_names:Array):void{
      trace("game started");
      _my_turn = my_turn;
      reset();
      _position = new Kyokumen();
      setPosition(_position);
      _name_labels[0].text = player_names[_my_turn]; 
      _name_labels[1].text = player_names[1-_my_turn]; 
      _turn_symbols[0].source = _my_turn == Kyokumen.SENTE ? black : white;
      _turn_symbols[1].source = _my_turn == Kyokumen.SENTE ? white_r : black_r;
      _game_started = true;
    }

    public function endGame():void{
      trace("game end");
      _game_started = false;
    }

    public function get position():Kyokumen{
      return _position;
    }

    private function _squareMouseUpHandler(e:MouseEvent):void {
      if(_game_started && _position.turn == _my_turn){
        var x:int = e.currentTarget.coord_x;
        var y:int = e.currentTarget.coord_y;
        if(_from == null){
          var koma:Koma = _position.getKomaAt(_position.translateHumanCoordinates(new Point(x,y)));
          if( koma != null && koma.ownerPlayer == _my_turn){
            e.currentTarget.setStyle('backgroundColor','0x33CCCC');
            _selected_square = Square(e.currentTarget);
            _from = new Point(x,y);
          }
        } else {
          _selected_square.setStyle('backgroundColor',undefined);
          if(_selected_square == e.currentTarget){
            _from = null;
            _selected_square = null;
          } else {
            _to = new Point(x,y);
            if(_position.canPromote(_from,_to)){
              Alert.show("Promote?","",Alert.YES | Alert.NO,Canvas(e.currentTarget),_promotionHandler);
            } else {
              _playerMoveCallback(_from,_to);
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

  }
}
