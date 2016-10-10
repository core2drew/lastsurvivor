package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import Game;
	
	public class Zombie extends MovieClip 
	{
		public var playerPosition:Number;
		public var survivor:Survivor;
		public var stageWidth:int;
		public var walkingBool:Boolean;
		public var attackingBool:Boolean;
		public var direction:String;
		public var zombieSpeed:Number;
		public var zombieHitpoints:Number;
		
		private var zombieLifeBar_mc:MovieClip;
		private var zombieBody_mc:MovieClip;
		private var zombieLegs_mc:MovieClip;
		private var zombieUpdateDirectionDelay:int;
		private var main:Main;
		
		public function Zombie (main:Main, xLocation:int, yLocation:int, direction:String, survivor:Survivor, stageWidth:int) {
            this.main = main;
			
            x = xLocation;
            y = yLocation;
			
			this.stageWidth = stageWidth;
			this.survivor = survivor;
			this.direction = direction;
			
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
        }
		
		public function init(e:Event = null) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//must be from database data
			zombieSpeed = 10; ;
			zombieHitpoints = 100;
			zombieUpdateDirectionDelay =  4;
			
			stop();
			zombieBody_mc = this.body_mc;
			zombieLegs_mc = this.legs_mc;
			zombieLifeBar_mc = this.lifebar_mc;
			zombieBody_mc.stop();
			zombieLegs_mc.stop();
			updateDirection();
			addEventListener(Event.ENTER_FRAME, loop);	
		}
		
		public function updateDirection ():void {
			if (direction == 'left') {
				zombieLifeBar_mc.rotationY = 0;
				this.rotationY = 0;
			}
			else if (direction == 'right') {
				zombieLifeBar_mc.rotationY = 180;
				this.rotationY = 180;
			}
		}

        public function loop (e:Event):void {
            //the looping code goes here
			//actions e.g (walking, attacking, etc.)
			
			//Game Pause Condition
			if (Game.IsPaused) {
				stopWalking();
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
				//Checker if GamePause is False;
				addEventListener(Event.ENTER_FRAME, pauseCheckerLoop);
			}
			
			playerCollision();
			playerCurrentPosition();
        }
		
		private function pauseCheckerLoop(e:Event):void {
			if (!Game.IsPaused) {
				addEventListener(Event.ENTER_FRAME, loop);
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
			}
		}
		
		public function takeDamage (damage:Number, currentZombieIndex:int):void {
			zombieHitpoints -= damage;
			zombieLifeBar_mc.bar_mc.scaleX = (zombieHitpoints / 100);
			if (zombieHitpoints <= 0) {
				Game.zombieList.splice(currentZombieIndex, 1);
				removeSelf();
			}
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
