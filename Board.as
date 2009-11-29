/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import flash.events.Event;
  import flash.events.MouseEvent;
	import flash.geom.Point;
	import mx.controls.Image;
	import mx.containers.Canvas;
  import Square;
  import Kyokumen;
  import Koma;

	public class Board extends Canvas {
		
		public static const BAN_WIDTH:int = 410;
		public static const BAN_HEIGHT:int = 454;
		public static const BAN_LEFT_MARGIN:int = 100;

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

		private var cells:Array;
		private var board_back_image:Image = new Image();
		private var board_masu_image:Image = new Image();
		
		private var board_coordinate:Array = new Array();

    private var callback:Function;

    private var from:Point;
    private var position:Kyokumen;

		public function Board() {
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

			for (i = 0; i < 9; i++ ) {
				for (var j:int = 0; j < 9;j++ ){
          var square:Square = new Square(9-j,i+1);
          square.addEventListener(MouseEvent.MOUSE_UP,_squareMouseUpHandler);
          //square.source = sfu;
          square.x = BAN_LEFT_MARGIN + 10 + j * KOMA_WIDTH;
          square.y = 10 + i * KOMA_HEIGHT;
          square.width = KOMA_WIDTH;
          square.height = KOMA_HEIGHT;
          addChild(square);
					cells[i][j] = square;
				}
			}

      position = new Kyokumen();
      setPosition(position);
		}

    public function setPosition(pos:Kyokumen):void{
      position = pos
      for(var y:int=0;y<9;y++){
        for(var x:int=0;x<9;x++){
          var koma:Koma = position.getKomaAt(new Point(x,y));
          if(koma != null){
            var images:Array = koma.ownerPlayer == Kyokumen.SENTE ? koma_images_sente : koma_images_gote;
            var image_index:int = koma.type + (koma.isPromoted() ? 8 : 0)
            cells[y][x].source = images[image_index];
          } else {
            cells[y][x].source = emptyImage;
          }
        }
      }
    }

    public function setCallback(callback:Function):void{
      this.callback = callback;
    }

    private function _squareMouseUpHandler(e:MouseEvent):void {
      var x:int = e.target.coord_x;
      var y:int = e.target.coord_y;
      trace(x.toString() + "," + y.toString());
      if(this.from == null){
        if(position.getKomaAt(position.translateHumanCoordinates(new Point(x,y))) != null){
          this.from = new Point(x,y);
        }
      } else {
        var to:Point = new Point(x,y);
        callback(from,to);
        this.from = null;
      }
    }
	}
}
