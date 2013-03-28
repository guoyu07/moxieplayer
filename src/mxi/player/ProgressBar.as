package mxi.player
{
	import flash.display.Sprite;

	public class ProgressBar extends Sprite
	{
		public var progress:Sprite;
		public var buffer:Sprite;
		
		public function ProgressBar()
		{
			progress = new Sprite;
			progress.buttonMode = true;
			
			buffer = new Sprite;
			buffer.buttonMode = true;			
			
			addChild(buffer);
			addChild(progress); 
		}
	}
}