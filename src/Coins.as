package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import Helper;
	
	public class Coins extends MovieClip {
		
		private var main:Main;
		private var db:Database;
		
		public function Coins(main:Main) {
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
			name = "coins";
			x = 988.9;
			y = 105.6;
		}
		
		//Update Coin Container
		public function updateCoins (itemPrice:int):void {
			currentCoins_txt.text = Helper.formatCost(String(parseInt(currentCoins_txt.text.replace(",", "")) - itemPrice), 0, "", 0);
			db.buyShopItem(itemPrice);//Update the Game State Coin
		}
		
		public function displayCoin():void {
			visible = true;
			currentCoins_txt.text = Helper.formatCost(db.getCoins().toString(), 0, "", 0);
		}
		
		public function hide():void {
			visible = false;
		}
	}
}
