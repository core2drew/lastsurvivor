package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import Modal;
	import Helper;
	import Database;
	import Main;
	
	public class ShopItem extends MovieClip {
		private var main:Main;
		private var db:Database;
		private var shopModal:MovieClip;
		private var itemDetails:Object;
		private var itemID:int;
		private var itemdisplayFrame:int;
		private var itemName:String;
		private var itemPrice;
		private var itemWeaponBullets:int;
		private var itemWeaponMaxBullets:int;
		private var itemWeaponDamage:int;
		private var itemWeaponReloadTime:int;
		private var itemWeaponLevelReq:int;
		private var itemUpgradeLevelIndex:int;
		private var itemUpgradeLevel:int;
		private var itemUpgrades:Array = new Array();
		private var buyUpgrade_btn:MovieClip
		private var updatePriceArr:Array;
		private var characterStatus:Object;
		private var currentSelectedStat:int;
		private var userCurrentLevel:int;
		
		public function ShopItem(itemDetails:Object, main:Main) {
			this.itemDetails = itemDetails;
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
			stop();
			
			db = main.db;
			userCurrentLevel = db.getCurrentLevel();
			shopModal = this.parent.parent as MovieClip;
			
			//Shop Item Details
			itemID = itemDetails.id;//Unique ID of Item
			itemdisplayFrame = itemDetails.frame;//Frame for Display Item
			itemName = itemDetails.name;//Item Name
			itemPrice = itemDetails.price;//Item Price / Item PriceArr
			itemWeaponBullets = itemDetails.bullets;//Weapon Bullets
			itemWeaponMaxBullets = itemDetails.max_bullets;
			itemWeaponDamage = itemDetails.damage;//Weapon Damage
			itemWeaponLevelReq = itemDetails.levelreq;//Weapon require level
			itemWeaponReloadTime = itemDetails.reload;//Weapon Reload Time
			itemUpgradeLevelIndex = itemDetails.level;//Upgrade Level it must be start with zero
			itemUpgradeLevel = itemUpgradeLevelIndex + 1; //For Upgrade Level label
			itemUpgrades = String(itemDetails.upgrades).split(",");//Upgrade Additional Array
			//Shop Item Display and Text
			this.itemText.text = itemDetails.name;
			this.gotoAndStop(itemDetails.frame);
			addEventListener(MouseEvent.CLICK, showItemInfo);
		}
		
		//Show the info of the selected upgrade / weapon
		public function showItemInfo(e:MouseEvent):void {
			
			Modal.shopPickCategory = Modal.shopCurrentView;
			Modal.shopCurrentView = "ShowInfo"
			
			//Show Selected Item Display
			shopModal.itemDisplay_mc.visible = true;
			
			//Show Buy/Upgrade Button
			showBuyUpgrade();
			
			//Full Item Info Display Image
			shopModal.itemDisplay_mc.gotoAndStop(itemDetails.frame);
			
			//Full Item Info Display Fields
			shopModal.itemDisplay_mc.item_txt.text = itemDetails.name;
			
			//Show ItemInfo
			if (Modal.shopPickCategory == "Character") {
				
				//Get All Character Stats
				characterStatus = db.getCurrentCharacterStatus();
				
				updatePriceArr = String(itemDetails.price).split(",");
				
				
				switch (itemDetails.name) 
				{
					case "Health":
						currentSelectedStat = characterStatus.health;
						shopModal.upgradeInfo_mc.currentStatLabel_txt.text = "Current Health";
						shopModal.upgradeInfo_mc.currentStat_txt.text = characterStatus.health;
					break;
					
					case "Armor":
						currentSelectedStat = characterStatus.armor;
						shopModal.upgradeInfo_mc.currentStatLabel_txt.text = "Current Armor";
						shopModal.upgradeInfo_mc.currentStat_txt.text = characterStatus.armor;
					break;
					
					case "Gun Slot":
						currentSelectedStat = characterStatus.gun_slot;
						shopModal.upgradeInfo_mc.currentStatLabel_txt.text = "Current Gun Slot";
						shopModal.upgradeInfo_mc.currentStat_txt.text = characterStatus.gun_slot;
					break;
					
					default:
				}
				
				//Check if player reach the max upgrade level and change Level Label to 'Max' and remove the additional stat 
				checkIfMaxUpgradeLevel();
				
				//Show Character Upgrade Info
				shopModal.upgradeInfo_mc.visible = true;
				
			}
			else if (Modal.shopPickCategory == "Weaponry") {
				var currentBullets;
				
				//Show Weapon Item Info
				shopModal.weaponInfo_mc.visible = true;
				shopModal.weaponInfo_mc.damage_txt.text = String(itemWeaponDamage);
				
				currentBullets = String(db.getCurrentBullet(itemID));
				shopModal.weaponInfo_mc.bullet_txt.text = String(itemWeaponBullets) + "/" + currentBullets
				shopModal.weaponInfo_mc.maxbullet_txt.text = String(itemWeaponMaxBullets);
				shopModal.weaponInfo_mc.reload_txt.text = String(itemWeaponReloadTime) + " sec";
				shopModal.weaponInfo_mc.price_txt.text = Helper.formatCost(String(itemPrice), 0, "", 0);
				
			}
		}
		
		private function showBuyUpgrade() {
			var buyWeaponUpgradeBtn:buyWeaponOrUpgrade = new buyWeaponOrUpgrade();
			buyWeaponUpgradeBtn.name = "buyWeaponUpgradeBtn";
			
			//Add Shop Buy Weapon/Upgrade Button
			shopModal.addChild(buyWeaponUpgradeBtn);
			
			//Positioning of Buy Weapon/Upgrade
			buyUpgrade_btn = shopModal.getChildByName("buyWeaponUpgradeBtn") as MovieClip
			
			//Buy/Upgrade Button Positioning
			buyUpgrade_btn.x = -10;
			buyUpgrade_btn.y = 370.2	
			buyUpgrade_btn.visible = false;
			
			
			//Change Text of Buy/Upgrade Button
			if (Modal.shopPickCategory == "Character") {
				buyUpgrade_btn.text_txt.text = "Upgrade";
				buyUpgrade_btn.visible = true;
			}
			
			if (Modal.shopPickCategory == "Weaponry") {
				buyUpgrade_btn.text_txt.text = "Buy";
				shopModal.weaponInfo_mc.unlock_txt.visible = false;
				
				if (userCurrentLevel >= itemWeaponLevelReq) {
					buyUpgrade_btn.visible = true;
				}
				else {
					shopModal.weaponInfo_mc.unlock_txt.text = "Unlock At Level " + String(itemWeaponLevelReq);
					shopModal.weaponInfo_mc.unlock_txt.visible = true;
				}
			}
			
			buyUpgrade_btn.addEventListener(MouseEvent.CLICK, buyItemOrUpgradeChar);
		}
		
		public function buyItemOrUpgradeChar(e:MouseEvent):void {
			var updatedUpgradeStat:String;
			var bullet:int;
			var currentCoin:int;
			var currentBullet:int;
			var checkWeaponry:int;
			var bulletTxt:String;
			
			//Current Coins Item Conditon
			currentCoin = db.getCoins();
			
			//Item price
			if (Modal.shopPickCategory === "Character") {
				itemPrice = parseInt(shopModal.upgradeInfo_mc.upgradePrice_mc.price_txt.text.replace(",", ""));
			}
			
			if (Modal.shopPickCategory === "Weaponry") {
				itemPrice = parseInt(shopModal.weaponInfo_mc.price_txt.text.replace(",", ""));
			}
			
			if (currentCoin >= itemPrice) {
				itemName = shopModal.itemDisplay_mc.item_txt.text;
				
				if (Modal.shopPickCategory == "Character") {
					
					//Get Updated UpgradeStat
					updatedUpgradeStat = String(currentSelectedStat + int(itemUpgrades[itemUpgradeLevelIndex]));
					
					//Update Character Stat		
					switch (itemName) 
					{
						case "Health":
							db.upgradeCharacterStatus("health", int(updatedUpgradeStat) );
							
							//Upgrade Stat
							shopModal.upgradeInfo_mc.currentStat_txt.text = updatedUpgradeStat;
							
							//Get All Character Stats
							characterStatus = db.getCurrentCharacterStatus();
							
							currentSelectedStat = characterStatus.health;
						break;
						
						case "Armor":
							db.upgradeCharacterStatus("armor", int(updatedUpgradeStat) );
							
							//Upgrade Stat
							shopModal.upgradeInfo_mc.currentStat_txt.text = updatedUpgradeStat;
							
							//Get All Character Stats
							characterStatus = db.getCurrentCharacterStatus();
							
							currentSelectedStat = characterStatus.armor;
						break;
						
						case "Gun Slot":
							db.upgradeCharacterStatus("gun_slot", int(updatedUpgradeStat) );
							
							//Upgrade Stat
							shopModal.upgradeInfo_mc.currentStat_txt.text = updatedUpgradeStat;
							
							//Get All Character Stats
							characterStatus = db.getCurrentCharacterStatus();
							
							currentSelectedStat = characterStatus.gun_slot;
						break;
						default:
					}
						
					if (itemUpgradeLevel <= itemUpgrades.length) {
						
						//Update Item UpgradeLevelIndex
						itemUpgradeLevelIndex = itemUpgradeLevelIndex + 1;
						
						//Update Item UpgradeLevel for Level Label
						itemUpgradeLevel = itemUpgradeLevelIndex + 1
					}
					
					main.coins.updateCoins(itemPrice);//Update the Coin Container
					
					db.updateUpgradeShopLevel(itemID, itemUpgradeLevelIndex);//Update UpgradeShop Table
					
					checkIfMaxUpgradeLevel();
				}
				else if (Modal.shopPickCategory == "Weaponry") {
					
					bulletTxt = shopModal.weaponInfo_mc.bullet_txt.text;
					bullet = int(bulletTxt.substring(0, bulletTxt.indexOf("/")));
					
					//Update Weaponry Table
					checkWeaponry = db.checkWeaponry(itemID);
					if (checkWeaponry > 0) {
						//Just Add the bullets of the bought weapon
						//Bullet limit = 999 the excess will be void
						if (currentBullet < itemWeaponMaxBullets) {
							db.updateBulletsWeaponry(itemID, bullet);
						}else {
							showShopMessage("You reach the Max Bullet Capacity of this Weapon");
						}
					} else {
						//Add the weapon to weaponry table with bullets
						db.addToWeaponry(itemID, itemName, bullet);
					}
					
					//Update bullet_txt current bullet
					currentBullet = db.getCurrentBullet(itemID);
					shopModal.weaponInfo_mc.bullet_txt.text = String(bullet) + "/" + String(currentBullet);
				}
			}
			else {
				//Show Modal
				if (Modal.shopPickCategory === "Character") {
					showShopMessage("You don't have enough coins. Play more to buy this Upgrade");
				}
				else if (Modal.shopPickCategory === "Weaponry") {
					showShopMessage("You don't have enough coins. Play more to buy this Weapon");
				}
			}
		}
		
		//Hide Shop Message Modal
		public function hideShopMessage ():void {
			shopModal.shopMsg.visible = false;
			shopModal.shopMsg.message_txt.text = "";
		}
		
		//Show Message Modal
		public function showShopMessage (msg:String):void {
			shopModal.shopMsg.visible = true;
			shopModal.shopMsg.message_txt.text = msg;
			shopModal.shopMsg.CloseBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				shopModal.shopMsg.CloseBtn.removeEventListener(MouseEvent.CLICK, arguments.callee);
				hideShopMessage();
			});
		}
		
		private function checkIfMaxUpgradeLevel () {
			if (itemUpgradeLevel > itemUpgrades.length) {
				//shopModal.upgradeInfo_mc.currentLevel_txt.text = "Max";
				shopModal.upgradeInfo_mc.additionalUpgrade_txt.text = "Max";
				shopModal.upgradeInfo_mc.upgradePrice_mc.price_txt.text = "0";
				buyUpgrade_btn.visible = false;
			}
			else {
				//Upgrade Level Label
				//shopModal.upgradeInfo_mc.currentLevel_txt.text = itemUpgradeLevel;
				
				//Update Additional Stat
				shopModal.upgradeInfo_mc.additionalUpgrade_txt.text = "+" + String(itemUpgrades[itemUpgradeLevelIndex]);
				
				//Price
				shopModal.upgradeInfo_mc.upgradePrice_mc.price_txt.text = Helper.formatCost(String(updatePriceArr[itemUpgradeLevelIndex]), 0, "", 0);
			};
		}
	}
}
