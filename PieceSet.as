package 
{
	
	/**
	 * ...
	 * @author Hidetchi
	 */
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import mx.controls.Alert;

	public class PieceSet
	{
		private const SOURCE_DIRECTORY:String = "http://81dojo.com/dojo/images/piecesets34/";
		private var _koma_images:Array = new Array(2);
		private var _coord_images:Array;
		private var ban:Class;
		private var _name:String;
		private var _loader:Loader = new Loader();

		public function PieceSet(filename:String, name:String):void
		{
			_name = name;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _handleLoader);
			_loader.load(new URLRequest(SOURCE_DIRECTORY + filename));
  		}
		
		private function _handleLoader(e:Event):void {
			var pieceSetSource:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition("PieceSetSource34") as Class;
			var source:Object = new pieceSetSource();
			_koma_images = source.pieceClasses;
			_coord_images = source.coordClasses;
			ban = source.banClass;
		}
		
		public function getPieceClass(turn:int, type:int):Class {
			return _koma_images[turn][type];
		}
		
		public function getCoordClass(turn:int):Class {
			return _coord_images[turn];
		}
		
		public function get banClass():Class {
			return ban;
		}
		
		public function get getName():String {
			return _name;
		}

	}
	
}