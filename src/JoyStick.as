package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class JoyStick extends MovieClip {
		private var _knob:MovieClip
		private var isTouch:Boolean;
		private var startX:Number;
		private var startY:Number;
		private var radius:int;
		private var angle:int;
		private var xDirection:int;
		public var direction:String;
		
		public function JoyStick()  {
			if (stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public function init (e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			hide();
			_knob = knob
			x = 240;
			y = 875;
			startX = x;
			startY = y;
			radius = 100;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
			stage.addEventListener(MouseEvent.MOUSE_UP, offTouch);
		}
		
		public function enterFrame (e:Event):void {
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
		}
		
		public function onTouch (e:MouseEvent):void  {
			isTouch = true;
		}
		
		public function offTouch (e:MouseEvent):void {
			isTouch = false;
		}
		
		public function show() {
			visible = true;
		}
		
		public function hide() {
			visible = false;
		}
	}
}