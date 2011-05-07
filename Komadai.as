/**
* ...
* @author Default
* @version 0.1
*/

package  {
	import Koma;
	import mx.containers.Box;
	
	public class Komadai extends Box{
		private var koma_list:Array = new Array(4);
		
		public function Komadai() {
			clearKoma();
		}
		
		public function addKoma(koma:Koma):void {
			koma_list[koma.type]++;
		}
		
		public function removeKoma(koma_type:int):void {
		  koma_list[koma_type]--;
		}
		
		public function getNumOfKoma(koma_type:int):int {
			return koma_list[koma_type];
		}
		
		public function clearKoma():void{
			for (var i:int = 0; i < 4; i++ ) {
				koma_list[i]=0;
			}
		}
	}
}
