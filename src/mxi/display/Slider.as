package mxi.display
{	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mxi.events.SliderEvent;
	
	public class Slider extends GreenSprite
	{
		public var bar:GreenSprite;
		public var handle:GreenSprite;
		
		private var bounds:Rectangle;
		
		private var _value:uint = 0;
		
		
		public function get value() : uint 
		{
			_value = Math.ceil(handle.x / bar.width * 100);
			if (_value > 100) {	
				_value = 100;
			}
			return _value;			
		}
		
		public function set value(num:uint) : void 
		{
			if (num < 0) {
				num = 0;
			} else if (num > 100) {
				num = 100;
			}
			_value = num;
			handle.x = Math.ceil(num / 100 * bar.width);
			dispatchEvent(new SliderEvent(SliderEvent.CHANGE, num));
		}
		
		
		public function Slider()
		{
			bar = new GreenSprite;
			handle = new GreenSprite;
			
			this.addEventListener(Event.ADDED_TO_STAGE, initialize);			
		}
		
		
		private function initialize(... args) : void 
		{		
			var barX:uint, barY:uint, handleX:uint, handleY:uint;
			
			barX = Math.ceil(handle.width/2);
			barY = bar.height < handle.height ? Math.ceil((handle.height - bar.height)/2) : 0;
			
			handleX = 0;
			handleY = bar.height > handle.height ? Math.ceil((bar.height - handle.height)/2) : 0;
			
			bounds = new Rectangle(0, handleY, bar.width - (handle.width - barX), handleY);
					
			bar.buttonMode = true;
			bar.x = barX;
			bar.y = barY;
			
			bar.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) : void {
				value = Math.ceil(event.localX / bar.width * 100);
			});
			
			handle.buttonMode = true;
			handle.x = handleX;
			handle.y = handleY;
						
			handle.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			handle.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			stage.addEventListener(Event.MOUSE_LEAVE, stopDragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			
			if (_value) {
				value = _value;
			}
			
			this.addChild(bar);
			this.addChild(handle);
		}
		
		
		public function destroy() : void
		{
			stopDragging();
			
			stage.removeEventListener(Event.MOUSE_LEAVE, stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			
			bar.removeAllEvents();
			handle.removeAllEvents();			
			this.removeAllEvents();
		}	
		
		
		private function startDragging(... args) : void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchSlide);
			
			dispatchEvent(new SliderEvent(SliderEvent.START, value));
			handle.startDrag(false, bounds);
		}
		
		
		private function stopDragging(... args) : void
		{			
			handle.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchSlide);
			
			dispatchEvent(new SliderEvent(SliderEvent.STOP, value));
		}
		
		
		private function dispatchSlide(... args) : void
		{
			dispatchEvent(new SliderEvent(SliderEvent.SLIDE, value));
		}
		
	}
}