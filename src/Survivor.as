package 
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import SurvivorStat;
	
	public class Survivor extends MovieClip
	{
		
		public var invulnerable:Boolean;
		public var survivor:MovieClip;
		public var mainStage:MovieClip;
		public var survivorStat:SurvivorStat;
		private var main:Main;
				
		public function Survivor(main:Main) 
		{
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
			mainStage = main.mainStage;
			this.survivorStat = main.survivorStat;
			
			heroBody_mc.stop();
			heroBody_mc.heroArms_mc.gotoAndStop(1);//Change Weapon Temporary
			
			name = "survivor";
			x = (main.stageWidth / 2);
			y = main.scrollBG.y;
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function loop (e:Event):void {
			//Game Pause Condition
			if (Game.IsPaused) {
				heroBody_mc.stop();
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
				//Checker if GamePause is False;
				addEventListener(Event.ADDED_TO_STAGE, pauseCheckerLoop);
			}
			
			if (heroBody_mc.currentFrameLabel === "End") {
				heroBody_mc.gotoAndStop(20);
			}
			
			if (heroBody_mc.currentFrameLabel === "JumpEnd" || heroBody_mc.currentFrameLabel === "FallEnd") {
				heroBody_mc.stop();
			}
		}
		
		
		public function TurnRight():void
		{
			scaleX = 1;
		}
		
		public function TurnLeft():void
		{
			scaleX = -1;
		}
		
		public function Walk ():void {
			if (heroBody_mc.currentFrameLabel === "WalkEnd") {
				heroBody_mc.gotoAndPlay("WalkLoop");
			}
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
		
		private function pauseCheckerLoop(e:Event):void {
			if (!Game.IsPaused) {
				heroBody_mc.play();
				addEventListener(Event.ENTER_FRAME, loop);
				removeEventListener(Event.ENTER_FRAME, arguments.callee);
			}
		}
		
		public function Attacked ():void {
			//Invulnerable for 5secs
			if (!invulnerable) {
				//invulnerable = true;
				survivorStat.takeDamage(10);//Temporary zombie damage
				TweenMax.fromTo(this, .5, { alpha:1 }, { alpha:0, repeat:5, ease:Linear.easeNone , onComplete:function() {
					//invulnerable = false;
					alpha = 1;
				} });
			}
		}
		
		public function show() {
			visible = true;
		}
		
		public function hide() {
			visible = false;
		}
	}
}