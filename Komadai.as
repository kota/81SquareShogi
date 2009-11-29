/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import Koma;
	import mx.containers.Box;
	
	public class Komadai extends Box{
		private var koma_list:Array = new Array(8);
		
		public function Komadai() {
			for (var i:int = 0; i < 8; i++ ) {
				koma_list[i] = 0;
			}
		}
		
		public function addKoma(koma:Koma):void {
			koma_list[koma.type]++;
		}
		
		public function removeKoma(koma:Koma):void {
			koma_list[koma.type]--;
		}
		
		public function getNumOfKoma(type:int):int {
			return koma_list[type];
		}
	}
}
