package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class Melee extends MovieClip{
		
		var Health:Number = 100;
		var IsMelee:Boolean = true;
		var IsFacingRight:Boolean = true;
		var DistanceMoved:int = 0;
		var JustAttacked:int = 0;
		
		var PreviousHP:int = 100;
		var PrevHPCount:int = 10;
		
		public function Melee(xLocation:int, yLocation:int) {
			// constructor code
			x = xLocation;
			y = yLocation;
			
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			if(PreviousHP == Health){
				//If health hasn't changed, move
				if(IsFacingRight){
					x = x + 2;
					DistanceMoved++;
				} else{
					x = x - 2;
					DistanceMoved--;
				}	
			} else{
				//If health has, stop moving, then, after about 10 frames, reset the health tracker so it can move again
				//This should never get to that point if you're constantly hitting the enemy
				if(PrevHPCount <= 0){
					PrevHPCount = 10;
					PreviousHP = Health;
				} else{
					PrevHPCount--;
				}
			}
			
			
			if(DistanceMoved >= 60){
				IsFacingRight = false;
			} else if(DistanceMoved <= -60){
				IsFacingRight = true;
			}
			
			if(JustAttacked != 0){
				JustAttacked--;
			}
		}
		
		public function removeSelf(hp:Number):void{
			Health -= hp;
			HPBar.scaleX = (Health / 100);
			
			if(Health <= 0){
				actuallyDead();
			}
		}
		
		public function actuallyDead():void{
			trace("Melee Enemy Removed");
			removeEventListener(Event.ENTER_FRAME, loop);
			this.parent.removeChild(this);
		}
		
		
		
		
		
		//Getters and Setters
		public function getJustAttacked():int{
			return JustAttacked;
		}
		public function setJustAttacked(e:int):void{
			JustAttacked = e;
		}
		public function setPrevHPCount(e:int):void{
			PrevHPCount = e;
		}

	}
	
}
