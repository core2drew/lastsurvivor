package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import Modal;
	import Helper;
	
	public class ShopItem extends MovieClip {
		private var shopModal:MovieClip;
		private var itemDetails:Object;
		private var frameToShow:int;
		private var itemName:String;
		private var itemPrice:int;
		private var itemBullets:String;
		private var itemReload:int;
		private var itemDamage:int;

		public function ShopItem(itemDetails:Object) {
			this.itemDetails = itemDetails;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
			shopModal = this.parent.parent as MovieClip;
			
			//Shop Item Details
			frameToShow = itemDetails.frame;
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
			
			//Show ItemInfo
			if (Modal.shopPickCategory == "Character") {
				//Show Character Info
			}
			else if (Modal.shopPickCategory == "Weaponry") {
				shopModal.weaponInfo_mc.visible = true;
				shopModal.weaponInfo_mc.damage_txt.text = itemDamage;
				shopModal.weaponInfo_mc.bullet_txt.text = itemBullets;
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
