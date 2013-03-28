package mxi.ui
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mxi.player.SkinParser;

	public class Component
	{
		public var object:DisplayObject;
		
		public var style:Object;		
		public var xml:XML;
		
		protected var styles:Object;
		protected var actions:Object;
		
		protected var parser:SkinParser;
		
		
		public function Component(el:XML, styles:Object = {}, actions:Object = {})
		{
			this.xml = el;
			this.styles = styles;
			this.actions = actions;
			
			parseAttributes();
		}
		
		
		
		protected function parseAttributes(el:XML) : Object
		{
			var raw:Object, id:String, global:Object, attr:XML;
			
			id = el.@style.toString();
			raw = styles.hasOwnProperty(id) ? styles[id] : {};
				
			
			// get local styles, and override global ones were met
			for each (attr in el.attributes())
				raw[attr.name().toString().toLowerCase()] = attr.toString();	
			
			// every element must have some width/height, if not present, will be set to 100%
			raw['parent_height'] = getDimension(el.parent(), 'height');
			raw['parent_width'] = getDimension(el.parent(), 'width');
			
			raw['width'] = getDimension(el, 'width');
			raw['height'] = getDimension(el, 'height');
			
			setStyles(raw);
			setActions(raw);
		}
		
		
		protected function setStyles(raw:object) : void
		{
			var name:String, value:String;
			
			for (name in raw) 
			{
				value = raw[name];
				switch (name) 
				{	
					case 'left':  
						if (value == 'center')
							style.x = Math.round(raw['parent_width']/2 - raw.width/2); 
						else
							style.x = Number(value);
						break;
					
					case 'right':
						style.x = raw['parent_width'] - Number(value);
						break;
					
					case 'top':					
						if (value == 'middle')
							style.y = Math.round(raw['parent_height']/2 - raw.height/2); 
						else
							style.y = Number(value);
						break;
					
					case 'bottom':
						style.y = raw['parent_height'] - Number(value);
						break;
					
					case 'id':
						style[name] = value;  
						break;
					
					case 'radius':
						style[name] = Number(value);
						break;	
					
					case 'background':	
						var background:String = value;
						if (/^#/.test(background)) 
							style.background = uint(background.replace('#', '0x'));	
						else
							style.background = background.split(' ');
						break;
					
					case 'repeat':
					case 'visible':
						style[name] = (value.toLowerCase() == 'true');
						break;	
					
					case 'width':
					case 'height':
					case 'parent_width':
					case 'parent_height':
						style[name] = value;
						break;
				}
			}		
			
			if (!style.hasOwnProperty('x'))
				style.x = 0;
			
			if (!style.hasOwnProperty('y'))
				style.y = 0;			
		}	
		
		
		protected function setActions(raw:Object) : void
		{
			var name:String, value:String, map:Object;
			
			map = {
				'onclick': MouseEvent.CLICK
			};
			
			for (name in raw) 
			{
				value = raw[name];
				if (name in map) {
					object.addEventListener(map[name], function(event:* = null) : void {
						execute(value, event);
					});
				}
			}
		}
		
		
		protected function execute(value:String, event:* = null) : void
		{
			var todo:Array, matches:Array, i:uint, length:uint;
			
			todo = value.split(/\s*;\s*/);
			length = todo.length;
			for (i = 0; i < length; i++) 
			{
				// trim it and omit if empty
				todo[i] = trim(todo[i]);
				if (todo[i] == '')
					continue;
				
				matches = todo[i].match(/([^\(]+)\(([^\)]*)\)/);
				if (matches) {
					
					switch (matches[1]) {
						
						case 'play':
						case 'pause':
						case 'stop':
							parser.dispatchEvent(ComponentEvent.ACTION, matches[1]);
							break;
						
						case 'volume':
							// if no value specified event target should be a slider, otherwise ignore
							
							
							break;
					
					
					
				}
			}
		}
		
		
		protected function trim(str:String) : String 
		{
			return str.replace(/^\s+/, '').replace(/\s+$/, '');
		}
		
		
	}
}