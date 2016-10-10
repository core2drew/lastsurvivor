package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	
	public class LoadingScreen extends MovieClip {
		
		private var main:Main;
		private var db:Database;
		private var modal:Modal;
		private var checkUser:Boolean;
		private var lastText:MovieClip;
		private var survivorText:MovieClip;
		private var moon:MovieClip;
		private var zombieHand:MovieClip;
		private var ground:MovieClip;
		private var cloud1:MovieClip;
		private var cloud2:MovieClip;
		private var touchScreenStart:MovieClip;
		private var loadingScreenTimer:Timer;
		
		public function LoadingScreen(main:Main) {
			
			this.main = main;
			
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			hide();
			
			db = main.db;
			modal = main.modal;
			
			checkUser = db.checkUserUser();
			x = 1065;
			y = 125;
						
			loadingScreenTimer = new Timer(3000, 1);
			loadingScreenTimer.addEventListener(TimerEvent.TIMER, showMainMenu);
		}
		
		public function showStartingScreen ():void {
			//SoundController.playBGSound(db.getBGSound(),"Main");//Play Sound for Map
			show();
			
			lastText = lastText_mc;
			survivorText = survivorText_mc;
			moon = moon_mc;
			zombieHand = zombiehand_mc;
			ground = ground_mc;
			cloud1 = cloud1_mc;
			cloud2 = cloud2_mc;
			touchScreenStart = touchscreenstart_mc;
			
			moon.y = -170;
			ground.y = 472;
			zombieHand.y = 1450;
			cloud1.alpha = 0;
			cloud2.alpha = 0;
			
			lastText.alpha = 0;
			survivorText.alpha = 0;
			touchScreenStart.alpha = 0;
			
			
			TweenMax.to(moon, 2, { 
				delay:1.5, 
				y: -340,
				onComplete:function () {
					TweenMax.to(cloud1, 15, {x:1070,yoyo:true, repeat: -1 } );
					TweenMax.to(cloud1, 8, { bezierThrough:[ { alpha: 1 }, { alpha:0 } ], repeat: -1 } );
					
					TweenMax.to(cloud2, 20, {x:-1197.2,yoyo:true, repeat: -1 } );
					TweenMax.to(cloud2, 10, {bezierThrough:[ { alpha: 1 }, { alpha:0 } ], repeat: -1 } );
				}
			});
			
			TweenMax.to(ground, 4, {
				delay:1.5, 
				y:30, 
				ease:Quad.easeOut,
				onComplete:function () {
					TweenMax.to(zombieHand, 2, { 
						y:440,
						ease:Circ.easeIn,
						onComplete:function () {
							TweenMax.to(lastText, 0.8, { delay:1, alpha:1 } );
							TweenMax.to(survivorText, 0.8, { 
								delay:2, 
								alpha:1, 
								onComplete:function() {
									if (!checkUser)
									{
										TweenMax.to(touchScreenStart, 1, { alpha:1, yoyo:true, repeat: -1 } );
										addEventListener(MouseEvent.CLICK, ScreenTouched);
									}
								}
							});
						}
					});
				}
			});
			
			if (checkUser)
			{
				TweenMax.to(touchScreenStart, 1, { alpha:1, yoyo:true, repeat: -1 } );
				addEventListener(MouseEvent.CLICK, ScreenTouched);
			}
		}
		
		public function ScreenTouched (e:MouseEvent):void {
			checkUser = db.checkUserUser();
			if (!checkUser) {
				modal.showNewUser();
				return;
			}
			
			removeEventListener(MouseEvent.CLICK, arguments.callee);
			TweenMax.killAll(false, true, false);
			
			hide();
			main.MainMenuInit();
		}
		
		public function showLoadingScreen():void {
			show();
			ground.y = 30;
			moon.y = -340;
			zombieHand.y = 440;
			lastText.alpha = 1;
			survivorText.alpha = 1;
			
			touchscreenstart_mc.alpha = 0;
			loadingScreenTimer.start();
		}
		
		public function showMainMenu(e:TimerEvent):void {
			hide();
			main.MainMenuInit();
		}
		
		public function show() {
			this.visible = true;
		}
		
		public function hide() {
			this.visible = false;
		}
	}
	
}
