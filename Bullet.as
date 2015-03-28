package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Bullet extends MovieClip{
		
		private var speed:int = 20;
		private var initialX:int;
		
		public function Bullet(playerX:int, playerY:int, playerDirection:String) {
			// constructor code
			
			if(playerDirection == "left"){
				speed = -20;
				x = playerX;
			} else if(playerDirection == "right"){
				speed = 20;
				x = playerX; //+
			}
			y = playerY - 35;

			initialX = x;
			
			//(stage.getChildByName("back") as MovieClip).addChild(this);
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			//Looping code here
			x += speed;
			
			
			
			if(speed > 0){
				if(x > initialX + 2000){
					removeSelf();
				}
			} else{
				if(x < initialX - 2000){
					removeSelf();
				}
			}
		}
		
		public function removeSelf():void{
			trace("Bullet Removed");
			removeEventListener(Event.ENTER_FRAME, loop);
			this.parent.removeChild(this);
		}

	}
	
}
