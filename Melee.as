package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class Melee extends MovieClip{
		
		var Health:Number = 100;
		var IsMelee:Boolean = true;
		
		public function Melee(xLocation:int, yLocation:int) {
			// constructor code
			x = xLocation;
			y = yLocation;
			
			
			//addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			
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
			trace("Melee Enemy Removed");
			removeEventListener(Event.ENTER_FRAME, loop);
			this.parent.removeChild(this);
		}

	}
	
}
