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
		private var touchXPos:Number;
		private var touchYPos:Number;
		private var radius:int;
		private var angle:int;
		
		public function JoyStick()  {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init (e:Event):void {
			_knob = this.knob
			this.x = 250;
			this.y = 770;
			startX = this.x;
			startY = this.y;
			radius = 100;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_END, offTouch);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, moveTouch);
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function enterFrame (e:Event):void {
			if (isTouch) {
				angle = Math.atan2(touchYPos - startY, touchXPos - startX) / (Math.PI / 180);
				this.rotation = angle;
				_knob.rotation = -angle;
				
				_knob.x = touchXPos;
				if (_knob.x > radius ) {
					_knob.x = radius;
				}
			}
			else {
				//If the joystick is not being touched, return it to the neutral position
				_knob.x = 0;
			}
		}
		
		public function onTouch (e:TouchEvent):void  {
			isTouch = true;
		}
		
		public function offTouch (e:TouchEvent):void {
			isTouch = false;
		}
		
		public function moveTouch (e:TouchEvent):void {
			touchXPos = e.stageX;
			touchYPos = e.stageY;
		}
	}
}