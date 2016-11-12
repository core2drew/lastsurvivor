package 
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
	import Settings;
	import Database;
	
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Modal extends MovieClip {
		private var main:Main;
		private var game:Game;
		private var db:Database;
		private var modal:MovieClip;
		public var showing:Boolean;
		private var levelsCon:MovieClip = new MovieClip();
		public static var shopCurrentView:String;
		public static var shopPickCategory:String;
		private var shopUpgradeCategory:String;
		private var currentUpgradeLevel:int;
		private var shopItemCurrentPage:int;
		private var shopItemPageCount:int;
		private var shopItemDisplayLimit;
		private var shopItemsCount:int;
		private var shopItemsArr:Array =  new Array();
		
		//Select Level
		private var currentLevel:int;
		
		//Settings
		private var bgSound:int;
		private var SFX:int;
		private var currentView:String;
		
		//Level Complete
		private var star1:MovieClip;
		private var star2:MovieClip;
		private var star3:MovieClip;
		
		
		public function Modal(main:Main) {
			this.main = main;
			modal = this;
			
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			hideAllModal();
			
			game = main.game;
			db = main.db;
		}
		
		public function hideAllModal ():void {
			showing = false;
			modal.visible = false;
			pause.visible = false;
			lockmessage.visible = false;
			level.visible = false;
			levelcomplete.visible = false;
			gameover.visible = false;
			newUser.visible = false;
			shop.visible = false;
			settings.visible = false;
			tutorial.visible = false;
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
			modal.showModal();
			
			pause.resumeBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				game.resume();
				pause.resumeBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				hideAllModal();
			});
			
			pause.restartBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				game.restart();
				pause.restartBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				hideAllModal();
			});
		}
		/***************************************** END OF PAUSE MODAL *******************************************/

		/********************************** NEW USER MODAL *****************************************/
		
		public function showNewUser():void {
			var rex:RegExp = /[\s\r\n]+/gim;
			var str:String;
			newUser.visible = true;
			hideNewUserMessage ();
			
			//TweenMax.fromTo(newUser, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			newUser.newUser_txt.addEventListener(Event.CHANGE, function(e:Event){
				str = newUser.newUser_txt.text.toUpperCase();
				str = str.replace(rex, '');
				newUser.newUser_txt.text = str;
			});
			
			newUser.okBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				if(newUser.newUser_txt.length <= 2)
				{
					newUser.newUserMsg.visible = true;
					newUser.newUserMsg.message_txt.text = "Minimum of 3 characters is required and Maximum of 8 characters only"
					
					newUser.newUserMsg.CloseBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { 
						hideNewUserMessage();
						newUser.newUserMsg.CloseBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
					});
					
					return;
				}
				
				if (newUser.newUser_txt.length >= 3) {
					db.setNewUser(str);
					hideAllModal();
					newUser.okBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
					return;
				}
			});
		}
		
		//Hide Shop Message Modal
		public function hideNewUserMessage ():void {
			newUser.newUserMsg.visible = false;
		}
		
		/********************************** END OF NEW USER MODAL *********************************/
		
		
		/********************************** SHOP MODAL *********************************************/
		public function showShop ():void {
			shop.visible = true;
			
			shopInit();
			
			//TweenMax.fromTo(shop, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			 //Current Page Viewing
			shopItemCurrentPage = 1;
			
			shop.characterBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				shopCurrentView = "Character";
				
				//Get Total Page
				pageCount();
				
				//Show Upgrades Items
				showShopItems();
			});
			
			shop.weaponryBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) { 
				shopCurrentView = "Weaponry";
				
				//Get Total Page
				pageCount();
				
				//Show Weapons Items
				showShopItems();
			});
			
			shop.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				
				//Close Shop Modal
				if (shopCurrentView == "Category") {
					hideAllModal();
					shop.XBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				}
				
				//Close Character/Weaponry Shop
				else if (shopCurrentView == "Character" || shopCurrentView == "Weaponry") {
					shopInit();
				}
				
				//Close Show Info - Showing Full Item/Upgrade details
				else if (shopCurrentView == "ShowInfo") {
					
					//Show Prev/Next Navigation if needed base on condition
					showNavigation();
					
					//Hide Shop Item Full Info
					hideShopItemFullInfo();
					
					//Remove the buyWeaponUpgradeBtn at modal to refresh the event
					removeBuyWeaponUpgradeBtnEvent();
					
					//Generate Updated Show Items
					showShopItems();
				}
			});
		}
		
		public function shopInit ():void {
			
			//Hide Shop Message Modal
			hideShopMessage();
			
			//Remove MouseEvent in Navigation
			removeShopNavEvent();
			
			//Hide Shop Items
			hideShopItems();
			
			//Hide All Shop Item Full Info
			hideShopItemFullInfo();
			
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
			
			//Hide Shop Item Navigation
			hideNavigation();
			
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
			
			shopItemsArr =  new Array();
			
			//Hide Categorys
			hideShopCategory();
			
			//Remove All Items (Reset the Shop Item Container)
			removeShopAllItems();
			
			//Each Shop Items Positioning (X,Y)
			shopItemYPosition = 2.45;
			shopItemXPosition = [ -273.35, 0, 270];
			
			//Get Shop Items Full Info Object
			shopItemsArr = db.getShopItems(shopCurrentView, shopItemCurrentPage) !== "" ? db.getShopItems(shopCurrentView, shopItemCurrentPage) : []; //Get items info condition
			
			//Show Message no Items available
			if (shopItemsArr.length == 0) {
				//Show Message modal if ever...
				trace("No Items Available");
				return;
			}
			
			//Generate Updated Shop Item Full Info
			else {
				
				for (var i = 0; i < shopItemsArr.length; i++) {
					shopItem = new ShopItem(shopItemsArr[i], main);
					shop.shopItemContainer_mc.addChild(shopItem);
					shop.shopItemContainer_mc.getChildAt(i).x = shopItemXPosition[i];
					shop.shopItemContainer_mc.getChildAt(i).y = shopItemYPosition;
					shop.shopItemContainer_mc.getChildAt(i).addEventListener(MouseEvent.CLICK,function(){
						hideShopItems();
					});
				}
				
				shop.shopItemContainer_mc.visible = true;
				
				//Show Prev/Next Navigation if needed base on condition
				showNavigation();
			}
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
		private function hideShopItemFullInfo ():void {
			//Hide ItemInfo
			shopCurrentView = (shopPickCategory != "" ? shopPickCategory : shopCurrentView);
			
			//Shop Item Full Info Container
			shop.upgradeInfo_mc.visible = false;
			shop.weaponInfo_mc.visible = false;
			
			//Display Image for Shop Item Full Info
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
				shop.nextBtn.addEventListener(MouseEvent.CLICK, nextShopPage, false, 0, true);
				shop.prevBtn.addEventListener(MouseEvent.CLICK, prevShopPage, false, 0, true);
			}
		}
		
		private function hideNavigation ():void {
			//Hide All Shop Buttons
			shop.prevBtn.visible = false;
			shop.nextBtn.visible = false;
		}
		
		private function nextShopPage (e:MouseEvent):void {
			shopItemCurrentPage++;
			
			//Generate Updated Show Items
			showShopItems();
		}
		
		private function prevShopPage (e:MouseEvent):void {
			shopItemCurrentPage--;
			
			//Generate Updated Show Items
			showShopItems();
		}
		
		private function removeShopNavEvent ():void {
			shop.nextBtn.removeEventListener(MouseEvent.CLICK, nextShopPage);
			shop.prevBtn.removeEventListener(MouseEvent.CLICK, prevShopPage);
		}
				
		private function pageCount ():void {
			shopItemsCount = db.getShopItemsCount(shopCurrentView);//Get the all shop items count
			shopItemDisplayLimit = 3;
			shopItemPageCount = Math.ceil(shopItemsCount / shopItemDisplayLimit);//Get the page count of current category
		}
		
		//Remove the buyWeaponUpgradeBtn at modal to refresh the event
		private function removeBuyWeaponUpgradeBtnEvent() {
			try {
				var buyWeaponUpgradeBtn:MovieClip = shop.getChildByName("buyWeaponUpgradeBtn") as MovieClip
				if (shop.contains(buyWeaponUpgradeBtn)) {
					shop.removeChild(buyWeaponUpgradeBtn);
				}
			}
			catch (err:Error) {
				//Do nothing for now...
				//trace(err.message);
			}
		}
		
		/********************************** END OF SHOP *********************************************/
		
		/******************************** SELECT LEVEL MODAL *******************************************/
		
		public function showLevel (title:String, selectedStage:int):void {
			level.visible = true;
			levelsCon =  level.levelsCon;
			//Show Parent Modal
			modal.showModal();
			
			//Add Events to Level Buttons
			levelBtnEvent(selectedStage);
			
			//Change stage title
			level.title_txt.text = title;
			//Start Button
			level.startBtn.visible = false;
			
			//TweenMax.fromTo(level, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			
			//Hide Level Modal
			level.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				resetLevelModal();
				hideAllModal();
				level.XBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}, false, 0, true);
		}
		
		private function resetLevelModal ():void {
			var levelsCon:MovieClip = new MovieClip();
			var level_btn:MovieClip = new MovieClip();
			levelsCon =  level.levelsCon;
			
			//Remove Click Event in Level Button
			for (var i = 0; i < levelsCon.numChildren; i++) {
				level_btn = levelsCon.getChildAt(i) as MovieClip;
				if (level_btn.level_txt.visible) { 
					//Remove All Filters
					trace(level_btn);
					//and removeEventListener
					level_btn.removeEventListener(MouseEvent.CLICK, selectLevel);
				}
			}
			
			resetLevelButtonFilter();
			//Remove Click Event in Start Button
			level.startBtn.removeEventListener(MouseEvent.CLICK, startGame);
		}
		
		private function resetLevelButtonFilter() {
			var levelsCon:MovieClip = new MovieClip();
			var level_btn:MovieClip = new MovieClip();
			levelsCon =  level.levelsCon;
			
			for (var i = 0; i < levelsCon.numChildren; i++) {
				level_btn = levelsCon.getChildAt(i) as MovieClip;
				if (level_btn.level_txt.visible) { 
					//Remove All Filters
					level_btn.filters = [];
				}
			}
		}
		
		private function levelBtnEvent (selectedStage:int):void {
			
			var stageLeveldata:Array = db.getLevelStars(selectedStage);
			var level_btn:MovieClip = new MovieClip();
			var firstLevel:MovieClip;
			var star:MovieClip;
			var curTarget:MovieClip
			
			
			for (var i = 0; i < levelsCon.numChildren; i++) {
				level_btn = levelsCon.getChildAt(i) as MovieClip;
				
				//Change Button Level Number
				level_btn.level_txt.text = stageLeveldata[i].level;
				level_btn.level_txt.visible = false;
				
				//Stop Buttons Stars
				for (var x = 0; x < level_btn.starsCon.numChildren; x++) {
					star = level_btn.starsCon.getChildAt(x) as MovieClip;
					star.gotoAndStop(1);
				}
				
				//Show how many stars on each level
				for (var j = 0; j < stageLeveldata[i].stars; j++) {
					star = level_btn.starsCon.getChildAt(j) as MovieClip;
					star.gotoAndStop(2);
				}
				
			}
			
			//Level 1 Button
			firstLevel = levelsCon.getChildAt(0) as MovieClip;	
			firstLevel.closed.visible = false;
			firstLevel.level_txt.visible = true;
			
			
			//Level 2,3,4,5... button numbering
			for (var a = 1; a < levelsCon.numChildren; a++) {
				if (stageLeveldata[a - 1].stars > 0) {
					level_btn = levelsCon.getChildAt(a) as MovieClip;
					level_btn.closed.visible = false;
					level_btn.level_txt.visible = true;
				}
			}
			
			//Adding event on each Level button
			for (var b = 0; b < levelsCon.numChildren; b++) {
				level_btn = levelsCon.getChildAt(b) as MovieClip;
				
				//Add Event only when stage is unlocked
				if (level_btn.level_txt.visible) {
					level_btn.addEventListener(MouseEvent.CLICK, selectLevel, false, 0, true);
				}
				//Start Level Event
				level.startBtn.addEventListener(MouseEvent.CLICK, startGame, false, 0, true);
			}
		}
		
		private function selectLevel (e:MouseEvent):void {
			var curTarget:MovieClip =  e.currentTarget as MovieClip;
			var myGlow:GlowFilter = new GlowFilter(); 
			
			//Yellow Glow
			myGlow.inner = false; 
			myGlow.color = 0xFFDF1E; 
			myGlow.blurX = 15; 
			myGlow.blurY = 15; 
			myGlow.alpha = 0.5;
			curTarget.filters = [myGlow];
			
			currentLevel = curTarget.level_txt.text;
			
			//Show Start Button
			level.startBtn.visible = true;
		}
		
		private function startGame(e:MouseEvent):void {
			main.hideMainMenu();
			
			hideAllModal();
			
			game.GameInit(currentLevel);
			
			level.startBtn.removeEventListener(MouseEvent.CLICK, startGame);
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
				lockmessage.XBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}, false, 0, true);
		}
		
		/**************************** END OF SELECT LEVEL MODAL *******************************************/
		
		/************************************ LEVEL COMPLETE MODAL *******************************************/
		public function showLevelComplete(level:int, stars:int/*coinsCollected:int, zombieskilled:int, zombiesCount:int*/) {
			star1 = levelcomplete.star1_mc;
			star2 = levelcomplete.star2_mc;
			star3 = levelcomplete.star3_mc;
			
			star1.visible = false;
			star2.visible = false;
			star3.visible = false;
			star1.y = 325;
			star2.y = 325;
			star3.y = 325;
			
			levelcomplete.visible = true;
			modal.showModal();
			
			levelcomplete.complete_txt.text = String("Level " + level + " Complete!");
			
			switch (stars) 
			{
				case 1:
					showOneStar();
				break;
				
				case 2:
					showTwoStar();
				break;
				
				case 3:
					showThreeStar();
				break;
				default:
			}
			
			TweenMax.fromTo(levelcomplete, 2, { y: -540 }, { y:0, ease:Bounce.easeOut} );
			
			levelcomplete.mainBtn.addEventListener(MouseEvent.CLICK, levelCompleteToMain, false, 0, true);
			levelcomplete.restartBtn.addEventListener(MouseEvent.CLICK, restartLevel, false, 0, true);
			levelcomplete.nextBtn.addEventListener(MouseEvent.CLICK, nextLevel, false, 0, true);
		}
		
		private function removeLevelCompleteEvents():void {
			levelcomplete.mainBtn.removeEventListener(MouseEvent.CLICK, levelCompleteToMain);
			levelcomplete.restartBtn.removeEventListener(MouseEvent.CLICK, restartLevel);
			levelcomplete.nextBtn.removeEventListener(MouseEvent.CLICK, nextLevel);
		}
		
		private function levelCompleteToMain(e:MouseEvent) {
			backToMain();
			removeLevelCompleteEvents();
		}
		
		private function restartLevel(e:MouseEvent) {
			restartGame();
			removeLevelCompleteEvents();
		}
		
		private function nextLevel(e:MouseEvent) {
			removeLevelCompleteEvents();
		}
		
		public function showOneStar() {
			star1.visible = true;
			
			star1.x = 960;
		}
		
		public function showTwoStar() {
			star1.visible = true;
			star2.visible = true;
			
			star1.x = 775;
			star2.x = 1135;
		}
		
		public function showThreeStar() {
			star1.visible = true;
			star2.visible = true;
			star3.visible = true;
			
			star1.x = 600;
			star2.x = 960;
			star3.x = 1315;
		}
		/************************************ END LEVEL COMPLETE MODAL *******************************************/
		
		/************************************ GAME OVER MODAL *******************************************/
		
		public function showGameOver(/*coinsCollected:int, zombieskilled:int, zombiesCount:int*/) {
			gameover.visible = true;
			
			modal.showModal();
			
			TweenMax.fromTo(gameover, 2, { y:-540 }, { y:540, ease:Bounce.easeOut } );
			
			gameover.mainBtn.addEventListener(MouseEvent.CLICK, backToMain, false, 0, true);
			gameover.playBtn.addEventListener(MouseEvent.CLICK, playAgain, false, 0, true);
		}
		
		private function gameOverToMain(e:MouseEvent):void {
			backToMain();
			removeGameOverEvents();
		}
		
		private function playAgain(e:MouseEvent):void {
			restartGame();
			removeGameOverEvents();
		}
		
		private function removeGameOverEvents():void {
			gameover.mainBtn.removeEventListener(MouseEvent.CLICK, backToMain);
			gameover.playBtn.removeEventListener(MouseEvent.CLICK, playAgain);
		}
		
		/************************************ END OF GAME OVER MODAL ***********************************/
		
		/************************************** SETTINGS MODAL **************************************/
		
		public function showSettings (_currentView:String):void {
			bgSound = db.getBGSound();
			SFX = db.getSFX();
			currentView = _currentView;
			
			settings.visible = true;
			//TweenMax.fromTo(settings, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			if (!bgSound) {
				settings.bgmusic_cb.check.visible = false;
			}
			
			if (!SFX) {
				settings.sfx_cb.check.visible = false;
			}
			
			settings.bgmusic_cb.addEventListener(MouseEvent.CLICK, setBGMusic, false, 0, true);
			
			settings.sfx_cb.addEventListener(MouseEvent.CLICK, setSFX, false, 0, true);
			
			//Hide unlock Modal
			settings.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
				settings.bgmusic_cb.removeEventListener(MouseEvent.CLICK, setBGMusic);
				settings.sfx_cb.removeEventListener(MouseEvent.CLICK, setSFX);
				settings.XBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}, false, 0, true);
		}
		
		private function setBGMusic (e:MouseEvent) { 
			if (bgSound) {
				settings.bgmusic_cb.check.visible = false;
				db.updateBGSound(0);
				Settings.stopBGSounds();
			}
			else {
				settings.bgmusic_cb.check.visible = true;
				db.updateBGSound(1);
				Settings.playBGSound(db.getBGSound(), currentView);
			}
			
			bgSound = db.getBGSound()
		}
		
		private function setSFX(e:MouseEvent) {
			if (SFX) {
				settings.sfx_cb.check.visible = false;
				db.updateSFX(0);
			}
			else {
				settings.sfx_cb.check.visible = true;
				db.updateSFX(1);
			}
			SFX = db.getSFX();
		}
		/************************************** END OF SETTINGS MODAL **************************************/
		
		/************************************** TUTORIAL MODAL **************************************/
		
		public function showTutorial ():void
		{
			tutorial.visible = true;
			//TweenMax.fromTo(tutorial, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			tutorial.steps.gotoAndStop(1);
			
			tutorial.nav.prev_btn.addEventListener(MouseEvent.CLICK, prevSlide, false, 0, true);
			tutorial.nav.next_btn.addEventListener(MouseEvent.CLICK, nextSlide, false, 0, true);
			
			//Close the Tutorial Modal
			tutorial.XBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
				tutorial.nav.prev_btn.removeEventListener(MouseEvent.CLICK, prevSlide);
				tutorial.nav.next_btn.removeEventListener(MouseEvent.CLICK, nextSlide);
				tutorial.XBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}, false, 0, true);
		}
		
		private function prevSlide(e:MouseEvent) {
			tutorial.steps.prevFrame();
		}
		
		private function nextSlide(e:MouseEvent) {
			tutorial.steps.nextFrame();
		}
		
		/************************************** END OF SETTINGS MODAL **************************************/
		
		/********************************** SHOW EXIT MODAL *****************************************/
		public function showExit ():void {
			exit.visible = true;
			//TweenMax.fromTo(exit, .8, { x:2607 }, { x:955, ease:Back.easeOut } );
			modal.showModal();
			
			//Exit the Game
			exit.yesBtn.addEventListener(MouseEvent.CLICK, function () {
				NativeApplication.nativeApplication.exit();
			}, false, 0, true);
			
			//Hide Exit Modal
			exit.noBtn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent) {
				hideAllModal();
				exit.noBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
			}, false, 0, true);
		}
		/********************************** END OF SHOW EXIT MODAL *****************************************/
		
		private function backToMain() {
			hideAllModal();
			
			game.removeEnterFrame();
			game.hideGameUI();
			game.survivor.hide();
			game.removeAllZombies();
			game.removeAllBullets();
			game.isInGame = false;
			game.isGamePause = false;
			
			main.showMainMenu();
		}
		
		private function restartGame() {
			hideAllModal();	
			game.restart();
		}
	}
}