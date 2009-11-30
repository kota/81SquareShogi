package {
	import mx.controls.Image;

  public class Square extends Image {
    private var _coord_x:int;
    private var _coord_y:int;

    public function Square(x:int,y:int):void{
       _coord_x = x; 
       _coord_y = y; 
    }

    public function get coord_x():int{
      return _coord_x;
    }

    public function get coord_y():int{
      return _coord_y;
    }
  }

}
