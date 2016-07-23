package 
{
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.Timer;
	import Game;
	import JoyStick;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Controller extends MovieClip 
 	{
		private var mainStage:MovieClip;
		private var speedConstant:Number;
		private var maxSpeedConstant:Number;
		private var LeftMoveLimit:Number;
		private var RightMoveLimit:Number;
		private var MovingLeft:Boolean;
		private var MovingRight:Boolean;
		private var Jumping:Boolean;
		private var Falling:Boolean;
		private var scrollingBG:MovieClip;
		private var survivor:Survivor;
		private var bullet:Bullet;
		private var playerDirection:String;
		private var xSpeed:int;
		private var scrollX:int;
		private var gravityConstant:Number;
		private var jumpConstant:Number;
		private var maxJumpHeight:int;
		private var ground:int;
		private var fireBulletDelay:Timer;
		
		public function Controller (_mainStage:MovieClip, _survivor:Survivor) {
			speedConstant = 10;
			maxSpeedConstant = 10
			xSpeed = 0;
			scrollX = 0;
			gravityConstant = 15;
			jumpConstant = -25;
			maxJumpHeight = 445;
			ground = Main.mainStage.scrollingBG_mc.y; //This is the ground of the scrollBG
			fireBulletDelay = new Timer(800, 1);//Delay must be get from the database (gun delay column)
			LeftMoveLimit = 0;
			RightMoveLimit = -2745;
			MovingLeft = false;
			MovingRight = false;
			mainStage = _mainStage;
			scrollingBG = mainStage.scrollingBG_mc;
			survivor = _survivor;
			
			//Jumping
			mainStage.jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);

			//Initial Fire
			fireBulletDelay.start();
			//Delay to Fire again a bullet
			fireBulletDelay.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent) { 
				//Firing
				mainStage.fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, fireBullet);
			} );
			
			addEventListener(Event.ENTER_FRAME, Loop);
		}
		
		private function fireBullet (e:TouchEvent) {
			if (survivor.scaleX < 0)
			{
				playerDirection = 'left';
			}
			else if (survivor.scaleX > 0)
			{
				playerDirection = 'right';
			}
			bullet = new Bullet(survivor.x - scrollX, survivor.y - ground, survivor, playerDirection);
			scrollingBG.addChild(bullet);
			
			//Remove Firing Bullet Event
			mainStage.fire_btn.removeEventListener(TouchEvent.TOUCH_BEGIN, arguments.callee);
			
			//Wait for 1 sec to fire again a bullet
			fireBulletDelay.start();
		}
		
		public function Jump(e:TouchEvent)
		{
			if (survivor.y >= ground)
			{
				Jumping = true;
				survivor.Jump();
			}
		}
		
		public function Fall():void {
			Falling = true;
			Jumping = false;
			
			if (Falling) {
				survivor.Fall();
			}
		}
		
		public function StopMoving(e:TouchEvent)
		{
			MovingLeft = false;
			MovingRight = false;
			survivor.Idle();
		}
		
		public function Loop(e:Event):void
		{
			//Player Movement
			/*if (MovingLeft)
			{
				
				if (scrollX >= LeftMoveLimit)
				{
					trace("MovingLeft False");
					MovingLeft = false;
					survivor.Idle();
				}
				else
				{
					trace("MovingLeft True");
					xSpeed -= speedConstant;
					if (!Jumping && !Falling)
					{
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}
			else if (MovingRight)
			{
				if (scrollX <= RightMoveLimit)
				{
					MovingRight = false;
					survivor.Idle();
				}
				else
				{
					xSpeed += speedConstant;
					if (!Jumping && !Falling)
					{
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}*/
			
			//JoyStick Pad Condition
			if (JoyStick.direction === "left")
			{
				MovingLeft = true;
				survivor.TurnLeft();
				if (scrollX >= LeftMoveLimit)
				{
					MovingLeft = false;
					survivor.Idle();
				}
				else
				{
					xSpeed -= speedConstant;
					if (!Jumping && !Falling)
					{
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}
			else if (JoyStick.direction === "right")
			{
				MovingRight = true;
				survivor.TurnRight();
				if (scrollX <= RightMoveLimit)
				{
					MovingRight = false;
					survivor.Idle();
				}
				else
				{
					xSpeed += speedConstant;
					if (!Jumping && !Falling)
					{
						survivor.Walk();
					}
					moveScrollBGX()
				}
			}
			else if (JoyStick.direction === "idle")
			{
				survivor.Idle();
			}
			
			//Jumping Condition
			if (Jumping)
			{
				if (survivor.y > maxJumpHeight)
				{
					survivor.y += jumpConstant;
				}
				else
				{
					Fall();
				}
			}
			else if (Falling)
			{
				if (survivor.y < ground)
				{
					survivor.y += gravityConstant;
				}
				else
				{
					Jumping = false;
					Falling = false;
					survivor.Idle();
				}
			}
		}
		
		public function moveScrollBGX() {
			//Maxspeed
			if (xSpeed < (maxSpeedConstant * -1))
			{
				xSpeed = (maxSpeedConstant * -1);
			}
			else if (xSpeed > maxSpeedConstant)
			{
				xSpeed = maxSpeedConstant;
			}
			//Move Scroll
			scrollX -= xSpeed;
			scrollingBG.x = scrollX;
		}
	}
}