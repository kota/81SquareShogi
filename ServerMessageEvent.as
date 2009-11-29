package {
  import flash.events.Event;

  public class ServerMessageEvent extends Event{
    public var message:String;
    public function ServerMessageEvent(type:String,message:String){
      super(type);
      this.message = message;
    }
  }
}
