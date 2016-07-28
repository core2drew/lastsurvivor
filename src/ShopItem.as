package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import Database;
	
	
	public class ShopItem extends MovieClip {
		
		private var frameToShow:int;
		private var itemName:String;
		private var itemPrice:int;
		private var itemDescription:String;
		private var itemDamage:int;
		private var shopItemContainer:MovieClip;
		
		public function ShopItem(_shopItemContainer:MovieClip, itemDetails:Object) {
			//Shop Item Details
			frameToShow = itemDetails.frame;
			itemName = itemDetails.name;
			itemPrice = itemDetails.price;
			itemDescription = itemDetails.description;
			shopItemContainer = _shopItemContainer;
			shopItemContainer.itemText.text = itemName;
			
			
		}
	}
	
}
