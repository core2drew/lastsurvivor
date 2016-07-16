package 
{
	import flash.display.Stage;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.TextField;
	import Game;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Controller extends MovieClip 
 	{
		private var speedConstant = 10;
		private var maxSpeedConstant = 10;
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
		private var xSpeed:int = 0;
		private	var ySpeed:Number = 0;
		private var scrollX:int = 0;
		private var gravityConstant:Number = 15;
		private var jumpConstant:Number = -25;
		private var maxJumpHeight:int = 600;
		private var ground:int = 907; //This is the ground of the stage
		private var leftBumping:Boolean = false;
		private var rightBumping:Boolean = false;
		private var downBumping:Boolean = false;
		
		public function Controller (mainStage:MovieClip,survivor:Survivor) {
			LeftMoveLimit = -0;
			RightMoveLimit = -2745;
			MovingLeft = false;
			MovingRight = false;
			
			scrollingBG = mainStage.scrollingBG_mc;
			this.survivor = survivor;
			
			//Movements
			mainStage.left_btn.addEventListener(TouchEvent.TOUCH_BEGIN, MoveLeft);
			mainStage.left_btn.addEventListener(TouchEvent.TOUCH_END,StopMoving);
			
			mainStage.right_btn.addEventListener(TouchEvent.TOUCH_BEGIN, MoveRight);
			mainStage.right_btn.addEventListener(TouchEvent.TOUCH_END, StopMoving);
			
			//Jumping
			mainStage.jump_btn.addEventListener(TouchEvent.TOUCH_BEGIN, Jump);
			
			
			//Firing
			mainStage.fire_btn.addEventListener(TouchEvent.TOUCH_BEGIN, function(e:TouchEvent) { 
				if (survivor.scaleX < 0)
				{
					playerDirection = 'left';
				}
				else if (survivor.scaleX > 0)
				{
					playerDirection = 'right';
				}
				bullet = new Bullet(survivor.x - scrollX, survivor.y - ground, playerDirection);
				scrollingBG.addChild(bullet);
			});
			
			addEventListener(Event.ENTER_FRAME, Loop);
		}
		
		public function MoveLeft(e:TouchEvent):void
		{
			MovingLeft = true;
			survivor.TurnLeft();
		}
		
		public function MoveRight(e:TouchEvent):void
		{
			MovingRight = true;
			survivor.TurnRight();
		}
		
		public function Jump(e:TouchEvent)
		{
			if (survivor.y >= ground)
			{
				Jumping = true;
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
			if (MovingLeft)
			{
				if (scrollX >= LeftMoveLimit)
				{
					MovingLeft = false;
					survivor.Idle();
					return
				}
				else
				{
					xSpeed -= speedConstant;
					survivor.Walk();
				}
			}
			else if (MovingRight)
			{
				if (scrollX <= RightMoveLimit)
				{
					MovingRight = false;
					survivor.Idle();
					return
				}
				else
				{
					xSpeed += speedConstant;
					survivor.Walk();
				}
			}
			
			
			if (Jumping)
			{
				if (survivor.y > maxJumpHeight)
				{
					survivor.y += jumpConstant;
				}
				else
				{
					Falling = true;
					Jumping = false;
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
				}
			}
			
			
			//Maxspeed
			if (xSpeed < (maxSpeedConstant * -1))
			{
				xSpeed = (maxSpeedConstant * -1);
			}
			else if (xSpeed > maxSpeedConstant)
			{
				xSpeed = maxSpeedConstant;
			}
			
			if (MovingLeft || MovingRight)
			{
				scrollX -= xSpeed;
				scrollingBG.x = scrollX;
				trace("Scroll X: " + scrollX);
				trace("xSpeed: " + xSpeed);
			}
		}
	}
}