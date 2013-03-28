package mxi.ui
{
	import flash.events.Event;

	public class ComponentEvent extends Event
	{	
		public var action:String;
		public var params:*;
		
		public static const ACTION:String = 'componentaction';
		
		public function ComponentEvent(type:String, action:String, params:* = null)
		{
			this.action = action;
			this.params = params;
			
			super(type, false, false);
		}
	}
}