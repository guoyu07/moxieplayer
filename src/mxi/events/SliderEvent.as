package mxi.events
{
	import flash.events.Event;
	
	public class SliderEvent extends Event
	{
		public static const START:String = 'slidestart';
		public static const SLIDE:String = 'slidehappens';
		public static const CHANGE:String = 'slidechanged';
		public static const STOP:String = 'slidestopped';
		
		public var data:Number;
		
		public function SliderEvent(type:String, data:Number = 0)
		{
			this.data = data;
			super(type, false, false);
		}
	}
}