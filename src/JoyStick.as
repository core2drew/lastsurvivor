package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class JoyStick extends MovieClip {
		private var main:Main;
		private var survivor:Survivor;
		private var scrollBG:ScrollingBackground;
		private var gameControls:GameControls;
		
		private var _knob:MovieClip
		private var isTouch:Boolean;
		private var startX:Number;
		private var startY:Number;
		private var radius:int;
		private var angle:int;
		private var xDirection:int;
		private var direction:String;
		private var speedConstant:int;
		private var xSpeed:int;
		private var leftMoveLimit:Number;
		private var rightMoveLimit:Number;
		private var leftStageMoveLimit:Number;
		private var rightStageMoveLimit:Number;
		private var jumping:Boolean;
		private var falling:Boolean;
		private var stageSpeed:int;
		
		public var scrollX:int;
		public var maxSpeedConstant:Number;
		
		public function JoyStick(main:Main)  {
			this.main = main
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init (e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT; 
			 
			survivor = main.survivor;
			scrollBG = main.scrollBG;
			gameControls = main.gameControls;
			
			hide();
			
			//ScrollBG variable
			speedConstant = 18; //Character Speed (illusion only)
			maxSpeedConstant = speedConstant;
			stageSpeed = speedConstant;
			xSpeed = 0;
			scrollX = 0;
			leftMoveLimit = 0;
			rightMoveLimit = main.stageWidth - scrollBG.width;
			leftStageMoveLimit = 150;
			rightStageMoveLimit = 1800;
			
			//Joystick variable
			_knob = knob
			x = 240;
			y = 875;
			startX = x;
			startY = y;
			radius = 100;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
			stage.addEventListener(MouseEvent.MOUSE_UP, offTouch);
		}
		
		public function moveJoystick ():void {
			jumping = gameControls.jumping;
			falling = gameControls.falling;
			direction = "idle";
			
			if (isTouch) {
				angle = Math.atan2(0, root.mouseX - startX) / (Math.PI / 180);
				rotation = angle;
				_knob.rotation = -angle;
				
				_knob.x = this.mouseX;
				if (_knob.x > radius ) {
					_knob.x = radius;
				}
				
				xDirection = Math.round( Math.cos(angle * (Math.PI / 180)) );
				if (xDirection > 0) {
					direction = "right";
				}
				else if (xDirection < 0) {
					direction = "left";
				}
			}
			else {
				//If the joystick is not being touched, return it to the neutral position
				_knob.x = 0;
			}
			
			switch (direction) 
			{
				case 'left':
					survivor.TurnLeft();
					
					if (scrollX >= leftMoveLimit) {
						if (survivor.x > leftStageMoveLimit) {
							stageSpeed = speedConstant * 1;
							moveSurvivor(stageSpeed);
							survivor.survivorCurrentPositon = "left";
						}
						else {
							survivor.Idle();
						}
					}
					else {
						if(960 >= survivor.x){	
							xSpeed -= speedConstant;
							moveScrollBGX()
							survivor.survivorCurrentPositon = "center";
						}
						else if (960 <= survivor.x){
							stageSpeed = speedConstant * 1;
							moveSurvivor(stageSpeed);
						}
					}
				break;
				
				case 'right':
					survivor.TurnRight();
					
					if (scrollX <= rightMoveLimit) {
						if (survivor.x < rightStageMoveLimit) {
							stageSpeed = speedConstant * -1; 
							moveSurvivor(stageSpeed);
							survivor.survivorCurrentPositon = "right";
						}
						else {
							survivor.Idle();
						}
						
					}
					else {
						if(960 <= survivor.x){
							xSpeed += speedConstant;
							moveScrollBGX();
							survivor.survivorCurrentPositon = "center";
						}
						else if(960 >= survivor.x){
							stageSpeed = speedConstant * -1;
							moveSurvivor(stageSpeed);
						}
					}
				break;
				
				case 'idle':
					if (!jumping && !falling) {
						survivor.Idle();
					}
				break;
				
				default:
			}
		}
		
		public function moveScrollBGX():void {
			if (!jumping && !falling) {
				survivor.Walk();
			}
			
			//Maxspeed
			if (xSpeed < (maxSpeedConstant * -1)) {
				xSpeed = (maxSpeedConstant * -1);
			}
			else if (xSpeed > maxSpeedConstant) {
				xSpeed = maxSpeedConstant;
			}
			//Move ScrollBG
			scrollX -= xSpeed;
			scrollBG.x = scrollX;
		}
		
		public function moveSurvivor(speed):void {
			if (!jumping && !falling) {
				survivor.Walk();
			}
			survivor.x -= speed;
		}
		
		public function onTouch (e:MouseEvent):void  {
			isTouch = true;
		}
		
		public function offTouch (e:MouseEvent):void {
			isTouch = false;
		}
		
		public function show():void {
			visible = true;
			reset();
		}
		
		public function hide():void {
			visible = false;
		}
		
		public function reset():void {
			scrollX = 0;	
		}
	}
}