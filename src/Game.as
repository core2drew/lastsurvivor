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
	
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Game extends MovieClip {
		private var db:Database;
		public var zombieArr:Array;
		public var bulletArr:Array;
		public var isInGame:Boolean;
		public var isGamePause:Boolean;
		public var main:Main;
		public var modal:Modal;
		public var mainStage:MovieClip;
		public var scrollBG:ScrollingBackground;
		public var joystick:JoyStick;
		public var survivor:Survivor;
		public var countDown:CountDown;
		public var survivorStat:SurvivorStat;
		public var gameControls:GameControls;
		public var stageWidth:int;
		public var scrollBGWidth:Number;
		public var zombieSpawnTimer:Timer;
		public var survivorDied:Boolean;
		public var levelCompleted:Boolean;
		public var currentLevel:int;
		
		private var timeRemaining:Object;
		private var zombieLevelObject:Object;
		private var zombieCount:int;
		private var zombieShowCount:int;
		private var zombieVariations:Array;
		private var zombieBoss:Boolean;
		
		public function Game (main:Main) {
			this.main = main;
			db = main.db;
			modal = main.modal;
			countDown = main.countDown;
			zombieArr = new Array();
			bulletArr = new Array();
		}
		
		public function GameInit ():void {
			//Native Device Back Button Event
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, handleBackButton, false, 0, true);
			
			//Inactive App in user Device Event
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivated, false, 0, true);
			
			mainStage = main.mainStage;
			scrollBG = main.scrollBG;
			survivor = main.survivor;
			survivorStat = main.survivorStat;
			joystick = main.joystick;
			gameControls = main.gameControls;
			
			stageWidth = main._stage.stageWidth;
			scrollBGWidth = scrollBG.width;
			
			countdownInit();
			zombieInit();
			startGame();
		}
		
		public function loop (e:Event):void {
			if (!survivorDied && !levelCompleted) {
				
				//Spawing Zombie Condition
				if (zombieCount > 0) {
					if (zombieArr.length < zombieShowCount) {
						zombieSpawnTimer.start();
					}
				}
				else{
					if (zombieArr.length == 0) {
						levelComplete();
					}
				}
				
				survivor.moves();
				joystick.moveJoystick();
				gameControls.actions();
				
				for (var i = 0; i < zombieArr.length; i++) {
					zombieArr[i].locateSurvivor();
				}
			}
			else {
				//for (var x = 0; x < zombieArr.length; x++) {
					//zombieArr[x].randomWalk();
				//}
				zombieSpawnTimer.stop();
			}
		}
		
		private function countdownInit() {
			countDown.TARGET_SECONDS = db.getTimelimit(currentLevel);
			timeRemaining = countDown.timeRemaining;
			countDown.START();
			countDown.countDownText.text = timeRemaining.minutes + ":" + timeRemaining.seconds;
			countDown.addEventListener(Event.CHANGE, onUpdateCountdown);
			countDown.addEventListener(Event.COMPLETE, onCompleteCountdown);
		}
		
		private function onUpdateCountdown(evt:Event):void {
           timeRemaining = countDown.timeRemaining;
           //countDown.countDownText.text = timeRemaining.minutes + ":" + timeRemaining.seconds;
        }
		
        private function onCompleteCountdown(evt:Event):void{
            trace ("Times up!");
        }
		
		private function zombieInit():void {
			zombieLevelObject = db.getZombies(currentLevel);
			zombieCount = int(zombieLevelObject.zombie_count);
			zombieShowCount = int(zombieLevelObject.zombie_show_count);
			zombieVariations = String(zombieLevelObject.zombie_variation).split(";");
			zombieBoss = Boolean(zombieLevelObject.zombie_boss);
		}
		
		public function spawnZombie (e:TimerEvent):void {
			var zombie:Zombie
			var xLocation:int;
			var initialDirection:String;
			var zombieWidth:Number = 212.85;
			var spawnPointX = (Math.floor(Math.random() * (1 - 0 + 1)) + 0);//If 0 Spawn Zombie Left, Else Right
			var zombieVariation:Object;
			
			if (spawnPointX) {
				xLocation = -1 * (zombieWidth / 2);
				initialDirection = "right";
			}
			else {
				xLocation = scrollBGWidth + (zombieWidth / 2);
				initialDirection = "left";
			}
			
			zombieVariation = JSON.parse(zombieVariations[ Helper.randomRange(0, (zombieVariations.length - 1) ) ]);
			zombie = new Zombie(main, xLocation, 950, initialDirection, zombieVariation);//Creating new Zombie Obj
			scrollBG.addChild(zombie);
			zombieArr.push(zombie);
			zombieCount--;
		}
		
		public function handleBackButton (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.BACK) {
				if (!isGamePause) {
					pause();
					return;
				}
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		public function handleDeactivated (e:Event):void {
			if (!isGamePause) {
				pause();
				return;
			}
		}
				
		public function showGameUI():void {
			scrollBG.show();
			joystick.show();
			gameControls.show();	
			survivorStat.show();
		}
		
		public function hideGameUI():void {
			scrollBG.hide();
			survivorStat.hide();
			joystick.hide();
			gameControls.hide();	
		}
		
		public function resume ():void {
			isGamePause = false;
			resumeAllBullets();
			gameControls.resume();
			addEventListener(Event.ENTER_FRAME, loop);//Resume Game
		}
		
		public function pause ():void {
			if (!survivorDied && !levelCompleted) {
				isGamePause = true;
				main.modal.showPause();
				pauseAllZombies();
				pauseAllBullets();
				gameControls.pause();
				removeEnterFrame();
			}
		}
		
		public function startGame():void {
			main.hideMainMenu();
			showGameUI();
			
			//countDown.show();
			survivor.show();
			scrollBG.reset();
			
			isInGame = true;
			survivorDied = false;
			isGamePause = false;
			levelCompleted = false;
			
			pauseAllZombies();
			removeAllZombies();
			removeAllBullets();
			
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function restart():void {
			removeEnterFrame();
			
			gameControls.reset();
			survivor.initialAppearance();
			survivorStat.resetStat();
			scrollBG.reset();
			
			startGame();
		}
		
		public function gameOver():void {
			
			survivorDied = true;
			countDown.hide();
			survivorStat.hide();
			joystick.hide();
			gameControls.hide();
			survivor.hide();
			removeAllBullets();
			
			modal.showGameOver();
		}
		
		public function levelComplete():void {
			
			levelCompleted = true;
			countDown.hide();
			survivorStat.hide();
			joystick.hide();
			gameControls.hide();
			survivor.hide();
			removeAllBullets();
			
			modal.showLevelComplete(1,2);//temporary
		}
		
		public function pauseAllZombies():void {
			for (var i = 0; i < zombieArr.length; i++) {
				zombieArr[i].pause();
			}
		}
		
		public function removeAllZombies():void {
			if (zombieArr.length > 0) {
				for (var i = 0; i < zombieArr.length; i++) {
					zombieArr[i].removeSelf();
				}
				zombieArr.length = 0;
			}
		}
		
		public function pauseAllBullets():void {
			for (var i = 0; i < bulletArr.length; i++) {
				bulletArr[i].pause();
			}
		}
		
		public function resumeAllBullets():void {
			for (var i = 0; i < bulletArr.length; i++) {
				bulletArr[i].resume();
			}
		}
		
		public function removeAllBullets():void {
			for (var i = 0; i < bulletArr.length; i++) {
				bulletArr[i].resume();
			}
		}
		
		public function removeEnterFrame():void {
			removeEventListener(Event.ENTER_FRAME, loop);
		}
	}
}