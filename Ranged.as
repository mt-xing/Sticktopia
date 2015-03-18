﻿package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class Ranged extends MovieClip {
		
		var Health:Number = 100;
		var IsMelee:Boolean = false;
		
		var rangeCord:Array = new Array();
		
		var lastFireTime:Number = 0;
		
		public function Ranged(xLocation:int, yLocation:int, possCore:Array) {
			// constructor code
			x = xLocation;
			y = yLocation;
			
			rangeCord = possCore;
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop(e:Event):void{
			
			if(rangeCord[0] < (root as DisplayObjectContainer).getChildByName("back").x &&
				rangeCord[2] > (root as DisplayObjectContainer).getChildByName("back").x &&
				rangeCord[1] < (root as DisplayObjectContainer).getChildByName("back").y &&
				rangeCord[3] > (root as DisplayObjectContainer).getChildByName("back").y){
				//trace("Player in Range");
				//Player in Range
				if(lastFireTime <= 0){
					fireBullet();
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
			this.parent.removeChild(this);
		}
		
		public function fireBullet():void {
			/*var playerDirection:String;
			if(player.Figure.scaleX < 0){
				playerDirection = "left";
			} else if(player.Figure.scaleX > 0){
				playerDirection = "right";
			}*/
			var bullet:Bullet = new Bullet(x + 10, y + 50, "right");
			
			var stageBackground:MovieClip = ((root as MovieClip).getChildByName("back") as MovieClip);
			//trace(stageBackground.x);
			
			//http://stackoverflow.com/questions/26924447/object-on-stage-cannot-be-accessed-from-external-class
			stageBackground.addChild(bullet);
			
			Main.bulletList.push(bullet);
			bullet.addEventListener(Event.REMOVED, bulletRemoved);
		}
		public function bulletRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, bulletRemoved);
			Main.bulletList.splice(Main.bulletList.indexOf(e.currentTarget), 1);
		}
	}
	
}
