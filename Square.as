package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import flash.text.TextFormat;

  public class Square extends Canvas {
    private var _coord_x:int;
    private var _coord_y:int;
    private var _img:Image;
	private var _stayTimer:Timer = new Timer(150, 1);
	private var _dead:Boolean = false;
	private var _movableMarker:UIComponent = new UIComponent();
	private var _studyLabelUIC:UIComponent = new UIComponent();
	private var _studyLabel:TextField;
	private var _studyLabelHoldTimer:Timer = new Timer(1500, 1);
	private var _studyLabelFadeTimer:Timer = new Timer(100, 10);

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
      this.addChild(_img);
	  var spr:Sprite = new Sprite();
	  spr.graphics.beginFill(0x00ff00, 0.3);
	  spr.graphics.drawCircle(KOMA_WIDTH / 2, KOMA_HEIGHT / 2, KOMA_WIDTH / 4);
	  spr.graphics.endFill();
	  _movableMarker.addChild(spr);
      _coord_x = x;
      _coord_y = y;
	  _stayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleStay);
	  _studyLabelHoldTimer.addEventListener(TimerEvent.TIMER, _handleTimerHold);
	  _studyLabelFadeTimer.addEventListener(TimerEvent.TIMER, _handleTimerFade);
	  _studyLabelFadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleTimerFadeComplete);
    }
	
	public function hidePiece():void {
		_img.visible = false;
	}
	
	public function showPiece():void {
		_img.visible = true;
	}
	
	public function showMovable():void {
		if (!contains(_movableMarker)) addChild(_movableMarker);
	}
	
	public function hideMovable():void {
		if (contains(_movableMarker)) removeChild(_movableMarker);
	}
	
	public function showLabel(name:String):void {
		_studyLabelHoldTimer.reset();
		_studyLabelFadeTimer.reset();
		if (_studyLabel == null) {
			_studyLabel = new TextField();
			_studyLabel.x = 0;
			_studyLabel.y = -3;
			_studyLabel.autoSize = "left";
			_studyLabel.selectable = false;
			_studyLabel.defaultTextFormat = new TextFormat("Meiryo UI", 10, 0x00AA00, true);
			_studyLabelUIC.addChild(_studyLabel);
		}
		hideLabel();
		_studyLabel.text = name;
		_studyLabel.alpha = 1.0;
		addChild(_studyLabelUIC);
		_studyLabelHoldTimer.start();
	}
	
	public function hideLabel():void {
		if (contains(_studyLabelUIC)) removeChild(_studyLabelUIC);
	}
	
	private function _handleTimerHold(e:TimerEvent):void {
		_studyLabelHoldTimer.reset();
		_studyLabelFadeTimer.start();
	}
	
	private function _handleTimerFade(e:TimerEvent):void {
		_studyLabel.alpha -= 0.1;
	}
	
	private function _handleTimerFadeComplete(e:TimerEvent):void {
		_studyLabelFadeTimer.reset();
		hideLabel();
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
