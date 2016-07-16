﻿package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	
	public class Zombie extends MovieClip 
	{
		public var playerPosition:Number;
		public var survivor:Survivor;
		public var stageWidth:int;
		public var walkingBool:Boolean;
		public var attackingBool:Boolean;
		public var direction:String;
		public var zombieSpeed:Number;
		public var zombieLife:Number;
		
		private var zombieBody_mc:MovieClip;
		private var zombieLegs_mc:MovieClip;
		
		public function Zombie (xLocation:int, yLocation:int, direction:String,survivor:Survivor,stageWidth:int) {
            // constructor code
            x = xLocation;
            y = yLocation;
			zombieSpeed = 0.5;
			stop();
			addEventListener(Event.ENTER_FRAME, loop);
			this.stageWidth = stageWidth;
			this.survivor = survivor;
			this.direction = direction;
			zombieBody_mc = this.body_mc;
			zombieLegs_mc = this.legs_mc;
			zombieBody_mc.stop();
			zombieLegs_mc.stop();
			updateDirection();
        }
		
		public function updateDirection ():void {
			if (direction == 'left') {
				this.rotationY = 0;
			}
			else if (direction == 'right') {
				this.rotationY = 180;
			}
		}

        public function loop (e:Event):void {
            //the looping code goes here
			//actions e.g (walking, attacking, etc.)
			playerCollision();
			playerCurrentPosition();
        }

		//Remove Zombie
        public function removeSelf ():void {
            removeEventListener(Event.ENTER_FRAME, loop); //stop the loop
            this.parent.removeChild(this); //tell this object's "parent object" to remove this object
        }
		
		//Ready To Walk
		public function startWalk ():void {
			//Check the player current position
			//playerCurrentPosition();
			if (!walkingBool) {
				walkingBool = true;
				attackingBool = false;
			}
		}
		
		public function animateWalkingLegs ():void {
			zombieLegs_mc.play();
			if (zombieLegs_mc.currentFrame == 90) {
				zombieLegs_mc.gotoAndPlay(30);
			}
			
			if (zombieLegs_mc.currentLabel == "Forward") {
				if (direction == "left") {
					x += -1 * (zombieSpeed);
				}
				else if (direction == "right") {
					x += zombieSpeed;
				}
			}
		}
		
		public function animateWalkingBody ():void {
			zombieBody_mc.play();
			if (zombieBody_mc.currentFrame == 90) {
				zombieBody_mc.gotoAndPlay(30);
			}
		}
		
		public function animateAttacking ():void {
			zombieBody_mc.play();
			if (zombieBody_mc.currentFrame == 151) {
				zombieBody_mc.gotoAndPlay(91);
			}
			
			survivor.Attacked();
		}
		
		public function zombieLifeBar ():void {
			
		}
		
		//Walking Zombie
		public function walking ():void {
			
			//Zombie Legs Animation
			animateWalkingLegs();
			
			//Zombie Body Animation
			animateWalkingBody();
			
			//Zombie Legs Animation
			/*TweenMax.to(zombieLegs_mc, 3,
			{ 
				frame:90, 
				onUpdate:function() 
				{
					if (zombieLegs_mc.currentLabel == "Forward" && walkingBool == true)
					{
						if (direction == "left")
						{
							x += -0.3;
						}
						else if (direction == "right")
						{
							x += 0.3;
						}
					}
				},
				onComplete:function()
				{
					if (walkingBool)
					{
						zombieLegs_mc.gotoAndStop(30);
						walking();
					}
				},
				ease:Linear.easeNone
			});
			
			//Zombie Body and Arm Animation
			TweenMax.to(zombieBody_mc, 3, { 
				frame:90,
				onComplete:function()
				{
					if (walkingBool)
					{
						zombieBody_mc.gotoAndStop(30);
					}
				},
				ease:Linear.easeNone
			});*/
		}
		
		//Stop Zombie
		public function stopWalking ():void {
			walkingBool = false;
			stop();
			zombieLegs_mc.stop();
			zombieBody_mc.stop();
		}
		
		public function playerCollision ():void {
			//Damage the player
			if ( this.hitTestObject(survivor as MovieClip) ) {
				stopWalking();
				if (!attackingBool) {
					zombieBody_mc.gotoAndStop(91);
					attackingBool = true;
				}
				animateAttacking();
			}
			else {
				if (!walkingBool) {
					startWalk();
				}
				else {
					walking();
				}
			}
		}
		
		public function playerCurrentPosition ():void {
			var background = this.parent.getChildByName("background_mc") as MovieClip;
			playerPosition = ((background.width / 2) + Math.abs(this.parent.x)) - (this.width * 2) - (stageWidth / 2);
			
			if (playerPosition < x) {
				direction = 'left';
			}
			else if (playerPosition > x) {
				direction = 'right';
			}
			updateDirection();
		}
	}
}