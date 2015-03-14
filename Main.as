package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.coreyoneil.collision.CollisionGroup;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	
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
		
		//Jumping Stuff
		const jumpConstant:Number = -65;
		var doubleJumpReady:Boolean = false;
		var upReleasedInAir:Boolean = false;
		const gravityConstant:Number = 5;
		
		//Speed
		var xSpeed:Number = 10;
		var ySpeed:Number = 10;
		
		var scrollX:Number = 150;
		var scrollY:Number = 950;
		
		const speedConstant:int = 4;
		const maxSpeedConstant:Number = 15;
		const friction:Number = 0.80;
		
		var AnimationState:String = "Idle";
		
		//var HomeTimer;
		//var ClearInd;
		//var ShowInd;
		//var Comp:LComp = new LComp();
		//var LevInd:LInd
		
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
			
			stop();
			trace("Class Code For Level " + LevelNum + " Initiated.");
			
			//Indicator - If a level spawns its own indicator, then don't do this. Otherwise, spawn a level indicator
			//if(AutoInd == true){
			//	AddInd(LevelNum);
			//}
			
			CurrLev = LevelNum;
			
			AnimationState = "Idle";
			UpdatePlayer();
			
			scrollX = LevelX;
			scrollY = LevelY;
			
			downPressed = false;
			upPressed = false;
			leftPressed = false;
			rightPressed = false;
			
			//Starting all the event listeners
			AddEvents();
			stage.addEventListener(Event.ENTER_FRAME, FrameCode);
			
			trace("Event Listeners Initialized");
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
			if(e.keyCode == Keyboard.LEFT){
				leftPressed = true;
			} else if(e.keyCode == Keyboard.RIGHT){
				rightPressed = true;
			} else if(e.keyCode == Keyboard.UP){
				upPressed = true;
			} else if(e.keyCode == Keyboard.DOWN){
				downPressed = true;
			}
		}
		
		public function keyUpHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.LEFT){
				leftPressed = false;
			} else if(e.keyCode == Keyboard.RIGHT){
				rightPressed = false;
			} else if(e.keyCode == Keyboard.UP){
				upPressed = false;
			} else if(e.keyCode == Keyboard.DOWN){
				downPressed = false;
			}
		}
		
		//Code To Be Executed Each Frame
		//==============================
		public function FrameCode(e:Event):void{
			
			var OnLad:Boolean = false;			
			
			//Run Collision Detection			
			var Bumping:Array = CollisionDetection();
			//[0]Up, [1]Down, [2]Left, [3]Right
			
			//Calculate Your Speed
			if(leftPressed){
				xSpeed -= speedConstant;
				player.Figure.scaleX = -1; // And turn your character in that direction
			} else if(rightPressed){
				xSpeed += speedConstant;
				player.Figure.scaleX = 1; // Ditto
			}
			
			//Old Code - Might come in handy, though
			/*if(upPressed){
				ySpeed -= speedConstant;
			} else if(downPressed){
				ySpeed += speedConstant;
			}*/
			if(downPressed){
				//trace("Down Pressed");
				if(player.hitTestObject(back.Exit)){
					//trace("Level Complete!");
					//LevelComplete();
					//gotoAndStop(1, "Level Select");
					//LEVEL COMPLETE CODE TO GO HERE
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
				//trace("On Ground");
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
				if((leftPressed||rightPressed||xSpeed>speedConstant||xSpeed<speedConstant*-1)&&Bumping[1]){
					AnimationState = "Running";
				} else if(Bumping[1]){
					AnimationState = "Idle";
				} else {
					AnimationState = "Jumping";
				}
			}
			
			//Updates the player animation
			UpdatePlayer();
			
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
		
	}
	
}
