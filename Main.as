package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.coreyoneil.collision.CollisionGroup;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.media.SoundMixer;
	import flash.display.InteractiveObject;
	
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
		//const friction:Number = 0.6;
		
		
		
		var AnimationState:String = "Idle";
		var LastWasLeft:Boolean = false;
		var AnimationTimer:Number = 0;
		var HomeTimer;
		var IgnoreAmend:Boolean = false;
		var Amend:AmendPopup;
		//Various Timer Iterators
		var FiredGun:int = 0;
		var KickedGuy:int = 0;
		var WasHit:int = -1;
		
		//Sprite Arrays
		public static var bulletList:Array = new Array();
		public static var enemyBulletList:Array = new Array();
		public static var enemyList:Array = new Array();
		
		
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
				stage.addEventListener(KeyboardEvent.KEY_UP, startSkip);
				
			} else{
				//Otherwise, updates the display
				Preloader.Fill.scaleX = LoadedBytes/TotalBytes;
				Preloader.PercentText.text = Math.round(LoadedBytes/TotalBytes*100) + "%";
			}
		}
		
		public function startSkip(e:Event):void{
			gotoAndStop("Main Menu", "Main Menu");
			
			//trace("StartSkip Removed");
		}
		public function creditsSkip(e:Event):void{
			stage.removeEventListener(KeyboardEvent.KEY_UP, creditsSkip);
			gotoAndStop("Main Menu", "Main Menu");
		}
		
		
		/*
		================
		RUNNING THE GAME
		================
		*/
		
		
		//New Level Code - What's called from the timeline
		public function NewLevel(LevelNum:int, LevelX:int, LevelY:int){
			
			HP = 100;
			IgnoreAmend = false;
			
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
			
			leftPressed = false;			
			rightPressed = false;			
			upPressed = false;			
			downPressed = false;			
			attackPressed = false;
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
				KickedGuy = 0;
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
			
			AnimationState = "Gun";
			UpdatePlayer();
			FiredGun = 6;
		}
		function bulletRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, bulletRemoved);
			bulletList.splice(bulletList.indexOf(e.currentTarget), 1);
		}
		
		
		function addEnemy(isMelee:Boolean, xLocation:int, yLocation:int/*, passCord:Array*/):void{
			var enemy;
			if(isMelee){
				enemy = new Melee(xLocation, yLocation);
			} else{
				//Spawn ranged enemy here
				enemy = new Ranged(xLocation, yLocation/*, passCord*/);
			}
			back.addChild(enemy);
			
			enemy.addEventListener(Event.REMOVED, enemyRemoved);
			enemyList.push(enemy);
		}
		function enemyRemoved(e:Event):void{
			e.currentTarget.removeEventListener(Event.REMOVED, enemyRemoved);
			trace("ABOUT TO KILL " + enemyList.indexOf(e.currentTarget));
			enemyList.splice(enemyList.indexOf(e.currentTarget), 1);
		}
		
		
		
		
		function SpawnEnemies():void{
			switch(CurrLev){
				case 1:
					//addEnemy(true, player.x - scrollX, player.y - scrollY);
					//addEnemy(true, 447.7, 307.1, null);
					//addEnemy(false, -549.45, 3.8, [914, 250, 1373, 350]);
					//addEnemy(true, 176, -263.5, null);
					addEnemy(true, -3255.4, -23);
					addEnemy(true, -2433.15, 588.3);
					addEnemy(true, -1237.95, 310.15);
					addEnemy(true, -534.9, -725.65);
					addEnemy(true, -1241, -725.65);
					addEnemy(true, -1913.45, -1003.9);
					addEnemy(true, -3530.45, -725.65);
					addEnemy(true, -3368.45, -725.65);
					addEnemy(true, -3206.45, -725.65);
					break;
				case 2:
					//addEnemy(false, -3833.95, 604.45)
					addEnemy(true, -4167.1, 600.95);
					addEnemy(true, -3735.7, 600.95);
					addEnemy(true, -2068.2, 573.45);
					addEnemy(true, -2221.15, 830.45);
					addEnemy(true, -79.55, -1072.5);
					addEnemy(true, 61.2, -1072.5);
					addEnemy(true, 201.95, -1072.5);
					addEnemy(true, 101, -572.35);
					addEnemy(true, 1119.85, -572.35);
					addEnemy(true, 1015.85, -572.35);
					addEnemy(true, 911.85, -572.35);
					addEnemy(true, 807.85, -572.35);
					addEnemy(false, -2805.6, 319.5);
					addEnemy(false, -810.75, -807.7);
					addEnemy(false, 394.7, -819.9);
					addEnemy(false, 443.6, -572.35);
					addEnemy(false, 1492.65, -850.35);
					addEnemy(false, 1630.3, -850.35);
					//addEnemy(false, 
					break;
				case 3:
					addEnemy(true, -836.05, 815.9);
					addEnemy(true, -1414.85, 549.45);
					addEnemy(true, -1053.5, 264.75);
					addEnemy(true, -921.85, 264.75);
					addEnemy(true, -790.2, 264.75);
					addEnemy(true, 150, 543.45);
					addEnemy(true, 241.9, 543.45);
					addEnemy(true, 333.8, 543.45);
					addEnemy(true, 425.7, 543.45);
					addEnemy(true, 55.1, 820);
					addEnemy(true, 211.3, 820);
					addEnemy(true, 367.5, 820);
					addEnemy(true, 523.7, 820);
					addEnemy(true, 679.9, 820);
					addEnemy(true, 836.1, 820);
					addEnemy(true, 1770.05, -474.4);
					addEnemy(true, 1644.45, -474.4);
					addEnemy(true, -324.65, -474.4);
					addEnemy(true, -223.6, -474.4);
					addEnemy(true, -122.55, -474.4);
					addEnemy(true, -21.5, -474.4);
					addEnemy(true, -1586.3, -213.4);
					addEnemy(true, -1451.6, -213.4);
					addEnemy(true, -1316.9, -213.4);
					addEnemy(true, -1182.2, -213.4);
					addEnemy(true, -1047.5, -213.4);
					addEnemy(true, -912.8, -213.4);
					addEnemy(true, -778.1, -213.4);
					addEnemy(true, -643.4, -213.4);
					addEnemy(true, -508.7, -213.4);
					addEnemy(true, -374, -213.4);
					addEnemy(false, -879.4, 829.2);
					addEnemy(false, -1028.55, 550.05);
					addEnemy(false, -680.6, 282.4);
					addEnemy(false, -550.6, 282.4);
					addEnemy(false, -420.6, 282.4);
					addEnemy(false, -290.6, 282.4);
					addEnemy(false, 191.25, 829.15);
					addEnemy(false, 478, 829.15);
					addEnemy(false, 764.75, 829.15);
					addEnemy(false, 1051.5, 829.15);
					addEnemy(false, 1338.25, 829.15);
					addEnemy(false, 1625, 829.15);
					addEnemy(false, 1516.1, -474.4);
					addEnemy(false, 1191.1, -474.4);
					addEnemy(false, -93.6, -753.6);
					addEnemy(false, 9.7, -753.6);
					addEnemy(false, 113, -753.6);
					addEnemy(false, 216.3, -753.6);
					addEnemy(false, -59.2, -213.4);
					addEnemy(false, -430.1, -213.4);
					addEnemy(false, -801, -213.4);
					addEnemy(false, -1171.9, -213.4);
					addEnemy(false, -1542.8, -213.4);
					addEnemy(false, -1913.7, -213.4);
					addEnemy(false, -2284.6, -213.4);
					break;
				case 4:
					addEnemy(true, 2482.7, 1171.5);
					addEnemy(true, 1933.75, 908.9);
					addEnemy(true, 2031.8, 908.9);
					addEnemy(true, 2129.85, 908.9);
					addEnemy(true, 1558.8, 630.5);
					addEnemy(true, 1850, 630.5);
					addEnemy(true, 2141.2, 630.5);
					addEnemy(true, 2432.4, 630.5);
					addEnemy(true, 2723.6, 630.5);
					addEnemy(true, 3014.8, 630.5);
					addEnemy(true, 3306, 630.5);
					addEnemy(true, 3597.2, 630.5);
					addEnemy(true, 3888.4, 630.5);
					addEnemy(true, 4179.6, 630.5);
					addEnemy(true, 4465.55, 1171.5);
					addEnemy(true, 3995, 908.9);
					addEnemy(true, 3811.15, 908.9);
					addEnemy(true, 3433.7, 1894.15);
					addEnemy(true, 3502.3, 2174.85);
					addEnemy(true, 3257.2, 2174.85);
					addEnemy(true, 3012.1, 2174.85);
					addEnemy(true, 2629.8, 1890.55);
					addEnemy(true, 1818.5, 1630.75);
					addEnemy(true, 2075.85, 1630.75);
					addEnemy(true, 1142.1, 2174.8);
					addEnemy(true, 975.5, 2174.8);
					addEnemy(true, 808.9, 2174.8);
					addEnemy(true, 642.3, 2174.8);
					addEnemy(true, 475.7, 2174.8);
					addEnemy(true, 309.1, 2174.8);
					addEnemy(true, 262.2, 1738.6);
					addEnemy(true, 399.45, 1738.6);
					addEnemy(true, 144.55, 703.75);
					addEnemy(true, -57.45, 703.75);
					addEnemy(true, -259.45, 703.75);
					addEnemy(true, -461.45, 703.75);
					addEnemy(true, -663.45, 703.75);
					addEnemy(true, -865.45, 703.75);
					addEnemy(true, -1067.45, 703.75);
					addEnemy(true, -1269.45, 703.75);
					addEnemy(true, -1471.45, 703.75);
					addEnemy(true, -1673.45, 703.75);
					addEnemy(false, 1382.3, 908.9);
					addEnemy(false, 1617.55, 908.9);
					addEnemy(false, 1852.8, 908.9);
					addEnemy(false, 2311.2, 629);
					addEnemy(false, 3551.35, 629);
					addEnemy(false, 4193.45, 1187.6);
					addEnemy(false, 3639.55, 908.9);
					addEnemy(false, 3531.8, 1886.5);
					addEnemy(false, 3156.75, 2174.85);
					addEnemy(false, 2681.85, 1878.3);
					addEnemy(false, 2051.4, 1638.1);
					addEnemy(false, 462.25, 1754.55);
					addEnemy(false, -79.15, 725.85);
					addEnemy(false, -370.95, 725.85);
					addEnemy(false, -662.75, 725.85);
					addEnemy(false, -954.55, 725.85);
					addEnemy(false, -1246.35, 725.85);
					addEnemy(false, -1538.15, 725.85);
					addEnemy(false, -1829.95, 725.85);
					addEnemy(false, -2121.75, 725.85);
					addEnemy(false, -2413.55, 725.85);
					addEnemy(false, -2705.35, 725.85);
					break;
				case 5:
					addEnemy(true, 1097.5, -162.55);
					addEnemy(true, 1334.85, -162.55);
					addEnemy(true, 1572.2, -162.55);
					addEnemy(true, 1809.55, -162.55);
					addEnemy(true, 1070.7, 386.6);
					addEnemy(true, 1258.3, 386.6);
					addEnemy(true, 1445.9, 386.6);
					addEnemy(true, 1633.5, 386.6);
					addEnemy(true, 1821.1, 386.6);
					addEnemy(true, 2008.7, 386.6);
					addEnemy(true, 2196.3, 386.6);
					addEnemy(true, 710.9, 838.4);
					addEnemy(true, 871.7, 838.4);
					addEnemy(true, 1032.5, 838.4);
					addEnemy(true, 1193.3, 838.4);
					addEnemy(true, 1354.1, 838.4);
					addEnemy(true, 362.05, 1383.15);
					addEnemy(true, 576.4, 1383.15);
					addEnemy(true, 790.75, 1383.15);
					addEnemy(true, 1005.1, 1383.15);
					addEnemy(true, 1219.45, 1383.15);
					addEnemy(true, 1433.8, 1383.15);
					addEnemy(true, 1648.15, 1383.15);
					addEnemy(true, -147.1, 1842.5);
					addEnemy(true, 9.8, 1842.5);
					addEnemy(true, 166.7, 1842.5);
					addEnemy(true, 323.6, 1842.5);
					addEnemy(true, 480.5, 1842.5);
					addEnemy(true, 262.55, 2758.65);
					addEnemy(true, 350, 2758.65);
					addEnemy(true, 437.45, 2758.65);
					addEnemy(true, 524.9, 2758.65);
					addEnemy(true, 612.35, 2758.65);
					addEnemy(true, 699.8, 2758.65);
					addEnemy(true, 787.25, 2758.65);
					addEnemy(true, 874.7, 2758.65);
					addEnemy(true, 962.15, 2758.65);
					addEnemy(true, 1049.6, 2758.65);
					addEnemy(true, 1137.05, 2758.65);
					addEnemy(true, 1224.5, 2758.65);
					addEnemy(true, 1311.95, 2758.65);
					addEnemy(true, 1399.4, 2758.65);
					addEnemy(true, 1486.85, 2758.65);
					addEnemy(true, 1574.3, 2758.65);
					addEnemy(true, 1661.75, 2758.65);
					addEnemy(true, 1749.2, 2758.65);
					addEnemy(true, 1836.65, 2758.65);
					addEnemy(true, 1924.1, 2758.65);
					addEnemy(false, 1179, -151.1);
					addEnemy(false, 1930, -151.1);
					addEnemy(false, 1237.1, 386.6);
					addEnemy(false, 1697.05, 386.6);
					addEnemy(false, 2157, 386.6);
					addEnemy(false, 1281, 838.3);
					addEnemy(false, 1930, 838.3);
					addEnemy(false, 694.5, 1383.15);
					addEnemy(false, 1291.65, 1383.15);
					addEnemy(false, 1888.8, 1383.15);
					addEnemy(false, -71.2, 1861.65);
					addEnemy(false, 131.75, 1861.65);
					addEnemy(false, 334.7, 1861.65);
					addEnemy(false, -13.8, 2777.9);
					addEnemy(false, 200, 2777.9);
					addEnemy(false, 413.8, 2777.9);
					addEnemy(false, 627.6, 2777.9);
					addEnemy(false, 841.4, 2777.9);
					addEnemy(false, 1055.2, 2777.9);
					addEnemy(false, 1269, 2777.9);
					addEnemy(false, 1482.8, 2777.9);
					addEnemy(false, 1696.6, 2777.9);
					addEnemy(false, 1910.4, 2777.9);
					break;
				case 6:
					addEnemy(true, 664.45, 387.25);
					addEnemy(true, 782.3, 387.25);
					addEnemy(true, 900.15, 387.25);
					addEnemy(true, 1018, 387.25);
					addEnemy(true, 1135.85, 387.25);
					addEnemy(true, 1253.7, 387.25);
					addEnemy(true, 1371.55, 387.25);
					addEnemy(true, 1886.9, 387.25);
					addEnemy(true, 2020, 387.25);
					addEnemy(true, 2153.1, 387.25);
					addEnemy(true, 2286.2, 387.25);
					addEnemy(true, 2419.3, 387.25);
					addEnemy(true, 2552.4, 387.25);
					addEnemy(true, 2685.5, 387.25);
					addEnemy(true, 2818.6, 387.25);
					addEnemy(true, 2795.55, 120.4);
					addEnemy(true, 2667.75, 120.4);
					addEnemy(true, 2539.95, 120.4);
					addEnemy(true, 2361.05, 120.4);
					addEnemy(true, 2206.3, 120.4);
					addEnemy(true, 2051.55, 120.4);
					addEnemy(true, 1896.8, 120.4);
					addEnemy(true, 1742.05, 120.4);
					addEnemy(true, 1587.3, 120.4);
					addEnemy(true, 1432.55, 120.4);
					addEnemy(true, 1277.8, 120.4);
					addEnemy(true, 1123.05, 120.4);
					addEnemy(true, 805.05, -157);
					addEnemy(true, 921.45, -157);
					addEnemy(true, 1037.85, -157);
					addEnemy(true, 1154.25, -157);
					addEnemy(true, 1270.65, -157);
					addEnemy(true, 1387.05, -157);
					addEnemy(true, 1503.45, -157);
					addEnemy(true, 1619.85, -157);
					addEnemy(true, 1736.25, -157);
					addEnemy(true, 1852.65, -157);
					addEnemy(true, 1969.05, -157);
					addEnemy(true, 2085.45, -157);
					addEnemy(true, 2201.85, -157);
					addEnemy(true, 2318.25, -157);
					addEnemy(true, 2434.65, -157);
					addEnemy(true, 3125.7, -157);
					addEnemy(true, 3192.3, -157);
					addEnemy(true, 3258.9, -157);
					addEnemy(true, 3325.5, -157);
					addEnemy(true, 3392.1, -157);
					addEnemy(true, 3458.7, -157);
					addEnemy(true, 3525.3, -157);
					addEnemy(true, 3591.9, -157);
					addEnemy(true, 3658.5, -157);
					addEnemy(true, 3725.1, -157);
					addEnemy(true, 3791.7, -157);
					addEnemy(true, 3858.3, -157);
					addEnemy(true, 3924.9, -157);
					addEnemy(true, 3991.5, -157);
					addEnemy(true, 4058.1, -157);
					addEnemy(false, 2386.7, 380.75);
					addEnemy(false, 2414.5, 120.4);
					addEnemy(false, 2548, 120.4);
					addEnemy(false, 811.45, 120.4);
					addEnemy(false, 986.7, 120.4);
					addEnemy(false, 1250, 120.4);
					addEnemy(false, 1513.3, 120.4);
					addEnemy(false, 1776.6, 120.4);
					addEnemy(false, 898.75, -157);
					addEnemy(false, 1104.6, -157);
					addEnemy(false, 1310.45, -157);
					addEnemy(false, 2815.9, -157);
					addEnemy(false, 2946.65, -157);
					addEnemy(false, 3077.4, -157);
					addEnemy(false, 3208.15, -157);
					addEnemy(false, 3338.9, -157);
					addEnemy(false, 3469.65, -157);
					addEnemy(false, 3600.4, -157);
					addEnemy(false, 3731.15, -157);
					addEnemy(false, 3861.9, -157);
					addEnemy(false, 3992.65, -157);
					break;
				case 7:
					addEnemy(true, 1191.05, -153.65);
					addEnemy(true, 1137.7, -153.65);
					addEnemy(true, 1084.35, -153.65);
					addEnemy(true, 1031, -153.65);
					addEnemy(true, 977.65, -153.65);
					addEnemy(true, 924.3, -153.65);
					addEnemy(true, 870.95, -153.65);
					addEnemy(true, 817.6, -153.65);
					addEnemy(true, 764.25, -153.65);
					addEnemy(true, 710.9, -153.65);
					addEnemy(true, 657.55, -153.65);
					addEnemy(true, 604.2, -153.65);
					addEnemy(true, 550.85, -153.65);
					addEnemy(true, 497.5, -153.65);
					addEnemy(true, 444.15, -153.65);
					addEnemy(true, 390.8, -153.65);
					addEnemy(true, 337.45, -153.65);
					addEnemy(true, 284.1, -153.65);
					addEnemy(true, 230.75, -153.65);
					addEnemy(true, 177.4, -153.65);
					addEnemy(true, 1955.75, -153.65);
					addEnemy(true, 2053.55, -153.65);
					addEnemy(true, 2151.35, -153.65);
					addEnemy(true, 2249.15, -153.65);
					addEnemy(true, 2346.95, -153.65);
					addEnemy(true, 3588.9, -153.65);
					addEnemy(true, 3486.65, -153.65);
					addEnemy(true, 3384.4, -153.65);
					addEnemy(true, 3282.15, -153.65);
					addEnemy(true, 3179.9, -153.65);
					addEnemy(true, 3077.65, -153.65);
					addEnemy(true, 2975.4, -153.65);
					addEnemy(true, 4278.1, -153.65);
					addEnemy(true, 4380, -153.65);
					addEnemy(true, 4481.9, -153.65);
					addEnemy(true, 4583.8, -153.65);
					addEnemy(true, 4685.7, -153.65);
					addEnemy(true, 4787.6, -153.65);
					addEnemy(true, 4889.5, -153.65);
					addEnemy(true, 4991.4, -153.65);
					addEnemy(true, 5093.3, -153.65);
					addEnemy(true, 5195.2, -153.65);
					addEnemy(true, 5297.1, -153.65);
					addEnemy(true, 5399, -153.65);
					addEnemy(true, 5500.9, -153.65);
					addEnemy(true, 5602.8, -153.65);
					addEnemy(true, 5704.7, -153.65);
					addEnemy(true, 5806.6, -153.65);
					addEnemy(true, 5908.5, -153.65);
					addEnemy(true, 6010.4, -153.65);
					addEnemy(true, 6112.3, -153.65);
					addEnemy(true, 6214.2, -153.65);
					addEnemy(true, 7192.65, -153.65);
					addEnemy(true, 7317.15, -153.65);
					addEnemy(true, 7441.65, -153.65);
					addEnemy(true, 7566.15, -153.65);
					addEnemy(true, 7690.65, -153.65);
					addEnemy(true, 7815.15, -153.65);
					addEnemy(true, 7939.65, -153.65);
					addEnemy(true, 8064.15, -153.65);
					addEnemy(false, 842.85, -156.95);
					addEnemy(false, 692.95, -156.95);
					addEnemy(false, 2337.45, -156.95);
					addEnemy(false, 2444.15, -156.95);
					addEnemy(false, 2550.85, -156.95);
					addEnemy(false, 3184.2, -156.95);
					addEnemy(false, 3046.4, -156.95);
					addEnemy(false, 2908.6, -156.95);
					addEnemy(false, 2770.8, -156.95);
					addEnemy(false, 2633, -156.95);
					addEnemy(false, 4740.4, -156.95);
					addEnemy(false, 4878.25, -156.95);
					addEnemy(false, 5016.1, -156.95);
					addEnemy(false, 5153.95, -156.95);
					addEnemy(false, 5291.8, -156.95);
					addEnemy(false, 5429.65, -156.95);
					addEnemy(false, 5567.5, -156.95);
					addEnemy(false, 5705.35, -156.95);
					addEnemy(false, 5843.2, -156.95);
					addEnemy(false, 5981.05, -156.95);
					addEnemy(false, 7607.1, -156.95);
					addEnemy(false, 7700, -156.95);
					addEnemy(false, 7792.9, -156.95);
					addEnemy(false, 7885.8, -156.95);
					addEnemy(false, 7978.7, -156.95);
					addEnemy(false, 8071.6, -156.95);
					addEnemy(false, 8164.5, -156.95);
					addEnemy(false, 8257.4, -156.95);
					addEnemy(false, 8350.3, -156.95);
					addEnemy(false, 8443.2, -156.95);
					addEnemy(false, 8536.1, -156.95);
					addEnemy(false, 8629, -156.95);
					break;
				case 8:
					addEnemy(true, -1928.65, -279.35);
					addEnemy(true, -1837, -279.35);
					addEnemy(true, -1745.35, -279.35);
					addEnemy(true, -1653.7, -279.35);
					addEnemy(true, -1562.05, -279.35);
					addEnemy(true, -1470.4, -279.35);
					addEnemy(true, -1378.75, -279.35);
					addEnemy(true, -1287.1, -279.35);
					addEnemy(true, -1195.45, -279.35);
					addEnemy(true, -1103.8, -279.35);
					addEnemy(true, -1012.15, -279.35);
					addEnemy(true, -920.5, -279.35);
					addEnemy(true, -828.85, -279.35);
					addEnemy(true, -737.5, -279.35);
					addEnemy(true, -645.55, -279.35);
					addEnemy(true, -553.9, -279.35);
					addEnemy(true, -462.25, -279.35);
					addEnemy(true, -370.6, -279.35);
					addEnemy(true, -278.95, -279.35);
					addEnemy(true, -187.6, -279.35);
					addEnemy(true, -95.65, -279.35);
					addEnemy(true, -4, -279.35);
					addEnemy(true, 87.65, -279.35);
					addEnemy(true, 179.3, -279.35);
					addEnemy(true, 270.95, -279.35);
					addEnemy(true, 362.6, -279.35);
					addEnemy(true, 454.25, -279.35);
					addEnemy(true, 545.9, -279.35);
					addEnemy(true, 637.55, -279.35);
					addEnemy(true, 729.2, -279.35);
					addEnemy(true, 669.6, -551.2);
					addEnemy(true, 720.35, -551.2);
					addEnemy(true, 771.1, -551.2);
					addEnemy(true, -929.15, -551.2);
					addEnemy(true, -840, -551.2);
					addEnemy(true, -750.85, -551.2);
					addEnemy(true, -661.7, -551.2);
					addEnemy(true, -572.55, -551.2);
					addEnemy(true, -483.4, -551.2);
					addEnemy(true, -394.25, -551.2);
					addEnemy(true, -305.1, -551.2);
					addEnemy(true, -215.95, -551.2);
					addEnemy(true, -126.8, -551.2);
					addEnemy(true, -37.65, -551.2);
					addEnemy(true, 51.5, -551.2);
					addEnemy(true, 140.65, -551.2);
					addEnemy(true, 229.8, -551.2);
					addEnemy(true, 318.95, -551.2);
					addEnemy(true, -2242.95, -551.2);
					addEnemy(true, -2147.2, -551.2);
					addEnemy(true, -2051.45, -551.2);
					addEnemy(true, -1955.7, -551.2);
					addEnemy(true, -1859.95, -551.2);
					addEnemy(true, -2061.45, -827.2);
					addEnemy(true, -1697.3, -827.2);
					addEnemy(true, -1600, -827.2);
					addEnemy(true, -1502.7, -827.2);
					addEnemy(true, -1405.4, -827.2);
					addEnemy(true, -1308.1, -827.2);
					addEnemy(true, -1210.8, -827.2);
					addEnemy(true, -1113.5, -827.2);
					addEnemy(true, -1016.2, -827.2);
					addEnemy(true, -918.9, -827.2);
					addEnemy(true, -821.6, -827.2);
					addEnemy(true, -431.1, -827.2);
					addEnemy(true, -333.8, -827.2);
					addEnemy(true, -236.5, -827.2);
					addEnemy(true, -139.2, -827.2);
					addEnemy(true, -41.9, -827.2);
					addEnemy(true, 55.4, -827.2);
					addEnemy(true, 152.7, -827.2);
					addEnemy(true, 250, -827.2);
					addEnemy(true, 755.2, -827.2);
					addEnemy(true, 875.75, -827.2);
					addEnemy(true, 996.3, -827.2);
					addEnemy(true, 679.05, -1098.7);
					addEnemy(true, 720.3, -1098.7);
					addEnemy(true, -415.35, -1098.7);
					addEnemy(true, -329.7, -1098.7);
					addEnemy(true, -1328.9, -1098.7);
					addEnemy(true, -1372.15, -1098.7);
					addEnemy(true, -1415.4, -1098.7);
					addEnemy(true, -1458.65, -1098.7);
					addEnemy(true, -1501.9, -1098.7);
					addEnemy(true, -1545.15, -1098.7);
					addEnemy(true, -1588.4, -1098.7);
					addEnemy(true, -1631.65, -1098.7);
					addEnemy(true, -1674.9, -1098.7);
					addEnemy(true, -1718.15, -1098.7);
					addEnemy(true, -1761.4, -1098.7);
					addEnemy(true, -1804.65, -1098.7);
					addEnemy(true, -1847.9, -1098.7);
					addEnemy(true, -1891.15, -1098.7);
					addEnemy(true, -1934.4, -1098.7);
					addEnemy(true, -1977.65, -1098.7);
					addEnemy(true, -2020.9, -1098.7);
					addEnemy(true, -2064.15, -1098.7);
					addEnemy(false, -1571.4, -276.2);
					addEnemy(false, -1375, -276.2);
					addEnemy(false, -1178.6, -276.2);
					addEnemy(false, -982.2, -276.2);
					addEnemy(false, -785.8, -276.2);
					addEnemy(false, -589.4, -276.2);
					addEnemy(false, -393, -276.2);
					addEnemy(false, -196.6, -276.2);
					addEnemy(false, -0.2, -276.2);
					addEnemy(false, 196.2, -276.2);
					addEnemy(false, 617.35, -554.35);
					addEnemy(false, -549.1, -554.35);
					addEnemy(false, -428.55, -554.35);
					addEnemy(false, -308, -554.35);
					addEnemy(false, -187.45, -554.35);
					addEnemy(false, -66.9, -554.35);
					addEnemy(false, -2360.45, -554.35);
					addEnemy(false, -1552.35, -827.15);
					addEnemy(false, -1428.65, -827.15);
					addEnemy(false, -1304.95, -827.15);
					addEnemy(false, -1181.25, -827.15);
					addEnemy(false, -1057.55, -827.15);
					addEnemy(false, 1061.45, -827.15);
					addEnemy(false, 896.5, -827.15);
					addEnemy(false, 731.55, -827.15);
					addEnemy(false, 46.35, -1098.7);
					addEnemy(false, 214.5, -1098.7);
					addEnemy(false, -1571.4, -1098.7);
					addEnemy(false, -1431.8, -1098.7);
					addEnemy(false, -1292.2, -1098.7);
					addEnemy(false, -1152.6, -1098.7);
					addEnemy(false, -1013, -1098.7);
					addEnemy(false, -873.4, -1098.7);
					addEnemy(false, -733.8, -1098.7);
					break;
				case 9:
					addEnemy(true, 456.9, -1360.75);
					addEnemy(true, 348.75, -1360.75);
					addEnemy(true, 240.6, -1360.75);
					addEnemy(true, 132.45, -1360.75);
					addEnemy(true, 24.3000000000001, -1360.75);
					addEnemy(true, -83.8499999999999, -1360.75);
					addEnemy(true, -192, -1360.75);
					addEnemy(true, -300.15, -1360.75);
					addEnemy(true, -408.3, -1360.75);
					addEnemy(true, -516.45, -1360.75);
					addEnemy(true, -624.6, -1360.75);
					addEnemy(true, -732.75, -1360.75);
					addEnemy(true, -840.9, -1360.75);
					addEnemy(true, -949.05, -1360.75);
					addEnemy(true, -1057.2, -1360.75);
					addEnemy(true, -1165.35, -1360.75);
					addEnemy(true, -1273.5, -1360.75);
					addEnemy(true, -1381.65, -1360.75);
					addEnemy(true, -1489.8, -1360.75);
					addEnemy(true, -1597.95, -1360.75);
					addEnemy(true, -1706.1, -1360.75);
					addEnemy(true, -1814.25, -1360.75);
					addEnemy(true, -1922.4, -1360.75);
					addEnemy(true, -2030.55, -1360.75);
					addEnemy(true, 348.75, -1091.45);
					addEnemy(true, 240.6, -1091.45);
					addEnemy(true, 132.45, -1091.45);
					addEnemy(true, 24.3000000000001, -1091.45);
					addEnemy(true, -83.8499999999999, -1091.45);
					addEnemy(true, -192, -1091.45);
					addEnemy(true, -300.15, -1091.45);
					addEnemy(true, -408.3, -1091.45);
					addEnemy(true, -516.45, -1091.45);
					addEnemy(true, -624.6, -1091.45);
					addEnemy(true, -732.75, -1091.45);
					addEnemy(true, -840.9, -1091.45);
					addEnemy(true, -949.05, -1091.45);
					addEnemy(true, -1057.2, -1091.45);
					addEnemy(true, -1165.35, -1091.45);
					addEnemy(true, -1273.5, -1091.45);
					addEnemy(true, -1381.65, -1091.45);
					addEnemy(true, -1489.8, -1091.45);
					addEnemy(true, -1597.95, -1091.45);
					addEnemy(true, -1706.1, -1091.45);
					addEnemy(true, -1814.25, -1091.45);
					addEnemy(true, -1922.4, -1091.45);
					addEnemy(true, -2030.55, -1091.45);
					addEnemy(true, 456.9, -820.2);
					addEnemy(true, 348.75, -820.2);
					addEnemy(true, 240.6, -820.2);
					addEnemy(true, 132.45, -820.2);
					addEnemy(true, 24.3000000000001, -820.2);
					addEnemy(true, -83.8499999999999, -820.2);
					addEnemy(true, -192, -820.2);
					addEnemy(true, -300.15, -820.2);
					addEnemy(true, -408.3, -820.2);
					addEnemy(true, -516.45, -820.2);
					addEnemy(true, -624.6, -820.2);
					addEnemy(true, -732.75, -820.2);
					addEnemy(true, -840.9, -820.2);
					addEnemy(true, -949.05, -820.2);
					addEnemy(true, -1057.2, -820.2);
					addEnemy(true, -1165.35, -820.2);
					addEnemy(true, -1273.5, -820.2);
					addEnemy(true, -1381.65, -820.2);
					addEnemy(true, -1489.8, -820.2);
					addEnemy(true, 456.9, -554.3);
					addEnemy(true, 348.75, -554.3);
					addEnemy(true, 240.6, -554.3);
					addEnemy(true, 132.45, -554.3);
					addEnemy(true, 24.3000000000001, -554.3);
					addEnemy(true, -83.8499999999999, -554.3);
					addEnemy(true, -192, -554.3);
					addEnemy(true, -300.15, -554.3);
					addEnemy(true, -408.3, -554.3);
					addEnemy(true, -516.45, -554.3);
					addEnemy(true, -624.6, -554.3);
					addEnemy(true, -732.75, -554.3);
					addEnemy(true, -840.9, -554.3);
					addEnemy(true, -949.05, -554.3);
					addEnemy(true, -1057.2, -554.3);
					addEnemy(true, -1165.35, -554.3);
					addEnemy(true, -1273.5, -554.3);
					addEnemy(true, -1381.65, -554.3);
					addEnemy(true, -1489.8, -554.3);
					addEnemy(true, -1597.95, -554.3);
					addEnemy(true, -1706.1, -554.3);
					addEnemy(true, -1814.25, -554.3);
					addEnemy(true, -1922.4, -554.3);
					addEnemy(true, -2030.55, -554.3);
					addEnemy(true, 654.3, -280.25);
					addEnemy(true, 533.4, -280.25);
					addEnemy(true, 412.5, -280.25);
					addEnemy(true, 291.6, -280.25);
					addEnemy(true, 170.7, -280.25);
					addEnemy(true, 49.8000000000001, -280.25);
					addEnemy(true, -71.0999999999999, -280.25);
					addEnemy(true, -192, -280.25);
					addEnemy(true, -312.9, -280.25);
					addEnemy(true, -433.8, -280.25);
					addEnemy(true, -554.7, -280.25);
					addEnemy(true, -675.6, -280.25);
					addEnemy(true, -796.5, -280.25);
					addEnemy(true, -917.4, -280.25);
					addEnemy(true, -1155.05, -280.25);
					addEnemy(true, -1227.5, -280.25);
					addEnemy(true, -1299.95, -280.25);
					addEnemy(true, -1372.4, -280.25);
					addEnemy(true, -1444.85, -280.25);
					addEnemy(true, -1517.3, -280.25);
					addEnemy(true, -1589.75, -280.25);
					addEnemy(true, -1662.2, -280.25);
					addEnemy(true, -1734.65, -280.25);
					addEnemy(true, -1807.1, -280.25);
					addEnemy(true, -1879.55, -280.25);
					addEnemy(true, -1952, -280.25);
					addEnemy(true, -2024.45, -280.25);
					addEnemy(true, -2096.9, -280.25);
					addEnemy(false, 241.7, -1367.65);
					addEnemy(false, 65.6, -1367.65);
					addEnemy(false, -110.5, -1367.65);
					addEnemy(false, -286.6, -1367.65);
					addEnemy(false, -462.7, -1367.65);
					addEnemy(false, -638.8, -1367.65);
					addEnemy(false, -814.9, -1367.65);
					addEnemy(false, -991, -1367.65);
					addEnemy(false, -1167.1, -1367.65);
					addEnemy(false, -1343.2, -1367.65);
					addEnemy(false, -1519.3, -1367.65);
					addEnemy(false, 241.7, -1098.35);
					addEnemy(false, 65.6, -1098.35);
					addEnemy(false, -110.5, -1098.35);
					addEnemy(false, -286.6, -1098.35);
					addEnemy(false, -462.7, -1098.35);
					addEnemy(false, -638.8, -1098.35);
					addEnemy(false, -814.9, -1098.35);
					addEnemy(false, -991, -1098.35);
					addEnemy(false, -1167.1, -1098.35);
					addEnemy(false, -1343.2, -1098.35);
					addEnemy(false, -1519.3, -1098.35);
					addEnemy(false, 241.7, -820.2);
					addEnemy(false, 65.6, -820.2);
					addEnemy(false, -110.5, -820.2);
					addEnemy(false, -286.6, -820.2);
					addEnemy(false, -462.7, -820.2);
					addEnemy(false, -638.8, -820.2);
					addEnemy(false, -814.9, -820.2);
					addEnemy(false, -991, -820.2);
					addEnemy(false, -1167.1, -820.2);
					addEnemy(false, 241.7, -550.85);
					addEnemy(false, 65.6, -550.85);
					addEnemy(false, -110.5, -550.85);
					addEnemy(false, -286.6, -550.85);
					addEnemy(false, -462.7, -550.85);
					addEnemy(false, -638.8, -550.85);
					addEnemy(false, -814.9, -550.85);
					addEnemy(false, -991, -550.85);
					addEnemy(false, -1167.1, -550.85);
					addEnemy(false, -1343.2, -550.85);
					addEnemy(false, -1519.3, -550.85);
					addEnemy(false, -1571.4, -280.35);
					addEnemy(false, -1447.1, -280.35);
					addEnemy(false, -1322.8, -280.35);
					addEnemy(false, -1198.5, -280.35);
					addEnemy(false, -1074.2, -280.35);
					addEnemy(false, -949.9, -280.35);
					addEnemy(false, -825.6, -280.35);
					addEnemy(false, -701.3, -280.35);
					addEnemy(false, -577, -280.35);
					addEnemy(false, -452.7, -280.35);
					addEnemy(false, -328.4, -280.35);
					addEnemy(false, -204.1, -280.35);
					addEnemy(false, -79.8, -280.35);
					addEnemy(false, 44.5, -280.35);
					addEnemy(false, 168.8, -280.35);
					break;
				case 10:
					addEnemy(true, -1791.9, -273.7);
					addEnemy(true, -1732.25, -273.7);
					addEnemy(true, -1672.6, -273.7);
					addEnemy(true, -1612.95, -273.7);
					addEnemy(true, -1553.3, -273.7);
					addEnemy(true, -1493.65, -273.7);
					addEnemy(true, -1434, -273.7);
					addEnemy(true, -1374.35, -273.7);
					addEnemy(true, -1314.7, -273.7);
					addEnemy(true, -1255.05, -273.7);
					addEnemy(true, -1195.4, -273.7);
					addEnemy(true, -1135.75, -273.7);
					addEnemy(true, -1076.1, -273.7);
					addEnemy(true, -1016.45, -273.7);
					addEnemy(true, -956.8, -273.7);
					addEnemy(true, -897.15, -273.7);
					addEnemy(true, -837.5, -273.7);
					addEnemy(true, -777.85, -273.7);
					addEnemy(true, -718.2, -273.7);
					addEnemy(true, -658.55, -273.7);
					addEnemy(true, 590.35, -273.7);
					addEnemy(true, 532.95, -273.7);
					addEnemy(true, 475.55, -273.7);
					addEnemy(true, 418.15, -273.7);
					addEnemy(true, 360.75, -273.7);
					addEnemy(true, 303.35, -273.7);
					addEnemy(true, 245.95, -273.7);
					addEnemy(true, 188.55, -273.7);
					addEnemy(true, 131.15, -273.7);
					addEnemy(true, 73.75, -273.7);
					addEnemy(true, 16.35, -273.7);
					addEnemy(true, -41.05, -273.7);
					addEnemy(true, -98.45, -273.7);
					addEnemy(true, -560.1, -564.2);
					addEnemy(true, -690.9, -564.2);
					addEnemy(true, -821.7, -564.2);
					addEnemy(true, -952.5, -564.2);
					addEnemy(true, -1083.3, -564.2);
					addEnemy(true, -1214.1, -564.2);
					addEnemy(true, -1344.9, -564.2);
					addEnemy(true, -1475.7, -564.2);
					addEnemy(true, -1606.5, -564.2);
					addEnemy(true, -1737.3, -564.2);
					addEnemy(true, -1868.1, -564.2);
					addEnemy(true, -1998.9, -564.2);
					addEnemy(true, -2129.7, -564.2);
					addEnemy(true, -2260.5, -564.2);
					addEnemy(true, -2073.95, -1174.6);
					addEnemy(true, -2039.5, -1174.6);
					addEnemy(true, -2005.05, -1174.6);
					addEnemy(true, -1970.6, -1174.6);
					addEnemy(true, -1936.15, -1174.6);
					addEnemy(true, -1901.7, -1174.6);
					addEnemy(true, -1867.25, -1174.6);
					addEnemy(true, -1832.8, -1174.6);
					addEnemy(true, -1798.35, -1174.6);
					addEnemy(true, -1763.9, -1174.6);
					addEnemy(true, -1729.45, -1174.6);
					addEnemy(true, -1695, -1174.6);
					addEnemy(true, -1660.55, -1174.6);
					addEnemy(true, -1626.1, -1174.6);
					addEnemy(true, -1591.65, -1174.6);
					addEnemy(true, -1557.2, -1174.6);
					addEnemy(true, -1522.75, -1174.6);
					addEnemy(true, -1488.3, -1174.6);
					addEnemy(true, -261.2, -1362.7);
					addEnemy(true, -139.6, -1362.7);
					addEnemy(true, -18, -1362.7);
					addEnemy(true, 103.6, -1362.7);
					addEnemy(true, 225.2, -1362.7);
					addEnemy(true, 346.8, -1362.7);
					addEnemy(true, 468.4, -1362.7);
					addEnemy(true, 590, -1362.7);
					addEnemy(true, 711.6, -1362.7);
					addEnemy(true, 833.2, -1362.7);
					addEnemy(true, 954.8, -1362.7);
					addEnemy(true, 1076.4, -1362.7);
					addEnemy(true, 1198, -1362.7);
					addEnemy(true, 1319.6, -1362.7);
					addEnemy(true, 1441.2, -1362.7);
					addEnemy(true, 1409.25, 716.2);
					addEnemy(true, 1533.15, 716.2);
					addEnemy(true, 1657.05, 716.2);
					addEnemy(true, -153.45, 450.05);
					addEnemy(true, -75.5, 450.05);
					addEnemy(true, 2.45, 450.05);
					addEnemy(true, 80.4, 450.05);
					addEnemy(true, 158.35, 450.05);
					addEnemy(true, 236.3, 450.05);
					addEnemy(true, 314.25, 450.05);
					addEnemy(true, 392.2, 450.05);
					addEnemy(true, 470.15, 450.05);
					addEnemy(true, 548.1, 450.05);
					addEnemy(true, 626.05, 450.05);
					addEnemy(true, 704, 450.05);
					addEnemy(true, 781.95, 450.05);
					addEnemy(true, 859.9, 450.05);
					addEnemy(true, 937.85, 450.05);
					addEnemy(true, 1015.8, 450.05);
					addEnemy(true, 1093.75, 450.05);
					addEnemy(true, 175, 718.55);
					addEnemy(true, 549, 718.55);
					addEnemy(true, 601.8, 1244);
					addEnemy(true, 549, 1244);
					addEnemy(true, 496.2, 1244);
					addEnemy(true, 443.4, 1244);
					addEnemy(true, 390.6, 1244);
					addEnemy(true, 337.8, 1244);
					addEnemy(true, 285, 1244);
					addEnemy(true, 232.2, 1244);
					addEnemy(true, 179.4, 1244);
					addEnemy(true, 126.6, 1244);
					addEnemy(true, 73.8, 1244);
					addEnemy(true, 21, 1244);
					addEnemy(true, -1049.6, 1131.5);
					addEnemy(true, -962.4, 1131.5);
					addEnemy(true, -875.2, 1131.5);
					addEnemy(true, -788, 1131.5);
					addEnemy(true, -700.8, 1131.5);
					addEnemy(true, -613.6, 1131.5);
					addEnemy(true, -526.4, 1131.5);
					addEnemy(true, -439.2, 1131.5);
					addEnemy(true, -352, 1131.5);
					addEnemy(true, -264.8, 1131.5);
					addEnemy(true, -177.6, 1131.5);
					addEnemy(true, -90.4, 1131.5);
					addEnemy(true, -3.2, 1131.5);
					addEnemy(true, 84, 1131.5);
					addEnemy(true, 171.2, 1131.5);
					addEnemy(true, 258.4, 1131.5);
					addEnemy(true, -3658, 3151.8);
					addEnemy(true, -3613.3, 3151.8);
					addEnemy(true, -3568.6, 3151.8);
					addEnemy(true, -3523.9, 3151.8);
					addEnemy(true, -3479.2, 3151.8);
					addEnemy(true, -3434.5, 3151.8);
					addEnemy(true, -3389.8, 3151.8);
					addEnemy(true, -3345.1, 3151.8);
					addEnemy(true, -3300.4, 3151.8);
					addEnemy(true, -3255.7, 3151.8);
					addEnemy(true, -3211, 3151.8);
					addEnemy(true, -3166.3, 3151.8);
					addEnemy(true, -3121.6, 3151.8);
					addEnemy(true, -3076.9, 3151.8);
					addEnemy(true, -3032.2, 3151.8);
					addEnemy(true, -2987.5, 3151.8);
					addEnemy(true, -2942.8, 3151.8);
					addEnemy(true, -2898.1, 3151.8);
					addEnemy(true, -2853.4, 3151.8);
					addEnemy(true, -2808.7, 3151.8);
					addEnemy(true, -2764, 3151.8);
					addEnemy(true, -2719.3, 3151.8);
					addEnemy(true, -2674.6, 3151.8);
					addEnemy(true, -2629.9, 3151.8);
					addEnemy(true, -2585.2, 3151.8);
					addEnemy(true, -2540.5, 3151.8);
					addEnemy(true, -2495.8, 3151.8);
					addEnemy(true, -2451.1, 3151.8);
					addEnemy(true, -2406.4, 3151.8);
					addEnemy(true, -2361.7, 3151.8);
					addEnemy(true, -2317, 3151.8);
					addEnemy(true, -2272.3, 3151.8);
					addEnemy(true, -2227.6, 3151.8);
					addEnemy(true, -2182.9, 3151.8);
					addEnemy(true, -2138.2, 3151.8);
					addEnemy(true, -2093.5, 3151.8);
					addEnemy(true, -2048.8, 3151.8);
					addEnemy(true, -2004.1, 3151.8);
					addEnemy(true, -1959.4, 3151.8);
					addEnemy(true, -1914.7, 3151.8);
					addEnemy(true, -1870, 3151.8);
					addEnemy(true, -1825.3, 3151.8);
					addEnemy(true, -1780.6, 3151.8);
					addEnemy(true, -1735.9, 3151.8);
					addEnemy(true, -1691.2, 3151.8);
					addEnemy(true, -1646.5, 3151.8);
					addEnemy(true, -1601.8, 3151.8);
					addEnemy(true, -1557.1, 3151.8);
					addEnemy(true, -1512.4, 3151.8);
					addEnemy(true, -1467.7, 3151.8);
					addEnemy(true, -1423, 3151.8);
					addEnemy(true, -1378.3, 3151.8);
					addEnemy(true, -1333.6, 3151.8);
					addEnemy(true, -1288.9, 3151.8);
					addEnemy(true, -1244.2, 3151.8);
					addEnemy(true, -1199.5, 3151.8);
					addEnemy(true, -1154.8, 3151.8);
					addEnemy(true, -1110.1, 3151.8);
					addEnemy(false, 246.35, -289.45);
					addEnemy(false, 139.8, -289.45);
					addEnemy(false, 33.25, -289.45);
					addEnemy(false, -73.3, -289.45);
					addEnemy(false, -179.85, -289.45);
					addEnemy(false, -156.85, -545.8);
					addEnemy(false, -44.55, -545.8);
					addEnemy(false, 67.75, -545.8);
					addEnemy(false, 180.05, -545.8);
					addEnemy(false, 292.35, -545.8);
					addEnemy(false, 404.65, -545.8);
					addEnemy(false, 516.95, -545.8);
					addEnemy(false, 629.25, -545.8);
					addEnemy(false, 741.55, -545.8);
					addEnemy(false, -1353.25, -819.35);
					addEnemy(false, -1231.65, -819.35);
					addEnemy(false, -1110.05, -819.35);
					addEnemy(false, -988.45, -819.35);
					addEnemy(false, -866.85, -819.35);
					addEnemy(false, -745.25, -819.35);
					addEnemy(false, -623.65, -819.35);
					addEnemy(false, -502.05, -819.35);
					addEnemy(false, -380.45, -819.35);
					addEnemy(false, -258.85, -819.35);
					addEnemy(false, -137.25, -819.35);
					addEnemy(false, -15.65, -819.35);
					addEnemy(false, 105.95, -819.35);
					addEnemy(false, 227.55, -819.35);
					addEnemy(false, 349.15, -819.35);
					addEnemy(false, 470.75, -819.35);
					addEnemy(false, 592.35, -819.35);
					addEnemy(false, 713.95, -819.35);
					addEnemy(false, 835.55, -819.35);
					addEnemy(false, 957.15, -819.35);
					addEnemy(false, -215.2, 441.9);
					addEnemy(false, -82.75, 441.9);
					addEnemy(false, 49.7, 441.9);
					addEnemy(false, 182.15, 441.9);
					addEnemy(false, 314.6, 441.9);
					addEnemy(false, 447.05, 441.9);
					addEnemy(false, 579.5, 441.9);
					addEnemy(false, 711.95, 441.9);
					addEnemy(false, 844.4, 441.9);
					addEnemy(false, 976.85, 441.9);
					addEnemy(false, 1109.3, 441.9);
					addEnemy(false, -1332.45, 1406.55);
					addEnemy(false, -1470.65, 1406.55);
					addEnemy(false, -1608.85, 1406.55);
					addEnemy(false, -1747.05, 1406.55);
					addEnemy(false, -1885.25, 1406.55);
					addEnemy(false, -2023.45, 1406.55);
					addEnemy(false, -3247.35, 3151.45);
					addEnemy(false, -3198.35, 3151.45);
					addEnemy(false, -3149.35, 3151.45);
					addEnemy(false, -3100.35, 3151.45);
					addEnemy(false, -3051.35, 3151.45);
					addEnemy(false, -3002.35, 3151.45);
					addEnemy(false, -2953.35, 3151.45);
					addEnemy(false, -2904.35, 3151.45);
					addEnemy(false, -2855.35, 3151.45);
					addEnemy(false, -2806.35, 3151.45);
					addEnemy(false, -2757.35, 3151.45);
					addEnemy(false, -2708.35, 3151.45);
					addEnemy(false, -2659.35, 3151.45);
					addEnemy(false, -2610.35, 3151.45);
					addEnemy(false, -2561.35, 3151.45);
					addEnemy(false, -2512.35, 3151.45);
					addEnemy(false, -2463.35, 3151.45);
					addEnemy(false, -2414.35, 3151.45);
					addEnemy(false, -2365.35, 3151.45);
					addEnemy(false, -2316.35, 3151.45);
					addEnemy(false, -2267.35, 3151.45);
					addEnemy(false, -2218.35, 3151.45);
					addEnemy(false, -2169.35, 3151.45);
					addEnemy(false, -2120.35, 3151.45);
					addEnemy(false, -2071.35, 3151.45);
					addEnemy(false, -2022.35, 3151.45);
					addEnemy(false, -1973.35, 3151.45);
					addEnemy(false, -1924.35, 3151.45);
					addEnemy(false, -1875.35, 3151.45);
					addEnemy(false, -1826.35, 3151.45);
					addEnemy(false, -1777.35, 3151.45);
					addEnemy(false, -1728.35, 3151.45);
					addEnemy(false, -1679.35, 3151.45);
					addEnemy(false, -1630.35, 3151.45);
					addEnemy(false, -1581.35, 3151.45);
					break;
			}
		}
		function KillEnemies():void{
			if (enemyList.length > 0){
				//trace(enemyList.length);
				for (var i:int = enemyList.length - 1; i >= 0; i--) {
					trace("DIE " + i + " " + enemyList[i]);					
					enemyList[i].actuallyDead();
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
			
			
			
			//Regen area code
			var MaxRegens:Boolean = false;
				var RegI:int = 1;
				//Regen Iterator
				
				while(MaxRegens != true){
					if(back.getChildByName("Regen" + RegI) == null){
						MaxRegens = true;
					} else{
						if(MovieClip(back.getChildByName("Regen" + RegI)).hitTestObject(player.LadDec)){
							/*if(upPressed){
								ySpeed = -20;
							} else if(downPressed){
								ySpeed = 20;
							}
							OnLad = true;*/
							if(HP < 99){
								HP += 1;
							} else if(HP < 100){
								HP = 100;
							}
							trace("Regenning");
						}
						RegI++;
					}
				}
			
			
			
			if(player.Figure){
				//HACK to fix something broken... IDK what	
				
				
				//Additional code dealing with contact damage
				if (enemyList.length > 0){
					for (var l:int = 0; l < enemyList.length; l++) {
						if (player.DamageHitBox.hitTestObject(enemyList[l].HitBox) ){
							//You actually walking into the enemy
							trace("Player and Enemy are colliding");
							HP -= 2;
							
							if(player.Figure.scaleX == -1){
								xSpeed += 2*speedConstant;
							} else if(player.Figure.scaleX == 1){
								xSpeed -= 2*speedConstant;
							}
						}
						if(enemyList[l].IsMelee == true){
							//You coming in range of a melee enemy hitting you
							if(player.DamageHitBox.hitTestObject(enemyList[l].LHitBox) || player.DamageHitBox.hitTestObject(enemyList[l].RHitBox)){
								//HP -= 0.1;
								if(enemyList[l].getJustAttacked() == 0){
									HP -= 1;
									enemyList[l].setJustAttacked(10);
									enemyList[l].setPrevHPCount(10);
									//WasHit = 3;
								}
							}/* else if(player.DamageHitBox.hitTestObject(enemyList[l].RHitBox)){
								HP -= 0.1;
							}*/
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
				//trace(AnimationTimer);/*
				/*
				if(WasHit == 0){
				WasHit--;
				AddEvents();
			} else if(WasHit > 0){
				WasHit--;
			}
				*/
				if(WasHit > -1){
					AnimationState = "Hurt";
					if(WasHit == 0){
						AddEvents();
					}
					WasHit--;
				} else if(attackPressed || (AnimationTimer < 10 && AnimationTimer > 0) || (AnimationTimer > 20 && AnimationTimer < 40)){
					
					if(AnimationTimer < 20){
						AnimationState = "Melee 1";
					} else{
						AnimationState = "Melee 2";
					}
					
					if(AnimationTimer < 40){
						AnimationTimer++;
					} else{
						AnimationTimer = 0;
					}
					
					
					
					//Melee version of same code that deals with enemies
					if (enemyList.length > 0 && ((player.currentLabel == "Melee 1") || (player.currentLabel == "Melee 2"))){
						for (var i:int = 0; i < enemyList.length; i++) {
							if (player.HitBox.hitTestObject(enemyList[i].AttackBound) ){
								//trace("Player Attack and Enemy are colliding");
								
								if(KickedGuy == 0){
									enemyList[i].removeSelf(10);
								}
								
							}
							
						}
						
					}
					if(KickedGuy == 0){
						KickedGuy = 20;
						//trace("Reset Kick");
					} else{
						KickedGuy--;
						//trace("Kick--");
					}
					
					
				} else if((leftPressed || rightPressed || xSpeed > speedConstant || xSpeed < speedConstant*-1) && Bumping[1]){
					AnimationState = "Running";
				} else if(Bumping[1]){
					AnimationState = "Idle";
				} else{
					AnimationState = "Jumping";
				}
			}
			
			
			if((AnimationTimer != 0 && AnimationTimer != 20) && !(attackPressed || (AnimationTimer < 10 && AnimationTimer > 0) || (AnimationTimer > 20 && AnimationTimer < 40))){
				if(AnimationTimer > 0 && AnimationTimer < 20){
					trace("2");
					AnimationTimer = 20;
				} else{
					trace("1");
					AnimationTimer = 0;
					
				}
				
				
			}
			
			//Updates the player animation
			UpdatePlayer();
			
			
			
			
			//People Shooting Each Other Code
			//===============================
			
			//You shooting the enemy
			if (enemyList.length > 0){
				for (var k:int = 0; k < enemyList.length; k++) {
					if (bulletList.length > 0) {
						for (var j:int = 0; j < bulletList.length; j++) {
							if ( enemyList[k].AttackBound.hitTestObject(bulletList[j]) ){
								trace("Bullet and Enemy are colliding");
								enemyList[k].removeSelf(40);
								bulletList[j].removeSelf();
							}
						}
					}
				}
			}
			//The enemy shooting you
			if(enemyBulletList.length > 0){
				for(var m:int = 0; m < enemyBulletList.length; m++){
					if(enemyBulletList[m].hitTestObject(player)){
						HP = HP - 10;
						WasHit = 10;
						RemoveEvents();
						enemyBulletList[m].removeSelf();
					}
				}
			}
			
			
			
			
			
			//Completing the level
			//if(downPressed){
				//trace("Down Pressed");
				if(player.hitTestObject(back.Exit)){
					//LEVEL COMPLETE CODE TO GO HERE
					//gotoAndStop(1, "Level Select");
					//stage.removeEventListener(Event.ENTER_FRAME, FrameCode);
					LevelComplete(true);
				} else if(player.hitTestObject(back.Amend) && !IgnoreAmend){
					GetAmend();
				}
			//}
			//trace(HP);
			
			HBar.HBar.scaleX = HP / 100;
			if(HealthAtBeg != HP){
				IsTakeDam.alpha = 1;
				//WasHit = 5;
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
			if(FiredGun > 0){
				FiredGun--;
				return;
			}
			if(player.currentLabel != AnimationState){
				player.gotoAndStop(AnimationState);
				player.Figure.gotoAndPlay(1);
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
		public function GetAmend():void{
			Amend = new AmendPopup();
			stage.addChild(Amend);
			Amend.x = 640;
			Amend.y = 360;
			//Amend.name = "AmendmentPop";
			RemoveEvents();
			IgnoreAmend = true;
			stage.removeEventListener(Event.ENTER_FRAME, FrameCode);
			Amend.Close.addEventListener(MouseEvent.CLICK, CloseAmend);
			
			
			switch(CurrLev){
				case 1:
					Amend.Title.text = "Amendment 2";
					Amend.AmendText.text = "A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.";
					Amend.Explanation.text = "Gives you the right to use a gun\n\nPress c to shoot";
					break;
				case 2:
					Amend.Title.text = "Amendment 4";
					Amend.AmendText.text = "The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no warrants shall issue, but upon probable cause, supported by oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.";
					Amend.Explanation.text = "Since you can no longer be illegally seized, you spend less time paralyzed after each hit\n\nTime paralyzed after each hit reduced by 50%";
					break;
				case 3:
					Amend.Title.text = "Amendment 5";
					Amend.AmendText.text = "No person shall be held to answer for a capital, or otherwise infamous crime, unless on a presentment or indictment of a grand jury, except in cases arising in the land or naval forces, or in the militia, when in actual service in time of war or public danger; nor shall any person be subject for the same offense to be twice put in jeopardy of life or limb; nor shall be compelled in any criminal case to be a witness against himself, nor be deprived of life, liberty, or property, without due process of law; nor shall private property be taken for public use, without just compensation.";
					Amend.Explanation.text = "As it's illegal to be hurt twice for the same crime, guards can no longer catch you as quickly (it's a stretch - get used to it)\n\nAttack speed of guards reduced by 10%";
					break;
				case 4:
					Amend.Title.text = "Amendment 10";
					Amend.AmendText.text = "The powers not delegated to the United States by the Constitution, nor prohibited by it to the states, are reserved to the states respectively, or to the people.";
					Amend.Explanation.text = "Using their rights, in an effort to support you, the states have set up safehouses where you can rest and regain health. Unfortunately, they can't stop the guards from chasing you in, though...\n\nStand in a safe-area to slowly regain health";
					break;
				case 5:
					Amend.Title.text = "Amendment 9";
					Amend.AmendText.text = "The enumeration in the Constitution, of certain rights, shall not be construed to deny or disparage others retained by the people.";
					Amend.Explanation.text = "Your personal powers allow you to summon a magical vortex that magically and conviniently deals spash damage to all enemies around you\n\nPress v to activate special splash move; takes time to recharge";
					break;
				case 6:
					Amend.Title.text = "Amendment 3";
					Amend.AmendText.text = "No soldier shall, in time of peace be quartered in any house, without the consent of the owner, nor in time of war, but in a manner to be prescribed by law.";
					Amend.Explanation.text = "Enemies are prohibited from being quartered in your private dwellings, which means they can no longer enter safehouses\n\nEnemies are prohibited from entering safehouses";
					break;
				case 7:
					Amend.Title.text = "Amendment 6";
					Amend.AmendText.text = "No soldier shall, in time of peace be quartered in any house, without the consent of the owner, nor in time of war, but in a manner to be prescribed by law.";
					Amend.Explanation.text = "Enemies are prohibited from being quartered in your private dwellings, which means they can no longer enter safehouses\n\nEnemies are prohibited from entering safehouses";
					break;
				case 8:
					Amend.Title.text = "Amendment 7";
					Amend.AmendText.text = "No soldier shall, in time of peace be quartered in any house, without the consent of the owner, nor in time of war, but in a manner to be prescribed by law.";
					Amend.Explanation.text = "Enemies are prohibited from being quartered in your private dwellings, which means they can no longer enter safehouses\n\nEnemies are prohibited from entering safehouses";
					break;
				case 9:
					Amend.Title.text = "Amendment 8";
					Amend.AmendText.text = "No soldier shall, in time of peace be quartered in any house, without the consent of the owner, nor in time of war, but in a manner to be prescribed by law.";
					Amend.Explanation.text = "Enemies are prohibited from being quartered in your private dwellings, which means they can no longer enter safehouses\n\nEnemies are prohibited from entering safehouses";
					break;
			}
			
		}
		public function CloseAmend(e:Event):void{
			AddEvents();
			stage.removeChild(Amend);
			stage.addEventListener(Event.ENTER_FRAME, FrameCode);
			Amend.Close.removeEventListener(MouseEvent.CLICK, CloseAmend);
		}
		
		
		public function PlaySounds(e:int):void{
			/*
			0 - Main Menu
			1 - Credits
			*/
			var MMSong:Sound;
			if(e == 0){
				MMSong = new MainMenuSong();
			} else if(e == 1){
			//	MMSong = new CreditsSong();
			}
			MMSong.play();
		}
		public function KillSounds():void{
			SoundMixer.stopAll();
		}
		
	}
	
}
