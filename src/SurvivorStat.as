package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import Main;
	
	public class SurvivorStat extends MovieClip
	{
		private var healthPoints:int;
		private var currentHealthPoints:Number;
		private var healthBar:MovieClip;
		private var healthPercentage:Number;
		private var armorPoints:int;
		private var currentArmorPoints:int;
		private var armorBar:MovieClip;
		private var armorPercentage:Number;
		private var main:Main;
		private var db:Database;
		private var game:Game;
		
		public function SurvivorStat(main:Main) 
		{
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
			game = main.game;
			name = "survivorStat";
			x = 685;
			y = 80;
		}
		
		public function displayStat():void {
			show();
			
			healthPoints = db.getCurrentCharacterStatus().health;
			armorPoints = db.getCurrentCharacterStatus().armor;
			
			currentHealthPoints = healthPoints;
			currentArmorPoints = armorPoints;
			
			healthBar = healthBarContainer_mc.healthBar;
			armorBar = armorBarContainer_mc.armorBar;
			
			healthBar.mask.scaleX = 1;
			armorBar.mask.scaleX = armorPoints ? 1 : 0;	
		}
		
		
		public function takeDamage (damage:Number):void {
			if (currentArmorPoints > 0) {
				currentArmorPoints -= damage;
				armorPercentage = currentArmorPoints / armorPoints;
				armorBar.mask.scaleX = armorPercentage;
				return;
			}
			
			currentHealthPoints -= damage;
			healthPercentage = currentHealthPoints / healthPoints;
			healthBar.mask.scaleX = healthPercentage;
			
			if (currentHealthPoints <= 0 && !game.survivorDied) {
				game.survivorDied = true;
				game.gameOver();
			}
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function show():void {
			visible = true;
		}
	}
}