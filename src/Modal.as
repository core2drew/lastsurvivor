﻿package 
{
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.desktop.NativeApplication;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.filters.*; 
	import Database;
	import SoundController;
	import Game;
	import Main;
	
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
		public static var shopCurrentView:String;
		public static var shopPickCategory:String;
		private var shopUpgradeCategory:String;
		private var currentUpgradeLevel:int;
		private var shopItemCurrentPage:int;
		private var shopItemPageCount:int;
		private var shopItemDisplayLimit;
		private var shopItemsCount:int;
		
		
		public function Modal() {
			modal = this;
			DB = new Database();
			hideAllModal();
		}
		
		public function hideAllModal ():void {
			showing = false;
			modal.visible = false;
			pause.visible = false;
			lockmessage.visible = false;
			level.visible = false;
			shop.visible = false;
			settings.visible = false;
			exit.visible = false;
			
			shopPickCategory = "";
		}
		
		public function showModal ():void {
			modal.showing = true;
			modal.visible = true;
		}
		
		/***************************************** PAUSE MODAL *******************************************/
		public function showPause ():void {
			pause.visible = true;
			Game.IsPaused = true;
			pause.resumeBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				Game.IsPaused = false;
				pause.resumeBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				hideAllModal();
			});
			modal.showModal();
		}
		/***************************************** END OF PAUSE MODAL *******************************************/

		/********************************** SHOP MODAL *********************************************/
		public function showShop ():void {
			shop.visible = true;
			shopInit();
			
			hideAllShopItemInfo();
			hideShopMessage();
			
			//TweenMax.fromTo(shop, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
		
			shopItemCurrentPage = 1; //Current Page Viewing
			shop.characterBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				shopCurrentView = "Character";
				
				pageCount();//Get Total Page
				
				showShopItems();
			});
			
			shop.weaponryBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) { 
				shopCurrentView = "Weaponry";
				
				pageCount();//Get Total Page
				
				showShopItems();
			});
			
			//Close Shop Modal
			shop.Xbtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				if (shopCurrentView == "Category") {
					hideAllModal();
					shop.Xbtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				}
				//Close Character/Weaponry Shop
				else if (shopCurrentView == "Character" || shopCurrentView == "Weaponry") {
					shopInit();
				}
				//Close Show Info - Showing Full Item/Upgrade details
				else if (shopCurrentView == "ShowInfo") {
					showNavigation();
					hideAllShopItemInfo();
					
					var buyWeaponUpgradeBtn:MovieClip = shop.getChildByName("buyWeaponUpgradeBtn") as MovieClip
					//Remove the buyWeaponUpgradeBtn at modal to refresh the event
					if (shop.contains(buyWeaponUpgradeBtn)) {
						shop.removeChild(buyWeaponUpgradeBtn);
					}
					
					//Show Items
					shop.shopItemContainer_mc.visible = true;
				}
			});
		}
		
		public function shopInit ():void {
			//Remove MouseEvent in Navigation
			removeShopNavEvent();
			
			//Hide Shop Item Navigation
			hideNavigation();
			
			//Hide Shop Items
			hideShopItems();
			
			//Show Category
			showShopCategory();
		}
		
		//Hide Shop Message Modal
		public function hideShopMessage ():void {
			shop.shopMsg.visible = false;
			shop.shopMsg.message_txt.text = "";
		}
		
		private function showShopCategory ():void {
			shopCurrentView = "Category";
			shop.characterBtn.visible = true;
			shop.weaponryBtn.visible = true;
		}
		
		private function hideShopCategory():void {
			shop.characterBtn.visible = false;
			shop.weaponryBtn.visible = false;
		}

		public function hideShopItems ():void {
			//Go back to items page 1
			shopItemCurrentPage = 1;
			
			//Remove Shop Items
			removeShopAllItems();
			
			//Hide ShopItems
			shop.shopItemContainer_mc.visible  = false;
		}
		
		public function showShopItems ():void {
			var shopItemYPosition:Number;
			var shopItemXPosition:Array;
			var shopItem:ShopItem;
			var shopItemsContainer:MovieClip;
			var shopItemsArr:Array =  new Array();
			
			hideShopCategory();//Hide Category
			
			removeShopAllItems();//Remove Items (Reset the Shop Item Container)
			
			shopItemYPosition = 2.45;
			shopItemXPosition = [-273.35, 0, 270];
			shopItemsContainer = shop.shopItemContainer_mc;
			shopItemsArr = DB.getShopItems(shopCurrentView, shopItemCurrentPage) !== "" ? DB.getShopItems(shopCurrentView, shopItemCurrentPage) : []; //Get items info condition
			
			//Show Message no Items available
			if (shopItemsArr.length == 0) {
				trace("No Items Available");
				//Show Message modal if ever...
				return;
			}
			
			for (var i = 0; i < shopItemsArr.length; i++) {
				shopItem = new ShopItem(shopItemsArr[i]);
				shopItemsContainer.addChild(shopItem);
				shopItemsContainer.getChildAt(i).x = shopItemXPosition[i];
				shopItemsContainer.getChildAt(i).y = shopItemYPosition;
			}
			
			//Show Items
			shop.shopItemContainer_mc.visible = true;
			
			shopItemsContainer.visible = true;
			
			showNavigation();
		}
		
		public function removeShopAllItems ():void {
			var shopItems:MovieClip = shop.shopItemContainer_mc;
			if (shopItems.numChildren) {
				while (shopItems.numChildren > 0) {
					shopItems.removeChildAt(0);
				}
			}	
		}
		
		//Hide All Shop Item Full Info
		private function hideAllShopItemInfo ():void {
			//Hide ItemInfo
			shopCurrentView = (shopPickCategory != "" ? shopPickCategory : shopCurrentView);
			shop.upgradeInfo_mc.visible = false;
			shop.weaponInfo_mc.visible = false;
			shop.itemDisplay_mc.visible = false;
		}
		
		public function showNavigation ():void {
			shop.nextBtn.visible = false;
			shop.prevBtn.visible = false;
			
			//Condition if what button to be shown
			if (shopItemPageCount > 1) {
				shop.nextBtn.visible = true;
				if (shopItemCurrentPage > 1) {
					//Currently in page (2,3, etc..)
					shop.prevBtn.visible = true;
				}
				if (shopItemCurrentPage == shopItemPageCount) {
					shop.nextBtn.visible =  false;
				}
			}
			
			if (!shop.nextBtn.hasEventListener(MouseEvent.CLICK) && !shop.prevBtn.hasEventListener(MouseEvent.CLICK)) {
				shop.nextBtn.addEventListener(MouseEvent.CLICK, nextShopPage);
				shop.prevBtn.addEventListener(MouseEvent.CLICK, prevShopPage);
			}
		}
		
		private function hideNavigation ():void {
			//Hide All Shop Buttons
			shop.prevBtn.visible = false;
			shop.nextBtn.visible = false;
		}
		
		private function nextShopPage (e:MouseEvent):void {
			shopItemCurrentPage++;
			showShopItems();
		}
		
		private function prevShopPage (e:MouseEvent):void {
			shopItemCurrentPage--;
			showShopItems();
		}
		
		private function removeShopNavEvent ():void {
			shop.nextBtn.removeEventListener(MouseEvent.CLICK, nextShopPage);
			shop.prevBtn.removeEventListener(MouseEvent.CLICK, prevShopPage);
		}
				
		private function pageCount ():void {
			shopItemsCount = DB.getShopItemsCount(shopCurrentView);//Get the all shop items count
			shopItemDisplayLimit = 3;
			shopItemPageCount = Math.ceil(shopItemsCount / shopItemDisplayLimit);//Get the page count of current category
		}
		
		/********************************** END OF SHOP *********************************************/
		
		/********************************** SHOW EXIT MODAL *****************************************/
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
		/********************************** END OF SHOW EXIT MODAL *****************************************/
		
		/******************************** SELECT LEVEL MODAL *******************************************/
		
		public function showLevel (title:String, selectedStage:int):void {
			level.visible = true;
			levelsCon =  level.levelsCon;
			//Add Events to Level Buttons
			levelBtnEvent(selectedStage);
			//Show Parent Modal
			modal.showModal();
			//Change stage title
			level.title_txt.text = title;
			//Start Button
			level.startBtn.visible = false;
			
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
						level.startBtn.visible = true;
						curTarget.filters = [myGlow];
						
						//Start Level
						level.startBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { 
							resetLevelModal();
							hideAllModal();
							_Game = new Game();
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
		
		/**************************** END OF SELECT LEVEL MODAL *******************************************/
		
		/************************************** SETTINGS MODAL **************************************/
		
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
		/************************************** END OF SETTINGS MODAL **************************************/
	}
}