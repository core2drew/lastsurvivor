package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import Bullet;
	
	public class GameControls extends MovieClip {
		
		private var main:Main;
		private var game:Game;
		private var survivor:Survivor;
		private var joystick:JoyStick;
		private var bullet:Bullet;
		private var scrollBG:ScrollingBackground;
		
		private var scrollX:int;
		private var playerDirection:String;
		private var gravityConstant:int;
		private var jumpConstant:int;
		private var	maxJumpHeight:int;
		
		public var bulletArr:Array;
		public var jumping:Boolean;
		public var falling:Boolean;
		public var ground:int;
		
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
			scrollBG = main.scrollBG;
			survivor = main.survivor;
			joystick = main.joystick
			
			jumping = false;
			falling = false;
			gravityConstant = 20;
			jumpConstant = -27;
			maxJumpHeight = 380;
			ground = scrollBG.y;//This is the ground of the scrollBG
			
			bulletArr = new Array();
			x = 1500;
			y = 960;
			jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);//Add jumping Event
			fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, fireBullet);//Firing Event
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function fireBullet (e:TouchEvent):void {
			if (survivor.scaleX < 0) {
				playerDirection = 'left';
			}
			
			if (survivor.scaleX > 0) {
				playerDirection = 'right';
			}
			
			bullet = new Bullet(main, playerDirection);
			bulletArr.push(bullet);
			scrollBG.addChild(bullet);
		}
		
		private function Jump (e:TouchEvent):void {
			if (survivor.y >= ground) {
				jumping = true;
				survivor.Jump();
			}
		}
		
		private function loop(e:Event):void {
			//jumping Condition
			if (jumping) {
				if (survivor.y > maxJumpHeight) {
					survivor.y += jumpConstant;
					joystick.maxSpeedConstant = 17;
				}
				else {
					falling = true;
					jumping = false;
					
				}
			}
			
			//falling Condition
			if (falling) {
				if (survivor.y < ground - 30) {
					survivor.y += gravityConstant;
					survivor.Fall();
				}
				else {
					falling = false;
					jumping = false;
					survivor.y = ground
					joystick.maxSpeedConstant = 12;
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
