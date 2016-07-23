package 
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class Survivor extends MovieClip
	{
		
		public var invulnerable:Boolean;
		public var survivor:MovieClip;
		public var mainStage:MovieClip;
		public function Survivor() 
		{
			survivor = this;
			heroBody_mc.stop();
			//Change Weapon Temporary
			heroBody_mc.heroArms_mc.gotoAndStop(1);
			this.name = "survivor";
			this.x = (Main.StageWidth / 2);
			trace(Main.StageWidth);
			this.y = Main.mainStage.scrollingBG_mc.y;
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
			heroBody_mc.gotoAndStop("Idle");
		}
		
		public function Jump ():void {
			heroBody_mc.gotoAndPlay("Jump");
		}
		
		public function Fall ():void {
			heroBody_mc.gotoAndPlay("Fall");
		}
		
		public function loop (e:Event):void {
			if (heroBody_mc.currentFrameLabel === "End") {
				heroBody_mc.gotoAndStop(20);
			}
			
			if (heroBody_mc.currentFrameLabel === "JumpEnd" || heroBody_mc.currentFrameLabel === "FallEnd") {
				heroBody_mc.stop();
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