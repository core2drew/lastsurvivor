package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import Database;
	
	public class Map extends MovieClip {
		
		private var main:Main;
		private var db:Database;
		private var modal:Modal;
		private var userCurrentLevel:int;
		
		public function Map(main:Main) {
			this.main = main;
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init(e:Event = null):void {
			var mapStages:MovieClip;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			hide();
			db = main.db;
			modal = main.modal;
			x = 0;
			y = 0;
			userCurrentLevel = db.getCurrentLevel();
			addEventListener(MouseEvent.CLICK, mapStageClicked);
			
			//Lock All Stage
			for (var i = 1; i < this.numChildren; i++) {
				mapStages = this.getChildAt(i) as MovieClip;
				mapStages.gotoAndStop(1);
			}
			
			if (userCurrentLevel >= 1) {
				stage1.gotoAndStop(2);//Unlock Stage 1
			}
			
			if (userCurrentLevel >= 8) {
				stage2.gotoAndStop(2);//Unlock Stage 2
			}
			
			if (userCurrentLevel >= 16) {
				stage3.gotoAndStop(2);//Unlock Stage 3
			}
			
			if (userCurrentLevel >= 24) {
				stage4.gotoAndStop(2);//Unlock Stage 4
			}
			
			if (userCurrentLevel >= 36) {
				stage5.gotoAndStop(2);//Unlock Stage 5
			}
		}
		
		public function mapStageClicked (e:MouseEvent):void {
			if (e.target.currentFrame == 2) {
				switch (e.target.name) { 
					case "stage1":
						modal.showLevel("Safe House", 1);
					break;
					
					case "stage2":
						modal.showLevel("Windsor Highway", 2);
					break;
					
					case "stage3":
						modal.showLevel("Repocity", 3);
					break;
					
					case "stage4":
						modal.showLevel("Hollow Forest", 4);
					break;
					
					case "stage5":
						modal.showLevel("Surviror Camp", 5);
					break;
				}
			}
			
			else if (e.target.currentFrame == 1)
			{
				//lock messages
				switch (e.target.name) { 
					case "stage2":
						modal.showLockMessage("Safe House");
					break;
					
					case "stage3":
						modal.showLockMessage("Windsor Highway");
					break;
					
					case "stage4":
						modal.showLockMessage("Repocity");
					break;
					
					case "stage5":
						modal.showLockMessage("Hollow Forest");
					break;
				}
			}
		}
		
		public function show():void {
			visible = true;
		}
		
		public function hide():void {
			visible = false;
		}
	}
	
}
