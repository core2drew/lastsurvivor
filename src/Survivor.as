package 
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import CharacterStat;
	
	public class Survivor extends MovieClip
	{
		
		public var invulnerable:Boolean;
		public var survivor:MovieClip;
		public var mainStage:MovieClip;
		private var characterStat:CharacterStat;
				
		public function Survivor() 
		{
			survivor = this;
			heroBody_mc.stop();
			
			//Change Weapon Temporary
			heroBody_mc.heroArms_mc.gotoAndStop(1);
			
			mainStage = Main.mainStage;
			
			this.name = "survivor";
			this.x = (Main.StageWidth / 2);
			this.y = mainStage.scrollingBG_mc.y;
			
			characterStat = new CharacterStat();
			addCharacterStat();
			
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
			this.scaleX = 1;
		}
		
		public function TurnLeft():void
		{
			this.scaleX = -1;
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
		
		public function addCharacterStat ():void {
			mainStage.addChild(characterStat);
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
				invulnerable = true;
				characterStat.takeDamage(10);
				TweenMax.fromTo(survivor, .5, { alpha:1 }, { alpha:0, repeat:5, ease:Linear.easeNone , onComplete:function() {
					invulnerable = false;
					survivor.alpha = 1;
				} });
			}
		}
	}
}