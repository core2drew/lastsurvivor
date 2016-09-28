package
{
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.media.SoundMixer;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import Database;
	import Game;
	import SoundController;
	import Modal;
	import Helper;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Main extends MovieClip
	{
		public static var mainStage:MovieClip;
		public static var STAGE:Stage;
		public static var StageWidth:Number;
		
		public var DB:Database;
		public var soundCtrl:SoundController;

		//Menu Container
		public var menuCon:MovieClip;
		
		//User Container
		public var userCon:MovieClip;
	
		//Star Container
		public var starCon:MovieClip;
		
		//Coin Container
		public var coinCon:MovieClip;
		
		//Modals Object
		public var modal:Modal;
		
		//Map Stage Container
		public var map:MovieClip;
		
		//User Check if there is already a user
		private var checkUser;
		
		public function Main () {
			stop();
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init (e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleBackButton, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleAppDeactivated, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleAppActivated, false, 0, true);
			STAGE = stage;
			StageWidth = STAGE.stageWidth;
			mainStage = this;
			DB = new Database();
			soundCtrl = new SoundController();
			
			//User checker if there is a already a user
			checkUser = DB.checkUserUser();
			
			//Show the starting screen
			ShowStartingScreen();
		}
		
		//Device Native BackButton 
		public function handleBackButton (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.BACK) {
				if (!modal.showing) {
					if (!Game.InGame) {
						modal.showModal();
						modal.showExit();
					}
				} 
				e.preventDefault();
				e.stopImmediatePropagation();
			}
		}
		
		public function handleAppActivated (e:Event):void {
			//Turn On Sound
			//SoundController.playBGSound(DB.getBGSound(), "Main");
		}
		
		public function handleAppDeactivated (e:Event):void {
			//Pause game and Turn off sound
			//SoundController.stopAllSounds();
		}

		public function ShowStartingScreen ():void {
			var ss = startscreen_mc;//ss meaning start screen;
			//SoundController.playBGSound(DB.getBGSound(),"Main");//Play Sound for Map
			
			ss.y = 472;
			ss.moon_mc.y = -170;
			ss.zombiehand_mc.y = 1450;
			ss.cloud1_mc.alpha = 0;
			ss.cloud2_mc.alpha = 0;
			
			ss.last_mc.alpha = 0;
			ss.survivor_mc.alpha = 0;
			touchscreenstart_mc.alpha = 0;
			
			
			TweenMax.to(ss.moon_mc, 2, { 
				delay:1.5, 
				y: -340,
				onComplete:function () {
					TweenMax.to(ss.cloud1_mc, 15, {x:1070,yoyo:true, repeat: -1 } );
					TweenMax.to(ss.cloud1_mc, 8, { bezierThrough:[ { alpha: 1 }, { alpha:0 } ], repeat: -1 } );
					
					TweenMax.to(ss.cloud2_mc, 20, {x:-1197.2,yoyo:true, repeat: -1 } );
					TweenMax.to(ss.cloud2_mc, 10, {bezierThrough:[ { alpha: 1 }, { alpha:0 } ], repeat: -1 } );
				}
			});
			TweenMax.to(ss, 4, {
				delay:1.5, 
				y:141.7, 
				ease:Quad.easeOut,
				onComplete:function () {
					TweenMax.to(ss.zombiehand_mc, 2, { 
						y:439,
						ease:Circ.easeIn,
						onComplete:function () {
							TweenMax.to(ss.last_mc, 0.8, { delay:1, alpha:1 } );
							TweenMax.to(ss.survivor_mc, 0.8, { 
								delay:2, 
								alpha:1, 
								onComplete:function() {
									TweenMax.to(touchscreenstart_mc, 1, { alpha:1, yoyo:true, repeat: -1 } );
									startscreen_mc.addEventListener(MouseEvent.CLICK, ScreenTouched);
								}
							});
						}
					});
				}
			});
			
			if (checkUser)
			{
				TweenMax.to(touchscreenstart_mc, 1, { alpha:1, yoyo:true, repeat: -1 } );
				startscreen_mc.addEventListener(MouseEvent.CLICK, ScreenTouched);
			}
		}
		
		public function ScreenTouched (e:MouseEvent):void {
			checkUser = DB.checkUserUser();
			if (!checkUser) {
				modal.showNewUser();
				return;
			}
			
			removeEventListener(MouseEvent.CLICK, arguments.callee);
			TweenMax.killAll(false, true, false);
			gotoAndStop(2);
			MainMenuInit();
		}
		
		public function MainMenuInit ():void {
			menuCon = mainStage.menuCon;
			starCon = mainStage.starCon;
			coinCon = mainStage.coinCon;
			userCon = mainStage.userCon;
			map = mainStage.map;
			
			userCon.user_txt.text = DB.getSelectedUser();//Temporary param(It must be dynamic param);
			coinCon.currentCoins_txt.text = Helper.formatCost(DB.getCoins().toString(), 0, "", 0);//Get current coins of the current user
			starCon.maxStars_txt.text = DB.getMaxStar();//Get max stars of the game
			starCon.currentStars_txt.text = DB.getStars();//Get current stars of current user
				
			menuCon.addEventListener(MouseEvent.CLICK, menuItemClicked);
			MapInit();
		}
		
		//Update Coin Container
		public static function updateCoins (itemPrice:int):void {
			mainStage.coinCon.currentCoins_txt.text = Helper.formatCost(String(parseInt(mainStage.coinCon.currentCoins_txt.text.replace(",","")) - itemPrice), 0, "", 0);
		}
		
		private function MapInit ():void {
			var mapStages:MovieClip;
			//Add Click fn for stages
			map.addEventListener(MouseEvent.CLICK, mapStageClicked);
			
			//Lock All Stage
			for (var i = 1; i < map.numChildren; i++) {
				mapStages = map.getChildAt(i) as MovieClip;
				mapStages.stop();
			}
			
			//Unlock Stage 1
			map.stage1.gotoAndStop(2);
		}
		
		//Menu Buttons
		public function menuItemClicked (e:MouseEvent):void {
			switch (e.target.name) {
				case "shopBtn":
					modal.showShop();
				break;
				
				case "settingsBtn":
					modal.showSettings(DB,"Main");
				break;
				
				case "creditsBtn":
					
				break;
				
				case "exitBtn":
					modal.showExit();
				break;
				
				default:
			};
		}
		
		//Map Stages Buttons
		public function mapStageClicked (e:MouseEvent):void {
			if (e.target.currentFrame == 2) {
				switch (e.target.name) { 
					case "stage1":
						modal.showLevel("Safe House", 1);
					break;
					
					case "stage2":
						modal.showLevel("Windsor Highway", 2);
					break;
					
					case "stage3":
						modal.showLevel("Repocity", 3);
					break;
					
					case "stage4":
						modal.showLevel("Hollow Forest", 4);
					break;
					
					case "stage5":
						modal.showLevel("Surviror Camp", 5);
					break;
				}
			}
			
			else if (e.target.currentFrame == 1)
			{
				//lock messages
				switch (e.target.name) { 
					case "stage2":
						modal.showLockMessage("Safe House");
					break;
					
					case "stage3":
						modal.showLockMessage("Windsor Highway");
					break;
					
					case "stage4":
						modal.showLockMessage("Repocity");
					break;
					
					case "stage5":
						modal.showLockMessage("Hollow Forest");
					break;
				}
			}
		}
	}
}