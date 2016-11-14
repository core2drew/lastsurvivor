package
{
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	import flash.text.TextInteractionMode;
	import flash.ui.Keyboard;
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.media.SoundMixer;
	import Database;
	import Menu;
	import Map;
	import LoadingScreen;
	import ScrollingBackground;
	import Game;
	import Survivor;
	import JoyStick;
	import Settings;
	import Modal;
	import Helper;
	import User;
	import Stars;
	import Coins;
	
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Main extends MovieClip
	{
		public var _stage:Stage;
		public var stageWidth:Number;
		public var stageHeight:Number;
		public var mainStage:MovieClip;
		
		public var db:Database;
		public var menu:Menu;
		public var map:Map;
		public var modal:Modal;
		public var loadingScreen:LoadingScreen;
		public var scrollBG:ScrollingBackground;
		public var survivor:Survivor;
		public var survivorStat:SurvivorStat;
		public var countDown:CountDown;
		public var joystick:JoyStick
		public var gameControls:GameControls;
		public var game:Game;
		public var user:User;
		public var stars:Stars;
		public var coins:Coins;
		public var gameAlreadyStarted:Boolean;
		
		public function Main () {
			stop();
			gameAlreadyStarted = false;
			
			_stage = stage;
			mainStage = this;
			
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init (e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stageWidth = _stage.stageWidth;
			stageHeight = _stage.stageHeight;
			
			db = new Database();
			scrollBG = new ScrollingBackground(this);
			modal = new Modal(this);
			countDown = new CountDown();
			survivorStat = new SurvivorStat(this);
			survivor = new Survivor(this);
			joystick = new JoyStick(this);
			gameControls = new GameControls(this);
			game = new Game(this);
			loadingScreen = new LoadingScreen(this);
			menu = new Menu(this);
			map = new Map(this);
			user = new User(this);
			stars = new Stars(this);
			coins = new Coins(this);
			
			mainStage.addChild(scrollBG);
			mainStage.addChild(countDown);
			mainStage.addChild(loadingScreen);
			mainStage.addChild(map);
			mainStage.addChild(menu);
			mainStage.addChild(user);
			mainStage.addChild(stars);
			mainStage.addChild(coins);
			mainStage.addChild(survivorStat);
			mainStage.addChild(survivor);
			mainStage.addChild(joystick);
			mainStage.addChild(gameControls);
			mainStage.addChild(modal);
			
			_stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleBackButton, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleAppDeactivated, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleAppActivated, false, 0, true);
			
			loadingScreen.showStartingScreen();//Show the starting animating screen
		}
		
		//Device Native BackButton 
		public function handleBackButton (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.BACK) {
				if (!modal.showing) {
					if (!game.isInGame) {
						modal.showModal();
						modal.showExit();
					}
				} 
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		public function handleAppActivated (e:Event):void {
			//SoundController.playBGSound(db.getBGSound(), "Main");//Turn On Sound
		}
		
		public function handleAppDeactivated (e:Event):void {
			//SoundController.stopAllSounds();//Pause game and Turn off sound
		}
		
		public function showMainMenu ():void {
			menu.show();
			map.show();
			user.displayUser();
			stars.displayStars();
			coins.displayCoin();
		}
		
		public function hideMainMenu():void {
			menu.hide();
			map.hide();
			user.hide();
			stars.hide();
			coins.hide();
		}
	}
}