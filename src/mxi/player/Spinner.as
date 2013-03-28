package mxi.player
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import mxi.display.FadingSprite;

	public class Spinner extends FadingSprite
	{
		public var center:Point;
		
		private var timer:Timer = null;
		
		public function Spinner(center:Point, speed:uint = 50)
		{
			visible = false;
			this.center = center;
			
			timer = new Timer(50);
		}
		
		
		public function show(duration:uint = 0) : void 
		{
			var self:FadingSprite = this,
				matrix:Matrix = self.transform.matrix;
			
			if (!visible) {
				timer = new Timer(50);
				timer.addEventListener(TimerEvent.TIMER, function() : void {						
					rotateAroundCenter(matrix, -30);        
					self.transform.matrix = matrix;
				});
				timer.start();
				fadeIn();
			}
		}
		
		
		public function hide() : void
		{
			if (timer !== null) {
				timer.stop();
				timer = null;
			}
			fadeOut();
		}
		
		
		protected function rotateAroundCenter(matrix:Matrix, angle:int) : void
		{
			matrix.translate(-center.x, -center.y);
			matrix.rotate(angle*(Math.PI/180));
			matrix.translate(center.x, center.y);
		}
	}
}