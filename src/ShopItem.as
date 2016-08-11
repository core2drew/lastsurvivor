package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import Modal;
	import Helper;
	import Database;
	
	public class ShopItem extends MovieClip {
		private var DB:Database;
		private var shopModal:MovieClip;
		private var itemDetails:Object;
		private var frameToShow:int;
		private var itemID:int;
		private var itemName:String;
		private var itemPrice:int;
		private var itemBullets:String;
		private var itemDamage:int;
		private var itemReload:int;
		private var itemLevel:int;
		private var itemUpgrades:Array;
		private var currentBullet:String;

		public function ShopItem(itemDetails:Object) {
			this.itemDetails = itemDetails;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
			stop();
			DB = new Database();
			shopModal = this.parent.parent as MovieClip;
			
			//Shop Item Details
			frameToShow = itemDetails.frame;
			itemID = itemDetails.id;
			itemName = itemDetails.name;
			itemPrice = itemDetails.price;
			itemBullets = itemDetails.bullets;
			itemDamage = itemDetails.damage;
			itemReload = itemDetails.reload;
			itemLevel = itemDetails.level;
			itemUpgrades = String(itemDetails.upgrades).split(",");
			//Shop Item Display and Text
			this.itemText.text = itemName;
			this.gotoAndStop(frameToShow);
			addEventListener(MouseEvent.CLICK, showItemInfo);
		}
		
		
		public function showItemInfo(e:MouseEvent):void {
			hideShopNav();
			
			Modal.shopPickCategory = Modal.shopCurrentView;
			Modal.shopCurrentView = "ShowInfo"
			
			//Hide Shop Items
			shopModal.shopItemContainer_mc.visible = false;
			
			//Show Item Display
			shopModal.itemDisplay_mc.visible = true;
			
			//Full Item Info Display
			shopModal.itemDisplay_mc.gotoAndStop(frameToShow);
			shopModal.itemDisplay_mc.item_txt.text = itemName;
			
			//Full Item  Global Container
			shopModal.itemID_txt.text = itemID;
			shopModal.price_txt.text = Helper.formatCost(itemPrice.toString(), 0, "", 0);
			
			//Show ItemInfo
			if (Modal.shopPickCategory == "Character") {
				//Show Character Upgrade Info
				shopModal.upgradeInfo_mc.visible = true;
				shopModal.upgradeInfo_mc.currentLevel_txt = itemLevel;
				
				shopModal.upgradeInfo_mc.upgradeIcon_mc.stop();
				shopModal.upgradeInfo_mc.upgradeIcon_mc.gotoAndStop(frameToShow);
				
				shopModal.upgradeInfo_mc.price_txt.text = Helper.formatCost(itemPrice.toString(),0,"",0);
			}
			else if (Modal.shopPickCategory == "Weaponry") {
				//Show Weapon Item Info
				shopModal.weaponInfo_mc.visible = true;
				shopModal.weaponInfo_mc.damage_txt.text = itemDamage;
				//Bullet Info
				currentBullet = String(DB.getCurrentBullet(itemID));
				shopModal.weaponInfo_mc.bullet_txt.text = itemBullets + "/" + currentBullet
				
				shopModal.weaponInfo_mc.reload_txt.text = itemReload + " sec";
				shopModal.weaponInfo_mc.price_txt.text = Helper.formatCost(itemPrice.toString(),0,"",0);
			}
			showBuyItemBtn();
		}
		
		private function hideShopNav ():void {
			//Hide Navigation
			shopModal.prevBtn.visible = false;
			shopModal.nextBtn.visible = false;
		}
		
		private function showBuyItemBtn ():void {
			shopModal.buyBtn.visible = true;
		}
	}
}
