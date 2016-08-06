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
		private var itemReload:int;
		private var itemDamage:int;
		private var currentBullet:String;

		public function ShopItem(itemDetails:Object) {
			this.itemDetails = itemDetails;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
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
			
			this.itemText.text = itemName;
			
			addEventListener(MouseEvent.CLICK, showItemInfo);
		}
		
		
		public function showItemInfo(e:MouseEvent):void {
			Modal.shopPickCategory = Modal.shopCurrentView;
			Modal.shopCurrentView = "ShowInfo"
			
			//Hide Shop Items
			shopModal.shopItems_mc.visible = false;
			
			hideShopNav();
			
			//Shop Global Container
			shopModal.itemID_txt.text = itemID;
			shopModal.price_txt.text = Helper.formatCost(itemPrice.toString(), 0, "", 0);
			
			//Show ItemInfo
			if (Modal.shopPickCategory == "Character") {
				//Show Character Info
			}
			else if (Modal.shopPickCategory == "Weaponry") {
				shopModal.weaponInfo_mc.visible = true;
				shopModal.itemID_txt.text = itemID;
				shopModal.weaponInfo_mc.gunDisplay_mc.weapon_txt.text = itemName;
				shopModal.weaponInfo_mc.damage_txt.text = itemDamage;
				//Bullet Info
				currentBullet = String(DB.getCurrentBullet(Game.UserID, itemID));
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
