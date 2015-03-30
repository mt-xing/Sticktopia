package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class Ranged extends MovieClip {
		
		var Health:Number = 100;
		var IsMelee:Boolean = false;		
		//var rangeCord:Array = new Array();
		
		var lastFireTime:Number = 0;
		//var MidXCord:int = 0;
		//var MidYCord:int = Math.floor((rangeCord[1] + rangeCord[3]) / 2);
		
		public function Ranged(xLocation:int, yLocation:int/*, possCore:Array*/) {
			// constructor code
			x = xLocation;
			y = yLocation;
			
			//rangeCord = possCore;
			//MidXCord = Math.floor((rangeCord[0] + rangeCord[2]) / 2);
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			
			if(!(root as DisplayObjectContainer).getChildByName("back")){
				trace("No Root");
				return;
			}
			
			/*if(rangeCord[0] < (root as DisplayObjectContainer).getChildByName("back").x &&
				rangeCord[2] > (root as DisplayObjectContainer).getChildByName("back").x &&
				rangeCord[1] < (root as DisplayObjectContainer).getChildByName("back").y &&
				rangeCord[3] > (root as DisplayObjectContainer).getChildByName("back").y){*/
			if((root as DisplayObjectContainer).getChildByName("player").hitTestObject(this.LRangeBox) || 
				(root as DisplayObjectContainer).getChildByName("player").hitTestObject(this.RRangeBox)){
				//trace("Player in Range");
				//Player in Range
				if(lastFireTime <= 0){
					
					if((root as DisplayObjectContainer).getChildByName("player").hitTestObject(this.LRangeBox)){
						fireBullet(false);
					} else{
						fireBullet(true);
					}
					
					
					
					lastFireTime = 30;
				} else{
					lastFireTime--;
				}
				
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
			//trace("Loop removed");
			this.parent.removeChild(this);
		}
		
		public function fireBullet(IsRight:Boolean):void {
			//trace(IsRight);
			var bullet:Bullet;
			
			if(IsRight){
				bullet = new Bullet(x + 80, y + 50, "right");
			} else{
				bullet = new Bullet(x - 80, y + 50, "left");
			}
			
			
			var stageBackground:MovieClip = ((root as MovieClip).getChildByName("back") as MovieClip);
			//trace(stageBackground.x);
			
			//http://stackoverflow.com/questions/26924447/object-on-stage-cannot-be-accessed-from-external-class
			stageBackground.addChild(bullet);
			
			Main.enemyBulletList.push(bullet);
			bullet.addEventListener(Event.REMOVED, bulletRemoved);
		}
		public function bulletRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, bulletRemoved);
			Main.enemyBulletList.splice(Main.bulletList.indexOf(e.currentTarget), 1);
		}
	}
	
}
