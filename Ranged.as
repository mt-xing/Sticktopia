package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	
	public class Ranged extends MovieClip {
		
		var Health:Number = 100;
		var IsMelee:Boolean = false;
		
		var rangeCord:Array = new Array();
		
		public function Ranged(xLocation:int, yLocation:int, possCore:Array) {
			// constructor code
			x = xLocation;
			y = yLocation;
			
			rangeCord = possCore;
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			
			if(rangeCord[0] < (root as DisplayObjectContainer).getChildByName("back").x && rangeCord[2] > (root as DisplayObjectContainer).getChildByName("back").x && rangeCord[1] < (root as DisplayObjectContainer).getChildByName("back").y && rangeCord[3] > (root as DisplayObjectContainer).getChildByName("back").y){
				trace("Player in Range");
				//Player in Range
			} 
		}
		
		public function removeSelf(hp:Number):void{
			Health -= hp;
			HPBar.scaleX = (Health / 100);
			//trace(Health / 100);
			//trace(Health / 100);
			
			if(Health <= 0){
				actuallyDead();
			}
		}
		
		public function actuallyDead():void{
			trace("Ranged Enemy Removed");
			removeEventListener(Event.ENTER_FRAME, loop);
			this.parent.removeChild(this);
		}
	}
	
}
