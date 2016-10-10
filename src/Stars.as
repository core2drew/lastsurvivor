package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Stars extends MovieClip {
		
		private var main:Main;
		private var db:Database;
		
		public function Stars(main:Main) {
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
			name = "stars";
			x = 604.3;
			y = 105.6;
		}
		
		public function displayStars():void {
			visible = true;
			maxStars_txt.text = db.getMaxStar().toString();
			currentStars_txt.text = db.getStars().toString();
		}
		
		public function hide():void {
			visible = false;
		}
	}
	
}
