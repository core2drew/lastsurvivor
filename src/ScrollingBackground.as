package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ScrollingBackground extends MovieClip {
		private var main:Main;
		
		public function ScrollingBackground(main:Main) {
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
			x = 0;
			y = 0;
		}
		
		public function show():void {
			visible = true;
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function reset():void {
			x = 0;
		}
	}
}
