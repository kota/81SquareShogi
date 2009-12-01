/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.events.Event;
  import flash.events.MouseEvent;
	import flash.geom.Point;
	import mx.events.CloseEvent;
	import mx.controls.Image;
  import mx.controls.Alert;
	import mx.containers.Canvas;
  import mx.containers.Box;
  import Square;
  import Kyokumen;
  import Koma;

	public class Board extends Canvas {
		
		public static const BAN_WIDTH:int = 410;
		public static const BAN_HEIGHT:int = 454;
		public static const BAN_LEFT_MARGIN:int = 150;

    public static const KOMA_WIDTH:int = 43;
    public static const KOMA_HEIGHT:int = 48;

		
		[Bindable]
		[Embed(source = "/images/ban_kaya_a.png")]
		private var board_back:Class
		[Bindable]
		[Embed(source = "/images/masu_dot.png")]
		private var board_masu:Class
		[Embed(source = "/images/empty.png")]
		private var emptyImage:Class

		[Bindable]
		[Embed(source = "/images/Sou.png")]
		private var sou:Class
		[Embed(source = "/images/Shi.png")]
		private var shi:Class
		[Embed(source = "/images/Sryu.png")]
		private var sryu:Class
		[Embed(source = "/images/Skaku.png")]
		private var skaku:Class
		[Embed(source = "/images/Suma.png")]
		private var suma:Class
		[Embed(source = "/images/Skin.png")]
		private var skin:Class
		[Embed(source = "/images/Sgin.png")]
		private var sgin:Class
		[Embed(source = "/images/Sngin.png")]
		private var sngin:Class
		[Embed(source = "/images/Skei.png")]
		private var skei:Class
		[Embed(source = "/images/Snkei.png")]
		private var snkei:Class
		[Embed(source = "/images/Skyo.png")]
		private var skyo:Class
		[Embed(source = "/images/Snkyo.png")]
		private var snkyo:Class
		[Embed(source = "/images/Sfu.png")]
		private var sfu:Class
		[Embed(source = "/images/Sto.png")]
		private var sto:Class
		
		[Embed(source = "/images/Gou.png")]
		private var gou:Class
		[Embed(source = "/images/Ghi.png")]
		private var ghi:Class
		[Embed(source = "/images/Gryu.png")]
		private var gryu:Class
		[Embed(source = "/images/Gkaku.png")]
		private var gkaku:Class
		[Embed(source = "/images/Guma.png")]
		private var guma:Class
		[Embed(source = "/images/Gkin.png")]
		private var gkin:Class
		[Embed(source = "/images/Ggin.png")]
		private var ggin:Class
		[Embed(source = "/images/Gngin.png")]
		private var gngin:Class
		[Embed(source = "/images/Gkei.png")]
		private var gkei:Class
		[Embed(source = "/images/Gnkei.png")]
		private var gnkei:Class
		[Embed(source = "/images/Gkyo.png")]
		private var gkyo:Class
		[Embed(source = "/images/Gnkyo.png")]
		private var gnkyo:Class
		[Embed(source = "/images/Gfu.png")]
		private var gfu:Class
		[Embed(source = "/images/Gto.png")]
		private var gto:Class

    private var koma_images_sente:Array = new Array(sou,shi,skaku,skin,sgin,skei,skyo,sfu,null,sryu,suma,null,sngin,snkei,snkyo,sto);

    private var koma_images_gote:Array = new Array(gou,ghi,gkaku,gkin,ggin,gkei,gkyo,gfu,null,gryu,guma,null,gngin,gnkei,gnkyo,gto);

    public var handBoxes:Array;

		private var cells:Array;
		private var board_back_image:Image = new Image();
		private var board_masu_image:Image = new Image();
		
		private var board_coordinate:Array = new Array();

    private var _playerMoveCallback:Function;

    private var _from:Point;
    private var _to:Point;
    private var _position:Kyokumen;

    private var _my_turn:int;
    private var _game_started:Boolean;

    private var _selected_square:Square;

		public function Board() {
      super();
			cells = new Array(9);
			for (var i:int; i < 9; i++ ) {
				cells[i] = new Array(9);
			}
			
			//_initializeBoardCoordinate();
			
			this.width = BAN_WIDTH;
			this.height = BAN_HEIGHT;
			
			board_back_image.width = BAN_WIDTH;
			board_back_image.height = BAN_HEIGHT;
			board_back_image.source = board_masu;
			board_back_image.x = BAN_LEFT_MARGIN;
			
			board_masu_image.source = board_masu;
			board_masu_image.width = BAN_WIDTH;
			board_masu_image.height = BAN_HEIGHT;
			
			board_back_image.addChild(board_masu_image);
			addChild(board_back_image);

      handBoxes = new Array(2);
      for(i=0;i<2;i++){
        var hand:Box = new Box();
        hand.width = 150;
        hand.height = 300;
        hand.setStyle('borderStyle','solid');
        hand.setStyle('borderThickness',2);
        hand.x = i == 0 ? BAN_LEFT_MARGIN + BAN_WIDTH + 10 : 0;
        handBoxes[i] = hand;
        addChild(hand);
      }

			for (i = 0; i < 9; i++ ) {
				for (var j:int = 0; j < 9;j++ ){
          var square:Square = new Square(9-j,i+1);
          square.addEventListener(MouseEvent.MOUSE_UP,_squareMouseUpHandler);
          //square.source = sfu;
          square.x = BAN_LEFT_MARGIN + 10 + j * KOMA_WIDTH;
          square.y = 10 + i * KOMA_HEIGHT;
          addChild(square);
					cells[i][j] = square;
				}
			}

      _position = new Kyokumen();
      setPosition(_position);
		}

    public function setPosition(pos:Kyokumen):void{
      _position = pos
      for(var y:int=0;y<9;y++){
        for(var x:int=0;x<9;x++){
          var koma:Koma = _position.getKomaAt(new Point(x,y));
          if(koma != null){
            var images:Array = koma.ownerPlayer == Kyokumen.SENTE ? koma_images_sente : koma_images_gote;
            var image_index:int = koma.type;// + (koma.isPromoted() ? 8 : 0)
            cells[y][x].source = images[image_index];
          } else {
            cells[y][x].source = emptyImage;
          }
        }
      }
      for(var i:int=0;i<2;i++){
        handBoxes[i].removeAllChildren();
        var hand:Komadai = _position.getKomadai(i);
        for(var j:int=0;j<8;j++){
          if(hand.getNumOfKoma(j) > 0){
            for(var k:int=0;k<hand.getNumOfKoma(j);k++){
              var handPiece:Square = new Square(Kyokumen.HAND+j,Kyokumen.HAND+j);
              handPiece.addEventListener(MouseEvent.MOUSE_UP,_handMouseUpHandler);
              images = i == Kyokumen.SENTE ? koma_images_sente : koma_images_gote;
              handPiece.source = images[j];
              handBoxes[i].addChild(handPiece);
            }
          }
        }
      }
    }

    public function setCallback(callback:Function):void{
      _playerMoveCallback = callback;
    }

    public function startGame(my_turn:int):void{
      this._my_turn = my_turn;
      this._game_started = true;
    }

    public function endGame():void{
      this._game_started = false;
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
