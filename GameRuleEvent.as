package {
  import flash.events.Event;

  public class GameRuleEvent extends Event{
    public var total:int;
    public var byoyomi:int;
    public var handicap:String;
    public static var RULE_SELECTED:String = "rule_selected";

    public function GameRuleEvent(type:String,total:int,byoyomi:int,handicap:String){
      super(type)
      this.total = total;
      this.byoyomi = byoyomi;
      this.handicap = handicap;
    }
  }
}
