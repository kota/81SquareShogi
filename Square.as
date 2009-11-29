package {
	import mx.controls.Image;

  public class Square extends Image {
    public var coord_x:int;
    public var coord_y:int;

    public function Square(x:int,y:int):void{
       coord_x = x; 
       coord_y = y; 
    }
  }

}
