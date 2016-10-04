package
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.TouchEvent;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import Main;
	import JoyStick;
	import Survivor;
	import Zombie;
	import Bullet;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Game extends MovieClip {
		public static var zombieList:Array = new Array();
		public static var InGame:Boolean;
		public static var IsPaused:Boolean;
		public var mainStage:MovieClip;
		public var joystick:JoyStick;
		public var survivor:Survivor;
		public var bullet:Bullet;
		public var stageWidth:int;
		public var scrollBGWidth:Number;
		public var zombieSpawnTimer:Timer;
		
		/*Controller Variables*/
		private var speedConstant:Number;
		private var maxSpeedConstant:Number;
		private var LeftMoveLimit:Number;
		private var RightMoveLimit:Number;
		private var MovingLeft:Boolean;
		private var MovingRight:Boolean;
		private var Jumping:Boolean;
		private var Falling:Boolean;
		private var scrollingBG:MovieClip;
		private var playerDirection:String;
		private var xSpeed:int;
		private var scrollX:int;
		private var gravityConstant:int;
		private var jumpConstant:int;
		private var maxJumpHeight:int;
		private var ground:int;
		private var reloadDelay:Timer;

		public function Game () {
			InGame = false;
			IsPaused = false;
			GameInit();
		}
		
		//InGame Init
		//Call this when click start
		public function GameInit ():void {
			//Native Device Back Button Event
			//NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, handleGameBackButton, false, 0, true);
			
			//Inactive App in user Device Event
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleGameDeactivated, false, 0, true);
			
			mainStage = Main.mainStage;
			mainStage.gotoAndStop(3);
			InGame = true;
			stageWidth = Main.STAGE.stageWidth;
			scrollBGWidth = mainStage.scrollingBG_mc.width;
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			joystick = new JoyStick();
			survivor = new Survivor();
			spawnSurvivor();//Add Survivor to Stage;
			mainStage.addChild(joystick);//Adding Joystick to MainStage
			mainStage.jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);//Add Jumping Event
			mainStage.fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, fireBullet);//Firing Event
			
			/*Controller Init*/
			speedConstant = 12; //Character Speed (illusion only)
			maxSpeedConstant = speedConstant;
			LeftMoveLimit = 0;
			RightMoveLimit = -2745;
			MovingLeft = false;
			MovingRight = false;
			Jumping = false;
			Falling = false;
			scrollingBG = mainStage.scrollingBG_mc;
			playerDirection = "";
			xSpeed = 0;
			scrollX = 0;
			gravityConstant = 15;
			jumpConstant = -25;
			maxJumpHeight = 380;
			ground = mainStage.scrollingBG_mc.y; //This is the ground of the scrollBG
			reloadDelay = new Timer(800, 1);//Delay must be get from the database (gun delay column)
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function fireBullet (e:TouchEvent) {
			if (survivor.scaleX < 0)
			{
				playerDirection = 'left';
			}
			else if (survivor.scaleX > 0)
			{
				playerDirection = 'right';
			}
			
			bullet = new Bullet(scrollX, ground, survivor, playerDirection);
			scrollingBG.addChild(bullet);
		}
		
		private function Jump (e:TouchEvent) {
			if (survivor.y >= ground) {
				Jumping = true;
				survivor.Jump();
			}
		}
		
		private function Fall():void {
			if (Falling) {
				survivor.Fall();
			}
		}
		
		public function spawnSurvivor ():void {
			mainStage.addChild(survivor);
		}
		
		public function spawnZombie (e:TimerEvent):void {
			var zombie:Zombie
			var xLocation:int;
			var direction:String;
			var zombieWidth:Number = 212.85;
			var spawnPointX = (Math.floor(Math.random() * (1 - 0 + 1)) + 0);//If 0 Spawn Zombie Left, Else Right
			
			if (spawnPointX) {
				xLocation = -1 * (zombieWidth / 2);
				direction = "right";
			}
			else {
				xLocation = scrollBGWidth + (zombieWidth / 2);
				direction = "left";
			}
			
			zombie = new Zombie(xLocation, 0, direction , survivor, stageWidth);//Creating new Zombie Obj
			mainStage.scrollingBG_mc.addChild(zombie);
			zombieList.push(zombie);
		}
		
		private function loop (e:Event):void {
			//Spawing Zombie Condition
			if (zombieList.length <= 2) {
				zombieSpawnTimer.start();
			}
			
			//JoyStick Pad Condition
			if (JoyStick.direction === "left") {
				MovingLeft = true;
				survivor.TurnLeft();
				if (scrollX >= LeftMoveLimit) {
					MovingLeft = false;
					survivor.Idle();
				}
				else {
					xSpeed -= speedConstant;
					if (!Jumping && !Falling) {
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}
			else if (JoyStick.direction === "right") {
				MovingRight = true;
				survivor.TurnRight();
				if (scrollX <= RightMoveLimit) {
					MovingRight = false;
					survivor.Idle();
				}
				else {
					xSpeed += speedConstant;
					if (!Jumping && !Falling) {
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}
			else if (JoyStick.direction === "idle") {
				//To animate jump when idle status
				if (!Jumping && !Falling) {
					survivor.Idle();
				}
			}
			
			//Jumping Condition
			if (Jumping) {
				if (survivor.y > maxJumpHeight) {
					survivor.y += jumpConstant;
					maxSpeedConstant = 17;
				}
				else {
					Falling = true;
					Jumping = false;
					Fall();
				}
			}
			//Falling Condition
			if (Falling) {
				if (survivor.y < ground - 30) {
					survivor.y += gravityConstant;
				}
				else {
					Falling = false;
					Jumping = false;
					survivor.y = ground
					maxSpeedConstant = 12;
				}
			}
		}
		
		public function moveScrollBGX() {
			//Maxspeed
			if (xSpeed < (maxSpeedConstant * -1)) {
				xSpeed = (maxSpeedConstant * -1);
			}
			else if (xSpeed > maxSpeedConstant) {
				xSpeed = maxSpeedConstant;
			}
			//Move ScrollBG
			scrollX -= xSpeed;
			scrollingBG.x = scrollX;
		}
		
		public function handleGameBackButton (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.BACK) {
				if (!IsPaused) {
					pauseGame();
				}else {
					IsPaused = false;
				}
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		public function handleGameDeactivated (e:Event):void {
			if (!IsPaused) {
				pauseGame();
			}
		}
		
		public function pauseGame ():void {
			//Show Pause Modal
			mainStage.setChildIndex(mainStage.modal, mainStage.numChildren - 1);
			mainStage.modal.showPause();
			//Here Stop All Survivor Bullets, Zombie Moving, etc.
			removeEventListener(Event.ENTER_FRAME, loop);
			//Checker if GamePause is False;
			addEventListener(Event.ENTER_FRAME, pauseCheckerLoop);
		}
		
		public function resumeGame ():void {
			//Resume Game
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function pauseCheckerLoop(e:Event):void {
			if (!IsPaused) {
				resumeGame();
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
			}
		}
	}
}