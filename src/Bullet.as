﻿
package  {
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.*;
	import Main;
	
	public class Bullet extends MovieClip {
		
		//how quickly the bullet will move
		private var speed:int = 80;
		private var initialX:int;
		private var deadZombieIndex:int;
		
		public function Bullet(playerX:int,playerY:int, playerDirection:String) 
		{
			// constructor code
			if (playerDirection == "left") 
			{
				speed = -30; //speed is faster if player is running
				x = playerX - 180;
			} else if (playerDirection == "right") 
			{
				speed = 30;
				x = playerX + 180;
			}
			y = playerY - 180;
			
			initialX = x; //use this to remember the initial spawn point
			
			//functions that will run on enter frame
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function bulletTypes ():void {
			//Change Bullets depend on what weapon survivor use
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
		public function removeSelf():void
		{
			removeEventListener(Event.ENTER_FRAME, loop); //stop the loop
			this.parent.removeChild(this); //tell this object's "parent object" to remove this object
			//in our case, the parent is the background because in the main code we said:
			//back.addChild(bullet);
		}
		
		public function bulletHitTargetChecker():void 
		{
			for (var i:int = 0; i < Game.zombieList.length; i++)
			{
				if (this.hitTestObject(Game.zombieList[i] as MovieClip))
				{
					//Remove Zombie
					Game.zombieList[i].removeSelf();
					deadZombieIndex = i;
					Game.zombieList.splice(deadZombieIndex, 1);
					Main.mainStage.kills_mc.kill_txt.text = String( Number(Main.mainStage.kills_mc.kill_txt.text) + 1 );
					//Remove the Bullet
					removeSelf();
				}
			}
		}
	}
}