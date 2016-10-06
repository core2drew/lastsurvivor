package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import Database;
	
	public class CharacterStat extends MovieClip
	{
		
		private var db:Database;
		private var healthPoints:int;
		private var currentHealthPoints:Number;
		private var healthBar:MovieClip;
		private var healthPercentage:Number;
		private var armorPoints:int;
		private var currentArmorPoints:int;
		private var armorBar:MovieClip;
		private var armorPercentage:Number;
		
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
			
			currentHealthPoints = healthPoints;
			currentArmorPoints = armorPoints;
			
			healthBar = healthBarContainer_mc.healthBar;
			armorBar = armorBarContainer_mc.armorBar;
			
			healthBar.mask.scaleX = 1;
			armorBar.mask.scaleX = armorPoints ? 1 : 0;
		}
		
		public function takeDamage (damage:Number) {
			if (currentArmorPoints > 0) {
				currentArmorPoints -= damage;
				armorPercentage = currentArmorPoints / armorPoints;
				armorBar.mask.scaleX = armorPercentage;
				return;
			}
			
			currentHealthPoints -= damage;
			healthPercentage = currentHealthPoints / healthPoints;
			healthBar.mask.scaleX = healthPercentage;
		}
	}
}