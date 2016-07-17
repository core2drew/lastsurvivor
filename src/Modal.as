package 
{
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.desktop.NativeApplication;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.filters.*; 
	import Database;
	import SoundController;
	import Game;
	
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Modal extends MovieClip {
		public var _Game:Game;
		public var modal:MovieClip;
		public var showing:Boolean;
		public var DB:Database;
		private var levelsCon:MovieClip = new MovieClip();
		
		public function Modal() {
			modal = this;
			DB = new Database();
			hideAllModal();
		}
		
		public function showModal ():void {
			modal.showing = true;
			modal.visible = true;
		}
		
		public function showShop ():void {
			shop.visible = true;
			
			prevBtn.visible = false;
			nextBtn.visible = false;
			buyBtn.visible = false;
			viewBtn.visible = false;
			
			//TweenMax.fromTo(shop, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			//Hide Shop Modal
			shop.Xbtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
			});
		}
		
		public function showExit ():void {
			exit.visible = true;
			//TweenMax.fromTo(exit, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			//Exit the Game
			exit.yesBtn.addEventListener(MouseEvent.CLICK, function () {
				NativeApplication.nativeApplication.exit();
			});
			
			//Hide Exit Modal
			exit.noBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
			});
		}
		
		
		public function showLevel (title:String, selectedStage:int):void {
			level.visible = true;
			levelsCon =  level.levelsCon;
			//Add Events to Level Buttons
			levelBtnEvent(selectedStage);
			//Show Parent Modal
			modal.showModal();
			//Change stage title
			level.title_txt.text = title;
			//level.startBtn.visible = false;
			
			//TweenMax.fromTo(level, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			
			//Hide Level Modal
			level.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
					resetLevelModal();
					hideAllModal();
			});
		}
		
		private function resetLevelModal ():void {
			var levelsCon:MovieClip = new MovieClip();
			var level_btn:MovieClip = new MovieClip();
			levelsCon =  level.levelsCon;
			
			for (var i = 0; i < levelsCon.numChildren; i++) {
				//Remove All Filters
				level_btn = levelsCon.getChildAt(i) as MovieClip;
				level_btn.filters = [];
				
				//and removeEventListener
				level_btn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				level.startBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}
		}
		
		private function levelBtnEvent (selectedStage:int):void {
			var myGlow:GlowFilter = new GlowFilter(); 
			var stageLeveldata:Array = DB.getLevelStars(selectedStage)
			
			//Yellow Glow
			myGlow.inner = false; 
			myGlow.color = 0xFFDF1E; 
			myGlow.blurX = 15; 
			myGlow.blurY = 15; 
			myGlow.alpha = 0.5;
			
			//Loop for button level
			for (var i = 0; i < levelsCon.numChildren; i++) {
				var level_btn:MovieClip = levelsCon.getChildAt(i) as MovieClip;
				var firstLevel:MovieClip = levelsCon.getChildAt(0) as MovieClip;
				var star:MovieClip = new MovieClip();
				
				//Change Button Level Number
				level_btn.level_txt.text = i + 1;
				level_btn.level_txt.visible = false;
				
				//First Button Level
				firstLevel.closed.visible = false;
				firstLevel.level_txt.visible = true;
				
				//Stop Buttons Stars
				for (var x = 0; x < level_btn.starsCon.numChildren; x++) {
					star = level_btn.starsCon.getChildAt(x) as MovieClip;
					star.gotoAndStop(1);
				}
				
				//Show stars on buttons levels
				if (stageLeveldata.length > i) {
					for (var j = 0; j < stageLeveldata[i].stars; j++) {
						star = level_btn.starsCon.getChildAt(j) as MovieClip;
						star.gotoAndStop(2);
					}
				}
					
				//If the previous button level has stars unlock the next button level 
				for (var z = 0; z < stageLeveldata.length; z++) {
					var nextLevel_btn:MovieClip = new MovieClip();
					nextLevel_btn = levelsCon.getChildAt(z + 1) as MovieClip;
					nextLevel_btn.closed.visible = false;
					nextLevel_btn.level_txt.visible = true;	
				}
				
				//Add Event only when stage is unlocked
				if (level_btn.level_txt.visible) {
					level_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
						var curTarget:MovieClip = e.currentTarget as MovieClip;
						resetLevelModal();
						//level.startBtn.visible = true;
						curTarget.filters = [myGlow];
						//Start Game
						level.startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { 
							resetLevelModal();
							hideAllModal();
							_Game = new Game();
							_Game.GameInit();
						});
					});
				}
			}
		}
		
		public function showLockMessage (title:String):void {
			lockmessage.visible = true;
			modal.showModal();
			//Change stage title
			lockmessage.stage_txt.text = title;
			
			//TweenMax.fromTo(lockmessage, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			//Hide unlock Modal
			lockmessage.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
			});
		}
		
		public function showSettings (DB:Database,_currentView:String):void {
			var bgSound:int = DB.getBGSound();
			var SFX:int = DB.getSFX();
			var currentView:String = _currentView;
			
			settings.visible = true;
			//TweenMax.fromTo(settings, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			if (!bgSound) {
				settings.bgmusic_cb.check.visible = false;
			}
			
			if (!SFX) {
				settings.sfx_cb.check.visible = false;
			}
			
			
			settings.bgmusic_cb.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) { 
				if (bgSound) {
					settings.bgmusic_cb.check.visible = false;
					DB.updateBGSound(0);
					SoundController.stopBGSounds();
				}
				else {
					settings.bgmusic_cb.check.visible = true;
					DB.updateBGSound(1);
					SoundController.playBGSound(DB.getBGSound(),currentView);
				}
				
				bgSound = DB.getBGSound()
			});
			
			settings.sfx_cb.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) { 
				if (SFX) {
					settings.sfx_cb.check.visible = false;
					DB.updateSFX(0);
				}
				else {
					settings.sfx_cb.check.visible = true;
					DB.updateSFX(1);
				}
				SFX = DB.getSFX();
			});
			
			//Hide unlock Modal
			settings.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
			});
		}
		
		public function hideAllModal ():void {
			showing = false;
			modal.visible = false;
			lockmessage.visible = false;
			level.visible = false;
			shop.visible = false;
			settings.visible = false;
			exit.visible = false;
		}
	}
}