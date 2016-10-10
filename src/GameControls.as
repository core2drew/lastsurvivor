package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import Bullet;
	
	public class GameControls extends MovieClip {
		
		private var main:Main;
		private var game:Game;
		private var bullet:Bullet;
		private var survivor:Survivor;
		private var scrollX:int;
		private var ground:int;
		private var playerDirection:String;
		private var jumping:Boolean;
		
		public function GameControls(main:Main) {
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
			game = main.game;
			survivor = main.survivor;
			x = 1500;
			y = 960;
			jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);//Add jumping Event
			fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, fireBullet);//Firing Event
		}
		
		private function fireBullet (e:TouchEvent):void {
			var scrollX:int = game.scrollX;
			var ground:int = game.ground;
			var playerDirection:String = game.playerDirection;
			
			if (survivor.scaleX < 0)
			{
				playerDirection = 'left';
			}
			else if (survivor.scaleX > 0)
			{
				playerDirection = 'right';
			}
			
			bullet = new Bullet(scrollX, ground, survivor, playerDirection);
			game.scrollBG.addChild(bullet);
		}
		
		private function Jump (e:TouchEvent):void {
			if (survivor.y >= ground) {
				game.jumping = true;
				survivor.Jump();
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
