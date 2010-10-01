package {
	import mx.containers.Canvas;
	import mx.controls.Image;

  public class Square extends Canvas {
    private var _coord_x:int;
    private var _coord_y:int;
    private var _img:Image;

    public static const KOMA_WIDTH:int = 43;
    public static const KOMA_HEIGHT:int = 48;

    public function Square(x:int,y:int):void{
      super();
      this.width = KOMA_WIDTH;
      this.height = KOMA_HEIGHT;
      this.setStyle('backgroundAlpha',0.25);
      _img = new Image();
      _img.width = KOMA_WIDTH;
      _img.height = KOMA_HEIGHT;
      this.addChild(_img);
      _coord_x = x; 
      _coord_y = y; 
    }

    public function get coord_x():int{
      return _coord_x;
    }

    public function get coord_y():int{
      return _coord_y;
    }

    public function set source(cls:Class):void{
      _img.source = cls;
    }
  }

}
