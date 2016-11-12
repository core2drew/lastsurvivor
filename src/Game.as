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
		public var survivorStat:SurvivorStat;
		public var gameControls:GameControls;
		public var stageWidth:int;
		public var scrollBGWidth:Number;
		public var zombieSpawnTimer:Timer;
		public var survivorDied:Boolean;
		public var levelCompleted:Boolean;
		private var zombieVariations:Array;
		
		public function Game (main:Main) {
			this.main = main;
			db = main.db;
			modal = main.modal;
			zombieArr = new Array();
			bulletArr = new Array();
		}
		
		public function GameInit (currentLevel:int):void {
			//Get ZombiesVariation from the Database
			var zombieInfo:Object = JSON.parse(db.getZombies(currentLevel).zombie_variation);
			trace(zombieInfo.variation);
			
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
			
			startGame();
		}
		
		public function loop (e:Event):void {
			if (!survivorDied) {
				//Spawing Zombie Condition
				if (zombieArr.length < 1) {
					zombieSpawnTimer.start();
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
		
		public function spawnZombie (e:TimerEvent):void {
			var zombie:Zombie
			var xLocation:int;
			var initialDirection:String;
			var zombieWidth:Number = 212.85;
			var spawnPointX = (Math.floor(Math.random() * (1 - 0 + 1)) + 0);//If 0 Spawn Zombie Left, Else Right
			var variation:int;
			var skill:int;
			
			if (spawnPointX) {
				xLocation = -1 * (zombieWidth / 2);
				initialDirection = "right";
			}
			else {
				xLocation = scrollBGWidth + (zombieWidth / 2);
				initialDirection = "left";
			}
			
			zombie = new Zombie(main, xLocation, 950, initialDirection, variation);//Creating new Zombie Obj
			scrollBG.addChild(zombie);
			zombieArr.push(zombie);
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
			if (!survivorDied) {
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
			
			survivor.show();
			scrollBG.reset();
			
			isInGame = true;
			survivorDied = false;
			isGamePause = false;
			
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
			survivorStat.hide();
			joystick.hide();
			gameControls.hide();
			survivor.hide();
			removeAllBullets();
			
			modal.showGameOver();
		}
		
		public function levelComplete():void {
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