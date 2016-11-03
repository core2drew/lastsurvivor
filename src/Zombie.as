package  {
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import Game;
	import Helper;
	
	public class Zombie extends MovieClip 
	{
		public var survivorPosition:Number;
		public var survivor:Survivor;
		public var stageWidth:int;
		public var walkingBool:Boolean;
		public var attackingBool:Boolean;
		public var direction:String;
		public var zombieSpeed:Number;
		public var zombieHitpoints:Number;
		private var zombieHitTest:MovieClip;
		private var zombieLifeBar_mc:MovieClip;
		private var zombieBody_mc:MovieClip;
		private var zombieLegs_mc:MovieClip;
		private var zombieUpdateDirectionDelay:int;
		private var currentZombieIndex:int;
		private var minWalkDistance:int 
		private var maxWalkDistance:int;
		private var randomWalkTimer:Timer;
		private var randomWalk_x:int;
		private var survivorHitTest:MovieClip;
		
		private var main:Main;
		private var game:Game;
		
		public function Zombie (main:Main, xLocation:int, yLocation:int, direction:String, survivor:Survivor, stageWidth:int) {
            this.main = main;
			game = main.game;
			
            x = xLocation;
            y = yLocation;
			zombieHitTest = this.body_mc.hitTest;
			this.stageWidth = stageWidth;
			this.survivor = survivor;
			this.direction = direction;
			survivorHitTest = survivor.heroBody_mc.hitTest;
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
			zombieSpeed = 5;
			zombieHitpoints = 100;
			zombieUpdateDirectionDelay =  4;
			
			stop();
			zombieBody_mc = this.body_mc;
			zombieLegs_mc = this.legs_mc;
			zombieLifeBar_mc = this.lifebar_mc;
			zombieBody_mc.stop();
			zombieLegs_mc.stop();
			updateDirection();
			
			randomWalkTimer = new Timer(5000, 1);
			randomWalkTimer.addEventListener(TimerEvent.TIMER, getRandomWalk);
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

        public function locateSurvivor ():void {
            //the looping code goes here
			//actions e.g (walking, attacking, etc.)
			survivorCollision();
			getsurvivorCurrentPosition();
        }
		
		public function takeDamage (damage:Number, currentZombieIndex:int):void {
			zombieHitpoints -= damage;
			zombieLifeBar_mc.bar_mc.scaleX = (zombieHitpoints / 100);
			if (zombieHitpoints <= 0) {
				game.zombieArr.splice(currentZombieIndex, 1);
				removeSelf();
			}
		}
		
		//Remove Zombie
        public function removeSelf ():void {
            pause();
            this.parent.removeChild(this); //tell this object's "parent object" to remove this object
        }
		
		//Ready To Walk
		public function startWalk ():void {
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
			
			if (zombieBody_mc.currentFrame == 110) {
				survivor.attacked();	
			}
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
		
		public function survivorCollision ():void {
			//Damage the player
			if (zombieHitTest.hitTestObject(survivorHitTest)) {
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
		
		public function getsurvivorCurrentPosition ():void {
			if (survivor.survivorCurrentPositon === "center") {
				survivorPosition = (Math.abs(this.parent.x) + main.stageWidth) - main.stageWidth / 2;
				if (survivorPosition < x) {
					direction = 'left';
				}
				else {
					direction = 'right';
				}
			}
			else if (survivor.survivorCurrentPositon === "left" || survivor.survivorCurrentPositon === "right") {
				survivorPosition = survivor.x + Math.abs(this.parent.x);
				if (survivorPosition < x) {
					direction = 'left';
				}else {
					direction = 'right';
				}
				
			}
			updateDirection();
		}
		
		public function pause():void {
			stopWalking();
		}
		
		public function randomWalk():void {
			randomWalkTimer.start();
			minWalkDistance = Math.abs(this.parent.x) + (this.width / 2);
			maxWalkDistance = (minWalkDistance + stageWidth) - this.width;
			
			if (randomWalk_x > x) {
				direction = 'right';
				walking();
			}
			else if (randomWalk_x < x) {
				direction = 'left';
				walking();
			}
			else if (randomWalk_x == x) {
				stopWalking();
			}
			updateDirection();
		}
		
		private function getRandomWalk(e:TimerEvent):void {
			randomWalk_x = Helper.randomRange(minWalkDistance, maxWalkDistance);
		}
		
		public function show():void {
			visible = true;
		}
		
		public function hide():void {
			visible = false;
		}
	}
}
