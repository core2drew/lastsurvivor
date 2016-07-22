package {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Controller;
	import Survivor;
	import Zombie;
	import Main;
	
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Game extends MovieClip {
		
		public static var zombieList:Array = new Array();
		public static var InGame:Boolean;
		public var mainStage:MovieClip;
		public var joystick:JoyStick;
		public var survivor:Survivor;
		public var controller:Controller;
		public var stageWidth:int;
		public var scrollBGWidth:Number;
		public var zombieSpawnTimer:Timer;

		public function Game () {
			mainStage = Main.mainStage;
			stageWidth = Main.STAGE.stageWidth;
			InGame = false;
		}
		
		//InGame functions
		//Call this when click start
		public function GameInit ():void {
			mainStage.gotoAndStop(3);
			zombieSpawnTimer = new Timer(5000, 1);
			zombieSpawnTimer.addEventListener(TimerEvent.TIMER, spawnZombie);
			joystick = new JoyStick();
			survivor = new Survivor();
			controller = new Controller(mainStage, survivor);
			spawnSurvivor();//Add Survivor to Stage;
			scrollBGWidth = mainStage.scrollingBG_mc.width;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//Adding Joystick to MainStage
			mainStage.addChild(joystick);
		}
		
		public function enterFrame (e:Event):void {
			if (zombieList.length <= 2) {
				zombieSpawnTimer.start();
			}
		}
		
		public function spawnSurvivor ():void {
			mainStage.addChild(survivor);
		}
		
		public function spawnZombie (e:TimerEvent):void {
			var zombie:Zombie
			var xLocation:int;
			var direction:String;
			var zombieWidth:Number = 212.85;
			var spawnPointX = (Math.floor(Math.random() * (1 - 0 + 1)) + 0);//If 0 Spawn Zombie Left, Else Right
			
			if (spawnPointX) {
				xLocation = -1 * (zombieWidth / 2);
				direction = "right";
			}
			else {
				xLocation = scrollBGWidth + (zombieWidth / 2);
				direction = "left";
			}
			
			zombie = new Zombie(xLocation, 0, direction , survivor, stageWidth);//Creating new Zombie Obj
			mainStage.scrollingBG_mc.addChild(zombie);
			zombieList.push(zombie);
		}

		public function PauseGame ():void {
			//Here Stop All Survivor Bullets, Zombie Moving
		}
	}
}