package {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.containers.Canvas;
	import mx.controls.Image;

  public class Square extends Canvas {
    private var _coord_x:int;
    private var _coord_y:int;
    private var _img:Image;
	private var _stayTimer:Timer = new Timer(150, 1);
	private var _dead:Boolean = false;

    public static const KOMA_WIDTH:int = 43;
    public static const KOMA_HEIGHT:int = 48;
	public static const STAY:String = "stay";

    public function Square(x:int,y:int):void{
      super();
      this.width = KOMA_WIDTH;
      this.height = KOMA_HEIGHT;
      this.setStyle('backgroundAlpha', 0.25);
	  this.horizontalScrollPolicy = 'off';
	  this.verticalScrollPolicy = 'off';
	  this.setStyle('borderStyle', 'outSet');
	  this.setStyle('borderThickness', 0);
	  this.setStyle('borderColor', 0xDD0000);
      _img = new Image();
      _img.width = KOMA_WIDTH;
      _img.height = KOMA_HEIGHT;
	  _img.x = -1;
	  _img.y = -1;
      this.addChild(_img);
      _coord_x = x;
      _coord_y = y;
	  _stayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleStay);
    }
	
	public function hidePiece():void {
		_img.visible = false;
	}
	
	public function showPiece():void {
		_img.visible = true;
	}
	
	public function mouseOver():void {
		this.setStyle('borderThickness', 1);
	}
	
	public function mouseOut():void {
		_stayTimer.stop();
		this.setStyle('borderThickness', 0);
	}
	
	public function startTimer():void {
		_stayTimer.reset();
		_stayTimer.start();
	}
	
	private function _handleStay(e:TimerEvent):void {
		dispatchEvent(new Event(STAY));
	}

    public function get coord_x():int{
      return _coord_x;
    }

    public function get coord_y():int{
      return _coord_y;
    }

    public function set source(cls:Object):void{
      _img.source = cls;
    }
	
	public function get source():Object {
		return _img.source;
	}

    public function set dead(dead:Boolean):void{
      _dead = dead;
    }
	
	public function get dead():Boolean {
		return _dead;
	}
	
  }
}
