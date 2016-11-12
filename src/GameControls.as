package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import Bullet;
	
	public class GameControls extends MovieClip {
		
		private var main:Main;
		private var game:Game;
		private var survivor:Survivor;
		private var joystick:JoyStick;
		public var bullet:Bullet;
		private var scrollBG:ScrollingBackground;
		
		private var scrollX:int;
		private var playerDirection:String;
		private var gravityConstant:int;
		private var jumpConstant:int;
		private var	maxJumpHeight:int;
		
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
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			hide();
			game = main.game;
			scrollBG = main.scrollBG;
			survivor = main.survivor;
			joystick = main.joystick
			
			jumping = false;
			falling = false;
			gravityConstant = 23;
			jumpConstant = -23;
			maxJumpHeight = 600;
			ground = 950;//This is the ground of the scrollBG
						
			x = 1600;
			y = 920;
			jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);//Add jumping Event
			fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, fireBullet);//Firing Event
			
			//addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function fireBullet (e:TouchEvent):void {
			if (survivor.scaleX < 0) {
				playerDirection = 'left';
			}
			
			if (survivor.scaleX > 0) {
				playerDirection = 'right';
			}
			
			bullet = new Bullet(main, playerDirection);
			scrollBG.addChild(bullet);
			game.bulletArr.push(bullet);
		}
		
		private function Jump (e:TouchEvent):void {
			if (survivor.y >= ground) {
				jumping = true;
				survivor.Jump();
			}
		}
		
		public function actions():void {
			//jumping Condition
			if (jumping) {
				if (survivor.y > maxJumpHeight) {
					survivor.y += jumpConstant;
					joystick.maxSpeedConstant = 17;
				}
				else {
					falling = true;
					jumping = false;
					survivor.Fall();
				}
			}
			//falling Condition
			else if (falling) {
				if (survivor.y < ground - 30) {
					survivor.y += gravityConstant;
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
			reset();
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function pause():void {
			survivor.pause();
		}
		
		public function resume() {
			survivor.resume();
			//addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function reset():void {
			//removeEventListener(Event.ENTER_FRAME, loop);
			falling = false;
			jumping = false;
			
			survivor.resume();
			//addEventListener(Event.ENTER_FRAME, loop);
		}
	}
}
