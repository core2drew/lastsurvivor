package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import JoyStick;
	import Survivor;
	
	public class Menu extends MovieClip {
		
		public var main:Main;
		public var db:Database;
		public var modal:Modal;
		
		public function Menu(main:Main) {
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
			modal = main.modal;
			x = 400;
			y = 520;
			addEventListener(MouseEvent.CLICK, menuItemClicked);
		}
		
		//Menu Buttons
		public function menuItemClicked (e:MouseEvent):void {
			switch (e.target.name) {
				case "shopBtn":
					modal.showShop();
				break;
				
				case "settingsBtn":
					modal.showSettings(db,"Main");
				break;
				
				case "helpBtn":
					modal.showTutorial();
				break;
				
				case "exitBtn":
					modal.showExit();
				break;
				
				default:
			};
		}
		
		public function show():void {
			visible = true;
		}
		
		public function hide():void {
			visible = false;
		}
	}
	
}
