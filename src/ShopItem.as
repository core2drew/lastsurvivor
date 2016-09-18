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
		private var DB:Database;
		private var shopModal:MovieClip;
		private var itemDetails:Object;
		private var itemID:int;
		private var itemdisplayFrame:int;
		private var itemName:String;
		private var itemPrice:int;
		private var itemWeaponBullets:int;
		private var itemWeaponDamage:int;
		private var itemWeaponReloadTime:int;
		private var itemUpgradeLevel:int;
		private var itemUpgrades:Array = new Array();
		private var buyUpgrade_btn:MovieClip
		
		public function ShopItem(itemDetails:Object) {
			this.itemDetails = itemDetails;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
			stop();
			DB = new Database();
			shopModal = this.parent.parent as MovieClip;
			
			//Shop Item Details
			itemID = itemDetails.id;//Unique ID of Item
			itemdisplayFrame = itemDetails.frame;//Frame for Display Item
			itemName = itemDetails.name;//Item Name
			itemPrice = itemDetails.price;//Item Price / Item PriceArr
			itemWeaponBullets = itemDetails.bullets;//Weapon Bullets
			itemWeaponDamage = itemDetails.damage;//Weapon Damage
			itemWeaponReloadTime = itemDetails.reload;//Weapon Reload Time
			itemUpgradeLevel = itemDetails.level;//Upgrade Level it must be start with zero
			itemUpgrades = String(itemDetails.upgrades).split(",");//Upgrade Additional Array
			
			//Shop Item Display and Text
			this.itemText.text = itemDetails.name;
			this.gotoAndStop(itemDetails.frame);
			addEventListener(MouseEvent.CLICK, showItemInfo);
		}
		
		//Show the info of the selected upgrade / weapon
		public function showItemInfo(e:MouseEvent):void {
			hideShopNav();
			
			Modal.shopPickCategory = Modal.shopCurrentView;
			Modal.shopCurrentView = "ShowInfo"
			
			//Hide Shop Items
			shopModal.shopItemContainer_mc.visible = false;
			
			//Show Item Display
			shopModal.itemDisplay_mc.visible = true;
			
			//Show Buy/Upgrade Button
			showBuyUpgrade();
			
			//Full Item Info Display
			shopModal.itemDisplay_mc.gotoAndStop(itemDetails.frame);
			shopModal.itemDisplay_mc.item_txt.text = itemDetails.name;
			
			//Full Item  Global Container
			shopModal.itemID_txt.text = itemDetails.id;
			
			//Show ItemInfo
			if (Modal.shopPickCategory == "Character") {
				var characterStatus:Array = DB.getCurrentCharacterStatus();
				var priceArr:Array = String(itemDetails.price).split(",");
				var upgradeValue = " (+" + itemUpgrades[itemUpgradeLevel] + ")";
				
				//Show Character Upgrade Info
				shopModal.upgradeInfo_mc.visible = true;
				//Upgrade Level Label
				shopModal.upgradeInfo_mc.currentLevel_txt.text = itemDetails.level;
				
				//Change Text of Buy/Upgrade Button
				buyUpgrade_btn.text_txt.text = "Upgrade";
				switch (itemDetails.name) 
				{
					case "Health":
						shopModal.upgradeInfo_mc.currentUpgrade_txt.text = characterStatus[0].health + upgradeValue;
					break;
					
					case "Armor":
						shopModal.upgradeInfo_mc.currentUpgrade_txt.text = characterStatus[0].armor + upgradeValue;
					break;
					
					case "Gun Slot":
						shopModal.upgradeInfo_mc.currentUpgrade_txt.text = characterStatus[0].gun_slot + upgradeValue;
					break;
					
					default:
				}
				
				shopModal.upgradeInfo_mc.price_txt.text = Helper.formatCost(priceArr[itemUpgradeLevel].toString(), 0, "", 0);
			}
			else if (Modal.shopPickCategory == "Weaponry") {
				var currentBullets;
				//Change Text of Buy/Upgrade Button
				buyUpgrade_btn.text_txt.text = "Buy";
				
				//Show Weapon Item Info
				shopModal.weaponInfo_mc.visible = true;
				shopModal.weaponInfo_mc.damage_txt.text = itemDetails.damage;
				
				currentBullets = String(DB.getCurrentBullet(itemDetails.id));
				shopModal.weaponInfo_mc.bullet_txt.text = itemDetails.bullets + "/" + currentBullets
				
				shopModal.weaponInfo_mc.reload_txt.text = String(itemDetails.reload) + " sec";
				shopModal.weaponInfo_mc.price_txt.text = Helper.formatCost(itemDetails.price.toString(), 0, "", 0);
			}
		}
		
		private function showBuyUpgrade() {
		var buyWeaponUpgradeBtn:buyWeaponOrUpgrade = new buyWeaponOrUpgrade();
			buyWeaponUpgradeBtn.name = "buyWeaponUpgradeBtn";
			//Add Shop Buy Weapon/Upgrade Button
			shopModal.addChild(buyWeaponUpgradeBtn);
			//Positioning of Buy Weapon/Upgrade
			buyUpgrade_btn = shopModal.getChildByName("buyWeaponUpgradeBtn") as MovieClip
			buyUpgrade_btn.x = -10;
			buyUpgrade_btn.y = 370.2	
			
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
			currentCoin = DB.getCoins();
			
			//Item price
			if (Modal.shopPickCategory === "Character") {
				itemPrice = parseInt(shopModal.upgradeInfo_mc.price_txt.text.replace(",", ""));
			}
			else if (Modal.shopPickCategory === "Weaponry") {
				itemPrice = parseInt(shopModal.weaponInfo_mc.price_txt.text.replace(",", ""));
			}
			
			if (currentCoin >= itemPrice) {
				itemName = shopModal.itemDisplay_mc.item_txt.text;
				
				if (Modal.shopPickCategory == "Character") {
					
					/*switch (itemName) 
					{
						case "Health":
							
						break;
						
						case "Armor":
						
						break;
						
						case "Gun Slot":
						
						break;
						default:
					}*/
					
					
					//Update the ShopItem Upgrade Fields
					updatedUpgradeStat = String(parseInt(shopModal.upgradeInfo_mc.currentUpgrade_txt.text) + int(itemUpgrades[itemUpgradeLevel]));
					itemUpgradeLevel = itemUpgradeLevel + 1;
					shopModal.upgradeInfo_mc.currentLevel_txt.text = itemUpgradeLevel;
					shopModal.upgradeInfo_mc.currentUpgrade_txt.text = updatedUpgradeStat + "(+" + itemUpgrades[itemUpgradeLevel] + ")";
					shopModal.upgradeInfo_mc.price_txt.text = Helper.formatCost(String(itemPrice * 2));
					
					//And Update UpgradeShop Table
					DB.updateUpgradeShopLevel(itemID, itemUpgradeLevel);
				}
				else if (Modal.shopPickCategory == "Weaponry") {
					
					bulletTxt = shopModal.weaponInfo_mc.bullet_txt.text;
					bullet = int(bulletTxt.substring(0, bulletTxt.indexOf("/")));
					
					//Update Weaponry Table
					checkWeaponry = DB.checkWeaponry(itemID);
					if (checkWeaponry > 0) {
						//Just Add the bullets of the bought weapon
						//Bullet limit = 999 the excess will be void
						DB.updateBulletsWeaponry(itemID, bullet);
					} else {
						//Add the weapon to weaponry table with bullets
						DB.addToWeaponry(itemID, itemName, bullet);
					}
					
					//Update bullet_txt current bullet
					currentBullet = DB.getCurrentBullet(itemID);
					shopModal.weaponInfo_mc.bullet_txt.text = String(bullet) + "/" + String(currentBullet);
				}
				
				//Update the Coin Container
				Main.updateCoins(itemPrice);
				//Update the Game State Coin
				DB.buyShopItem(itemPrice);
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
		
		//Hide shop modal navigation
		private function hideShopNav ():void {
			//Hide Navigation
			shopModal.prevBtn.visible = false;
			shopModal.nextBtn.visible = false;
		}
	}
}
