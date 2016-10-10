package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class User extends MovieClip {
		
		private var main:Main;
		private var db:Database;
		
		public function User(main:Main) {
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
			name = "user";
			x = 220.9;
			y = 105.6;
		}
		
		public function displayUser():void {
			visible = true;
			user_txt.text = db.getSelectedUser();
		}
		
		public function hide():void {
			visible = false;
		}
	}
}
