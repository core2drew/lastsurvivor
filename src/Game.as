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
		
		public var main:Main;
		public var mainStage:MovieClip;
		public var scrollBG:ScrollingBackground;
		public var joystick:JoyStick;
		public var survivor:Survivor;
		public var survivorStat:SurvivorStat;
		public var gameControls:GameControls;
		public var stageWidth:int;
		public var scrollBGWidth:Number;
		public var zombieSpawnTimer:Timer;
		public var survivorDied:Boolean;
		
		/*Controller Variables*/
		public var speedConstant:Number;
		public var maxSpeedConstant:Number;
		public var leftMoveLimit:Number;
		public var rightMoveLimit:Number;
		public var movingLeft:Boolean;
		public var movingRight:Boolean;
		public var jumping:Boolean;
		public var falling:Boolean;
		public var playerDirection:String;
		public var xSpeed:int;
		public var scrollX:int;
		public var gravityConstant:int;
		public var jumpConstant:int;
		public var maxJumpHeight:int;
		public var ground:int;

		public function Game (main:Main) {
			this.main = main;
			InGame = false;
			IsPaused = false;
		}
		
		public function GameInit ():void {
			InGame = true;
			survivorDied = false;
			
			mainStage = main.mainStage;
			scrollBG = main.scrollBG;
			survivor = main.survivor;
			survivorStat = main.survivorStat;
			joystick = main.joystick;
			gameControls = main.gameControls;
			
			//Native Device Back Button Event
			//NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, handleGameBackButton, false, 0, true);
			
			//Inactive App in user Device Event
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleGameDeactivated, false, 0, true);
			
			main.hideMenuInit();
			showGameUI();
			
			stageWidth = main._stage.stageWidth;
			scrollBGWidth = scrollBG.width;
			
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			
			/*Controller Init*/
			speedConstant = 15; //Character Speed (illusion only)
			maxSpeedConstant = speedConstant;
			leftMoveLimit = 0;
			rightMoveLimit = -2745;
			movingLeft = false;
			movingRight = false;
			jumping = false;
			falling = false;
			playerDirection = "";
			xSpeed = 0;
			scrollX = 0;
			gravityConstant = 20;
			jumpConstant = -27;
			maxJumpHeight = 380;
			ground = scrollBG.y; //This is the ground of the scrollBG
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function Fall():void {
			if (falling) {
				survivor.Fall();
			}
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
			
			zombie = new Zombie(main, xLocation, 0, direction , survivor, stageWidth);//Creating new Zombie Obj
			scrollBG.addChild(zombie);
			zombieList.push(zombie);
		}
		
		private function loop (e:Event):void {
			if (!survivorDied) {
				//Spawing Zombie Condition
				if (zombieList.length <= 2) {
					zombieSpawnTimer.start();
				}
				
				//JoyStick Pad Condition
				if (joystick.direction === "left") {
					movingLeft = true;
					survivor.TurnLeft();
					if (scrollX >= leftMoveLimit) {
						movingLeft = false;
						survivor.Idle();
					}
					else {
						xSpeed -= speedConstant;
						if (!jumping && !falling) {
							survivor.Walk();
						}
						moveScrollBGX()
					}
				}
				else if (joystick.direction === "right") {
					movingRight = true;
					survivor.TurnRight();
					if (scrollX <= rightMoveLimit) {
						movingRight = false;
						survivor.Idle();
					}
					else {
						xSpeed += speedConstant;
						if (!jumping && !falling) {
							survivor.Walk();
						}
						moveScrollBGX()
					}
				}
				else if (joystick.direction === "idle") {
					//To animate jump when idle status
					if (!jumping && !falling) {
						survivor.Idle();
					}
				}
				
				//jumping Condition
				if (jumping) {
					if (survivor.y > maxJumpHeight) {
						survivor.y += jumpConstant;
						maxSpeedConstant = 17;
					}
					else {
						falling = true;
						jumping = false;
						Fall();
					}
				}
				//falling Condition
				if (falling) {
					if (survivor.y < ground - 30) {
						survivor.y += gravityConstant;
					}
					else {
						falling = false;
						jumping = false;
						survivor.y = ground
						maxSpeedConstant = 12;
					}
				}
			}
			else {
				zombieSpawnTimer.stop();
			}
		}
		
		public function moveScrollBGX():void {
			//Maxspeed
			if (xSpeed < (maxSpeedConstant * -1)) {
				xSpeed = (maxSpeedConstant * -1);
			}
			else if (xSpeed > maxSpeedConstant) {
				xSpeed = maxSpeedConstant;
			}
			//Move ScrollBG
			scrollX -= xSpeed;
			scrollBG.x = scrollX;
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
		
		public function gameOver():void {
			hideGameUI();
			InGame = false;
			IsPaused = false;
			main.loadingScreen.showLoadingScreen();
		}
		
		public function showGameUI():void {
			scrollBG.show();
			survivor.show();
			survivorStat.displayStat();
			joystick.show();
			gameControls.show();	
		}
		
		public function hideGameUI():void {
			scrollBG.hide();
			survivor.hide();
			survivor.survivorStat.hide();
			joystick.hide();
			gameControls.hide();	
		}
	}
}