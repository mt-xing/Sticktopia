package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.coreyoneil.collision.CollisionGroup;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.media.SoundMixer;
	
	public class Main extends MovieClip {
		
		/*
		===============================================
		REGISTERING BAD GLOABL VARIABLES - DEAL WITH IT
		===============================================
		*/
		
		//Key Presses
		var leftPressed:Boolean = false;
		var rightPressed:Boolean = false;
		var upPressed:Boolean = false;
		var downPressed:Boolean = false;
		var attackPressed:Boolean = false;
		
		//Jumping Stuff
		const jumpConstant:Number = -65;
		var doubleJumpReady:Boolean = false;
		var upReleasedInAir:Boolean = false;
		const gravityConstant:Number = 5;
		
		var HP:Number = 100;
		
		//Speed
		var xSpeed:Number = 10;
		var ySpeed:Number = 10;
		
		var scrollX:Number = 150;
		var scrollY:Number = 950;
		
		const speedConstant:int = 4;
		const maxSpeedConstant:Number = 15;
		const friction:Number = 0.80;
		
		
		
		var AnimationState:String = "Idle";
		var LastWasLeft:Boolean = false;
		var AnimationTimer:Number = 0;
		var HomeTimer;
		
		//Sprite Arrays
		public static var bulletList:Array = new Array();
		var enemyList:Array = new Array();
		
		
		var CurrLev:int;
		
		/*
		==============
		PRELOADER CODE
		==============
		*/
		
		public function Main() {
			// constructor code
			trace("Hello Player! Main Class Has Loaded!");
			
			stop();
			addEventListener(Event.ENTER_FRAME, Preload);
		}
		
		//Loads the game
		public function Preload (e:Event):void{
			
			//Sets up variables for what's needed and what's loaded
			var TotalBytes:Number = loaderInfo.bytesTotal;
			var LoadedBytes:Number = loaderInfo.bytesLoaded;
			
			//Checks if loading is done
			if (LoadedBytes >= TotalBytes) {
				//If so, cleans up and moves on
				removeEventListener(Event.ENTER_FRAME, Preload)
				gotoAndStop(2, "Loader");
				
			} else{
				//Otherwise, updates the display
				Preloader.Fill.scaleX = LoadedBytes/TotalBytes;
				Preloader.PercentText.text = Math.round(LoadedBytes/TotalBytes*100) + "%";
			}
		}
		
		
		/*
		================
		RUNNING THE GAME
		================
		*/
		
		
		//New Level Code - What's called from the timeline
		public function NewLevel(LevelNum:int, LevelX:int, LevelY:int){
			
			HP = 100;
			
			stop();
			trace("Class Code For Level " + LevelNum + " Initiated.");
			
			//Indicator - If a level spawns its own indicator, then don't do this. Otherwise, spawn a level indicator
			//if(AutoInd == true){
			//	AddInd(LevelNum);
			//}
			
			CurrLev = LevelNum;
			
			AnimationState = "Idle";
			UpdatePlayer();
			
			player.Figure.scaleX = 1;
			
			
			scrollX = LevelX;
			scrollY = LevelY;
			
			downPressed = false;
			upPressed = false;
			leftPressed = false;
			rightPressed = false;
			
			//Starting all the event listeners
			AddEvents();
			
			
			trace("Event Listeners Initialized");
			stage.addEventListener(Event.ENTER_FRAME, FrameCode);
			SpawnEnemies();
		}
		
		public function AddEvents(){
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			trace("Listening for Arrow Keys");
		}
		public function RemoveEvents(){
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			trace("No Longer Listening for Arrow Keys");
		}
		
		
		
		
		
		//Key Handlers
		public function keyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.A || e.keyCode == Keyboard.LEFT){
				leftPressed = true;
			} else if(e.keyCode == Keyboard.D || e.keyCode == Keyboard.RIGHT){
				rightPressed = true;
			} else if(e.keyCode == Keyboard.W || e.keyCode == Keyboard.UP){
				upPressed = true;
			} else if(e.keyCode == Keyboard.S || e.keyCode == Keyboard.DOWN){
				downPressed = true;
			} else if(e.keyCode == Keyboard.SPACE){
			//	trace("Attack");
				attackPressed = true;
			}
		}
		
		public function keyUpHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.A || e.keyCode == Keyboard.LEFT){
				leftPressed = false;
			} else if(e.keyCode == Keyboard.D || e.keyCode == Keyboard.RIGHT){
				rightPressed = false;
			} else if(e.keyCode == Keyboard.W || e.keyCode == Keyboard.UP){
				upPressed = false;
			} else if(e.keyCode == Keyboard.S || e.keyCode == Keyboard.DOWN){
				downPressed = false;
			} else if(e.keyCode == Keyboard.C){
				fireBullet();
			} else if(e.keyCode == Keyboard.SPACE){
				attackPressed = false;
			}
		}
		
		
		
		function fireBullet():void {
			var playerDirection:String;
			if(player.Figure.scaleX < 0){
				playerDirection = "left";
			} else if(player.Figure.scaleX > 0){
				playerDirection = "right";
			}
			var bullet:Bullet = new Bullet(player.x - scrollX, player.y - scrollY, playerDirection);
			back.addChild(bullet);
			bulletList.push(bullet);
			bullet.addEventListener(Event.REMOVED, bulletRemoved);
		}
		function bulletRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, bulletRemoved);
			bulletList.splice(bulletList.indexOf(e.currentTarget), 1);
		}
		
		
		function addEnemy(isMelee:Boolean, xLocation:int, yLocation:int, passCord:Array):void{
			var enemy;
			if(isMelee){
				enemy = new Melee(xLocation, yLocation);
			} else{
				//Spawn ranged enemy here
				enemy = new Ranged(xLocation, yLocation, passCord);
			}
			back.addChild(enemy);
			
			enemy.addEventListener(Event.REMOVED, enemyRemoved);
			enemyList.push(enemy);
		}
		function enemyRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, enemyRemoved);
			enemyList.splice(enemyList.indexOf(e.currentTarget), 1);
		}
		
		
		
		
		function SpawnEnemies():void{
			switch(CurrLev){
				case 1:
					//addEnemy(true, player.x - scrollX, player.y - scrollY);
					addEnemy(true, 447.7, 307.1, null);
					addEnemy(false, -549.45, 3.8, [914, 250, 1373, 350]);
					addEnemy(true, 176, -263.5, null);
					break;
			}
		}
		function KillEnemies():void{
			if (enemyList.length > 0){
				for (var i:int = 0; i < enemyList.length; i++) {
					
						enemyList[i].removeSelf(999);
				}
			}
		}
		
		//Code To Be Executed Each Frame
		//==============================
		public function FrameCode(e:Event):void{
			var HealthAtBeg:Number = HP;
			
			
			
				
			
			var OnLad:Boolean = false;			
			
			//Run Collision Detection			
			var Bumping:Array = CollisionDetection();
			//[0]Up, [1]Down, [2]Left, [3]Right
			
			//Calculate Your Speed
			if(leftPressed){
				xSpeed -= speedConstant;
				player.Figure.scaleX = -1; // And turn your character in that direction
				LastWasLeft = true;
			} else if(rightPressed){
				xSpeed += speedConstant;
				player.Figure.scaleX = 1; // Ditto
				LastWasLeft = false;
			} else if(LastWasLeft){
				if(player.Figure){
					player.Figure.scaleX = -1;
				}
				
			}
			
			
			
			
			
			//Collision Detection - If bumping, nudge (bounce) in opposite direction
			if(Bumping[2]){
				if(xSpeed < 0){
					xSpeed *= -0.5;
				}
			}
			if(Bumping[3]){
				if(xSpeed > 0){
					xSpeed *= -0.5;
				}
			}
			if(Bumping[0]){
				if(ySpeed < 0){
					ySpeed *= -0.5;
				}
			}

			
			
			
			if(Bumping[1]){ //If the player is on the ground
				upReleasedInAir = false;
				doubleJumpReady = true;
				if(ySpeed > 0){
					ySpeed = 0;
				}
				if(upPressed){ //Player Jumps
					ySpeed = jumpConstant;
				}
				
				
				
			} else {
				
				var MaxLadders:Boolean = false;
				var LadI:int = 1;
				//Ladder Iterator
				
				while(MaxLadders != true){
					if(back.getChildByName("Lad" + LadI) == null){
						MaxLadders = true;
					} else{
						if(MovieClip(back.getChildByName("Lad" + LadI)).getChildByName("Collide").hitTestObject(player.LadDec)){
							if(upPressed){
								ySpeed = -20;
							} else if(downPressed){
								ySpeed = 20;
							}
							OnLad = true;
						}
						LadI++;
					}
				}
				
				
				if(OnLad == false){
					//Stole... I mean borrowed the following code - still figuring it out - read the original comments
					ySpeed = ySpeed + gravityConstant;
					if(upPressed == false){ // if the player releases the up arrow key
						upReleasedInAir = true; // set the variable to true
					}
					if(doubleJumpReady && upReleasedInAir){ // If you're not holding up and you can double jump...
						if(upPressed){ //If you press up...
							ySpeed = jumpConstant; //Double Jump!...
							doubleJumpReady = false; //And stop additional jumping
						}
					}
				}
			}
			
			
			if(player.Figure){
				
			
			//Additional code dealing with contact damage
			if (enemyList.length > 0){
				for (var l:int = 0; l < enemyList.length; l++) {
					if (player.DamageHitBox.hitTestObject(enemyList[l].HitBox) ){
						trace("Player and Enemy are colliding");
						HP -= 2;
						
						if(player.Figure.scaleX == -1){
							xSpeed += 2*speedConstant;
						} else if(player.Figure.scaleX == 1){
							xSpeed -= 2*speedConstant;
						}
					}
					if(enemyList[l].IsMelee == true){
						if(player.DamageHitBox.hitTestObject(enemyList[l].LHitBox)){
							HP -= 0.1;
						} else if(player.DamageHitBox.hitTestObject(enemyList[l].RHitBox)){
							HP -= 0.1;
						}
					}
				}
			}
			}
			
			//Movement Code
			if(xSpeed > maxSpeedConstant){
				xSpeed = maxSpeedConstant;
			} else if(xSpeed < (maxSpeedConstant * -1)){
				xSpeed = (maxSpeedConstant * -1);
			}	
			//Friction Calculation
			xSpeed *= friction;
			ySpeed *= friction;
			//Stops you if you're really not moving
			if(Math.abs(xSpeed) < 0.5 || (OnLad == true && leftPressed == false && rightPressed == false)){
				xSpeed = 0;
			}
			if(OnLad == true && upPressed == false && downPressed == false){
				ySpeed = 0;
			}
			//Updates the speed variables
			scrollX -= xSpeed;
			scrollY -= ySpeed;
			//And finally actually scrolls the background.
			back.x = scrollX;
			back.y = scrollY;
			
			
			//Player Animation Code
			if(AnimationState != "Complete"){
				if((leftPressed || rightPressed || xSpeed > speedConstant || xSpeed < speedConstant*-1) && Bumping[1]){
					AnimationState = "Running";
				} else if(attackPressed){
					
					if(AnimationTimer < 20){
						AnimationState = "Melee 1";
					} else{
						AnimationState = "Melee 2";
					}
					
					if(AnimationTimer < 35){
						AnimationTimer++;
					} else{
						AnimationTimer = 0;
					}
					
					
					
					//Melee version of same code that deals with enemies
					if (enemyList.length > 0 && ((player.currentLabel == "Melee 1") || (player.currentLabel == "Melee 2"))){
						for (var i:int = 0; i < enemyList.length; i++) {
							if (player.HitBox.hitTestObject(enemyList[i]) ){
								//trace("Player Attack and Enemy are colliding");
								enemyList[i].removeSelf(3);
							}	
						}
					}
					
					
				} else if(HealthAtBeg != HP){
					AnimationState = "Hurt";
				} else if(Bumping[1]){
					AnimationState = "Idle";
				} else{
					AnimationState = "Jumping";
				}
			}
			
			//Updates the player animation
			UpdatePlayer();
			
			
			
			
			
			//Deals with enemies
			if (enemyList.length > 0){
				for (var k:int = 0; k < enemyList.length; k++) {
					if (bulletList.length > 0) {
						for (var j:int = 0; j < bulletList.length; j++) {
							if ( enemyList[k].hitTestObject(bulletList[j]) ){
								trace("Bullet and Enemy are colliding");
								enemyList[k].removeSelf(40);
								bulletList[j].removeSelf();
							}
			
							// enemyList[i] will give you the current enemy
							// bulletList[j] will give you the current bullet
							// this will check all combinations of bullets and enemies
							// and see if any are colliding
							
							if(k == 0){
								if(bulletList[j].hitTestObject(player)){
									HP = HP - 20;
									bulletList[j].removeSelf();
								}
							}
						}
					}
				}
			}
			
			
			
			
			
			//Completing the level
			if(downPressed){
				//trace("Down Pressed");
				if(player.hitTestObject(back.Exit)){
					//LEVEL COMPLETE CODE TO GO HERE
					//gotoAndStop(1, "Level Select");
					//stage.removeEventListener(Event.ENTER_FRAME, FrameCode);
					LevelComplete(true);
				}
			}
			//trace(HP);
			
			HBar.HBar.scaleX = HP / 100;
			if(HealthAtBeg != HP){
				IsTakeDam.alpha = 1;
			} else{
				IsTakeDam.alpha = 0;
			}
			if(HP <= 0){
				//gotoAndStop(1, "Death");
				LevelComplete(false);
			}
			
			//trace(back.x);
			//trace(back.y);
			
		}
		
		public function UpdatePlayer():void{
			//trace(AnimationState);
			if(player.currentLabel != AnimationState){
				player.gotoAndStop(AnimationState);
			}
		}
		
		
		public function CollisionDetection():Array{
			//Much code here is from the Flash Collision Detection Kit; https://code.google.com/p/collisiondetectionkit/
			
			//Creates the Collision Group objects
			var TopCollisionGroup:CollisionGroup = new CollisionGroup(back.collisions, player.Upper);
			var BottomCollisionGroup:CollisionGroup = new CollisionGroup(back.collisions, player.Lower);
			var LeftCollisionGroup:CollisionGroup = new CollisionGroup(back.collisions, player.LeftSide);
			var RightCollisionGroup:CollisionGroup = new CollisionGroup(back.collisions, player.RightSide);
			
			
			var ReturnArray:Array = new Array();
			//[0]Up, [1]Down, [2]Left, [3]Right
			
			//Checks for collisions
			if(TopCollisionGroup.checkCollisions().length > 0) {
				ReturnArray[0] = true;
				//trace("Up Bump!");
				//Trying to prevent where you can glitch through the ceiling - isn't perfect, but good enough for now.
				doubleJumpReady = false;
			} else{
				ReturnArray[0] = false;
			}
			
			if(BottomCollisionGroup.checkCollisions().length > 0) {
				ReturnArray[1] = true;
			} else{
				ReturnArray[1] = false;
			}
			
			if(LeftCollisionGroup.checkCollisions().length > 0) {
				ReturnArray[2] = true;
				//trace("Left Bump!");
			} else{
				ReturnArray[2] = false;
			}
			
			if(RightCollisionGroup.checkCollisions().length > 0) {
				ReturnArray[3] = true;
				//trace("Right Bump!");
			} else{
				ReturnArray[3] = false;
			}
			
			return ReturnArray;
		}
		
		
		
		
		
		
		
		//=====================
		//LEVEL COMPLETE SHTUFF
		//=====================
		public function LevelComplete(isWin:Boolean):void{
			KillEnemies();
			stage.removeEventListener(Event.ENTER_FRAME, FrameCode);
			RemoveEvents();
			
			
			
			if(isWin){
				AnimationState = "Complete";
				UpdatePlayer();
				
				trace("Level Complete!");
				
				HomeTimer = setInterval(ReturnToLevels, 1000);
				
				
			} else{
				HP = 100;
				gotoAndStop(1, "Death");
			}
			
			
		}
		public function ReturnToLevels():void{
			//stage.removeEventListener(Event.ENTER_FRAME, FrameCode);
			clearInterval(HomeTimer);
			gotoAndStop(1, "Level Select");
		}
		
		
		
		
		public function KillSounds():void{
			SoundMixer.stopAll();
		}
		//OOP Encapsulation
		/*public static function getBulletArray():Array{
			return bulletList;
		}*/
		
	}
	
}
