package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import Database;
	
	public class CharacterStat extends MovieClip
	{
		
		private var db:Database;
		private var healthPoints:int;
		private var armorPoints:int;
		
		
		public function CharacterStat() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			db = new Database();
			this.name = "characterStat";
			this.x = 685;
			this.y = 80;
			healthPoints = db.getCurrentCharacterStatus().health;
			armorPoints = db.getCurrentCharacterStatus().armor;
		}
	}
}