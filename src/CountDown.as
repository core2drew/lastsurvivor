package  {
	import flash.display.MovieClip;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
	
    public class CountDown extends MovieClip {
 
        private var secondsRemaining:int;
        private var _timeRemaining:Object = {}
        private var countdownTimer:Timer;
        //INFO//
 
       /* This countdown does all the math to calculate how many days/hours/minutes/seconds are left in a specific countdown.
            * You can countdown to a specified date in time or for a specific amount of seconds
            * Create a new instance of countdown
            * Set the target seconds or target date
            * Add a listener for Event.CHANGE (each second update) and Event.COMPLETE (when timer is up)
            * On each update, get the object "timeRemaining" from the clock. This will return an object with the days, hours, minutes, seconds left
            * Use this info however you want <img draggable="false" class="emoji" alt="🙂" src="https://s.w.org/images/core/emoji/2/svg/1f642.svg">
 */
        /*EXAMPLE:
 
        private function init(evt:Event):void
        {
            cdc = new CountDown();
                //cdc.TARGET_SECONDS = 120; //Use this if you want to countdown to a specific # of seconds
            cdc.TARGET_DATE = new Date(2013, 11, 7);
            cdc.START();
            cdc.addEventListener(Event.CHANGE, onUpdate);
            cdc.addEventListener(Event.COMPLETE, onComplete)
        }
 
        private function onUpdate(evt:Event):void
        {
            var timeRemaining:Object = cdc.timeRemaining;
            trace("hours:", timeRemaining.hours, "minutes:", timeRemaining.minutes, "seconds:", timeRemaining.seconds);
        }
 
        private function onComplete(evt:Event):void
        {
            trace ("Times up!");
        }*/
 
        public function CountDown() {
			x = 960;
			y = 130;
			hide();
            countdownTimer = new Timer(1000);
            countdownTimer.addEventListener(TimerEvent.TIMER, onCountdown);
        }
 
        public function set TARGET_SECONDS(seconds:int):void
        {
            secondsRemaining = seconds;
        }
 
        public function set TARGET_DATE(target:Date):void
        {
            var currentDate:Date = new Date();
            var currentSeconds = currentDate.valueOf();
 
            var targetSeconds = target.valueOf();
 
            var difference:int = (targetSeconds - currentSeconds) / 1000;
            secondsRemaining = difference;
        }
 
        public function START():void
        {
            countdownTimer.start();
        }
 
        public function STOP():void
        {
            countdownTimer.stop();
        }
 
        private function onCountdown(evt:TimerEvent):void
        {
            secondsRemaining--;
            var minutes:int = Math.floor((secondsRemaining / 60) % 60);
            var seconds:int = secondsRemaining%60;
            timeRemaining.minutes = minutes;
            timeRemaining.seconds = seconds;
            if(secondsRemaining < 0)
            {
                dispatchEvent(new Event(Event.COMPLETE, true));
                countdownTimer.stop();
                countdownTimer.removeEventListener(TimerEvent.TIMER, onCountdown);
            }
            else
            {
                dispatchEvent(new Event(Event.CHANGE, true));
            }
        }
        public function get timeRemaining():Object
        {
            return _timeRemaining;
        }
		
		public function hide():void {
			visible = false;
		}
		
		public function show():void {
			visible = true;
		}
    }
}