package mxi.display
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	
	public class FadingSprite extends GreenSprite
	{
		public function fadeIn(duration:uint = 300) : void
		{
			if (visible) return;
			
			var self:* = this,
				timer:Timer = new Timer(Math.round(duration/10), 10);
			
			visible = true;
			timer.addEventListener(TimerEvent.TIMER, function() : void {
				self.alpha += 0.1;
			});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function() : void {
				self.alpha = 1;
				timer.stop();
				timer = null;
			});
			timer.start();
		}
		
		
		public function fadeOut(duration:uint = 300) : void
		{
			if (!visible) return;
			
			var self:* = this,
				timer:Timer = new Timer(Math.round(duration/10), 10);
			
			timer.addEventListener(TimerEvent.TIMER, function() : void {
				self.alpha -= 0.1;
			});
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function() : void {
				self.alpha = 0;
				timer.stop();
				timer = null;
				visible = false;
			});
			timer.start();
		}
		
		
	}
}