
package  {
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.*;
	import Main;
	
	public class Bullet extends MovieClip {
		
		//how quickly the bullet will move
		private var speed:int = 70;
		private var initialX:int;
		private var deadZombieIndex:int;
		private var bulletDamage:Number;
		private var survivorHalfWidth;
		private var survivorHalfHeight;
		private var scrollX:int;
		private var ground:int;
		private var playerDirection:String;
		private var main:Main;
		private var game:Game;
		private var survivor:Survivor;
		private var gameControls:GameControls;
		private var joyStick:JoyStick;
		
		public function Bullet(main:Main, playerDirection:String) 
		{
			this.main = main;
			game = main.game;
			survivor = main.survivor;
			joyStick = main.joystick;
			gameControls = main.gameControls;
			
			scrollX = joyStick.scrollX;
			ground = gameControls.ground;
			
			survivorHalfWidth = survivor.width / 2 ;
			survivorHalfHeight = survivor.height / 2;
			
			if (playerDirection == "left") 
			{
				speed *= -1;
				x = (survivor.x - scrollX) - survivorHalfWidth;
			} 
			else if (playerDirection == "right") 
			{
				speed *= 1;
				x = (survivor.x - scrollX) + survivorHalfWidth;
			}
			
			y = (survivor.y - ground ) - survivorHalfHeight;
			
			initialX = x; //use this to remember the initial spawn point
			
			//functions that will run on enter frame
			addEventListener(Event.ENTER_FRAME, loop);
			
			//Temporary Params
			setBulletDamage(10);
		}
		
		public function setBulletDamage (damage:int):void {
			bulletDamage = damage;//Change Bullets depend on what weapon damage
		}
		
		private function loop(event:Event):void
		{
			//looping code goes here
			x += speed;
			
			if (speed > 0)
			{
				//if player is facing right
				if (x > initialX + 750) 
				{ //and the bullet is more than 1920px to the right of where it was spawned
					removeSelf(); //remove it
				}
				else
				{
					bulletHitTargetChecker();
				}
			} 
			else 
			{
				//else if player is facing left
				if (x < initialX - 750)
				{  //and bullet is more than 1920px to the left of where it was spawned
					removeSelf(); //remove it
				}
				else
				{
					bulletHitTargetChecker();
				}
			}
		}
		
		private function pause():void {
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function resume():void {
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function removeSelf():void
		{
			removeEventListener(Event.ENTER_FRAME, loop); //stop the loop
			this.parent.removeChild(this); //tell this object's "parent object" to remove this object
			//in our case, the parent is the background because in the main code we said:
			//back.addChild(bullet);
		}
		
		public function bulletHitTargetChecker():void 
		{
			for (var i:int = 0; i < game.zombieArr.length; i++)
			{
				if (this.hitTestObject(game.zombieArr[i] as MovieClip))
				{
					//Remove Zombie
					game.zombieArr[i].takeDamage(bulletDamage, i);
					//Remove the Bullet
					removeSelf();
				}
			}
		}
	}
}
