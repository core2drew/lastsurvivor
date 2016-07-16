package 
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Survivor extends MovieClip
	{
		
		public var invulnerable:Boolean;
		public var survivor:MovieClip;
		
		public function Survivor() 
		{
			survivor = this;
			heroBody_mc.stop();
			this.name = "survivor";
			this.x = 960;
			this.y = 911;
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function TurnRight():void
		{
			this.scaleX = 1;
		}
		
		public function TurnLeft():void
		{
			this.scaleX = -1;
		}
		
		public function Walk ():void {
			heroBody_mc.play();
		}
		
		public function Idle ():void {
			heroBody_mc.gotoAndStop(2);
		}
		
		public function loop (e:Event):void {
			if (heroBody_mc.currentFrameLabel === "End") {
				heroBody_mc.gotoAndStop(20);
			}
		}
		
		public function Attacked ():void {
			//Invulnerable for 5secs
			if (!invulnerable) {
				invulnerable = true;
				TweenMax.fromTo(survivor, .5, { alpha:1 }, { alpha:0, repeat:5, ease:Linear.easeNone , onComplete:function() {
					invulnerable = false;
					survivor.alpha = 1;
				} });
			}
		}
	}
}