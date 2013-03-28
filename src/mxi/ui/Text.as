package mxi.ui
{
	import flash.text.TextField;

	public class Text extends Component
	{
		public var object:TextField;
		
		
		
		public function Text(xml:XMl)
		{
		}
		
		protected function setStyles(raw:Object) : void
		{
			var name:String, value:String;
			
			for (name in raw) 
			{
				value = raw[name];
				switch (name) 
				{	
					case 'font':
						style[name] = value;  
						break;
					
					case 'size':
						style[name] = Number(value);
						break;	
					
					case 'color':
						style[name] = uint(value.replace('#', '0x'));
						break;
					
					case 'bold':
					case 'selectable':
						style[name] = (value.toLowerCase() == 'true');
						break;	
					
					case 'align':
						var allowed:Array = ['left', 'right', 'center', 'justify'];
						
						if (allowed.indexOf(value.toLowerCase()) === -1)
							value = 'left';
						
						style[name] = TextFormatAlign[value.toLocaleUpperCase()];
						break;
				}
			}		
					
			super.normalizeStyles(raw);
		}
		
	}
}