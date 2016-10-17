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
		public var zombieArr:Array;
		public var bulletArr:Array;
		public var isInGame:Boolean;
		public var isGamePause:Boolean;
		
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
		
		public function Game (main:Main) {
			this.main = main;
			isInGame = false;
			isGamePause = false;
			zombieArr = new Array();
			bulletArr = new Array();
		}
		
		public function GameInit ():void {
			
			mainStage = main.mainStage;
			scrollBG = main.scrollBG;
			survivor = main.survivor;
			survivorStat = main.survivorStat;
			joystick = main.joystick;
			gameControls = main.gameControls;
			
			stageWidth = main._stage.stageWidth;
			scrollBGWidth = scrollBG.width;
			
			
			//Native Device Back Button Event
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_UP, handleBackButton, false, 0, true);
			
			//Inactive App in user Device Event
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivated, false, 0, true);
			
			startGame();
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
			zombieArr.push(zombie);
		}
		
		private function loop (e:Event):void {
			if (!survivorDied) {
				//Spawing Zombie Condition
				if (zombieArr.length < 2) {
					//zombieSpawnTimer.start();
				}
				
				survivor.loop();
				joystick.loop();
				gameControls.loop();
				
				for (var i = 0; i < zombieArr.length; i++) {
					zombieArr[i].loop();
				}
			}
			else {
				zombieSpawnTimer.stop();
			}
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
			scrollBG.reset();
			joystick.reset();
			
			scrollBG.show();
			survivor.show();
			survivorStat.displayStat();
			joystick.show();
			gameControls.show();	
		}
		
		public function hideGameUI():void {
			scrollBG.hide();
			survivor.hide();
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
			isGamePause = true;
			main.modal.showPause();
			pauseAllZombies();
			pauseAllBullets();
			gameControls.pause();
			removeEventListener(Event.ENTER_FRAME, loop);
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
		
		public function startGame():void {
			main.hideMainMenu();
			showGameUI();
			isInGame = true;
			survivorDied = false;
			
			removeAllZombies();
			
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function gameOver():void {
			removeEventListener(Event.ENTER_FRAME, loop);
			
			hideGameUI();
			isInGame = false;
			isGamePause = false;
			main.loadingScreen.showLoadingScreen();
			
		}
		
		public function restart():void {
			removeEventListener(Event.ENTER_FRAME, loop);
			
			isInGame = true;
			survivorDied = false;
			isGamePause = false;
			
			showGameUI();
			
			pauseAllZombies();
			removeAllZombies();
			
			removeAllBullets();
			
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			
			gameControls.reset();
			survivor.reset();
			survivorStat.displayStat();
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
	}
}