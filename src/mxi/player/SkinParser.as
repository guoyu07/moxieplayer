package mxi.player
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	import mxi.display.FadingSprite;
	import mxi.display.Slider;
	
	public class SkinParser extends EventDispatcher
	{
		private var sprite:Bitmap;
		private var xml:XML;
		private var modeXml:XML;
		
		private var maxWidth:Number;
		private var maxHeight:Number;
		private var actions:Object;
		
		public function SkinParser(sprite:Bitmap, xml:XML)
		{
			this.sprite = sprite;
			this.xml = xml;	
		}
		
		
		public function get(name:String) : *
		{
			return actions.hasOwnProperty(name) ? actions[name] : null;
		}
		
		
		public function draw(obj:*, mode:String = 'normal', width:Number = 0, height:Number = 0) : void
		{
			var child:*;
			
			/* this one makes sure that control panel and all it's contents fade in/out synchronously */
			obj.blendMode = BlendMode.LAYER;
			
			maxWidth = width;
			maxHeight = height;
			
			actions = {};
			
			modeXml = xml.mode.(@id == mode)[0];
			
			for each (var el:XML in modeXml.elements()) {
				if (el.name().toString().toLowerCase() != 'style') {
					child = drawElement(el);
					if (child !== false)
						obj.addChild(child);	
				}
			}		
		}
		
		
		public function redoBackground(attr:String, style:Object = null) : void
		{
			var action:XMLList = modeXml.descendants().(attribute('action') == attr);
			
			if (action.length()) {
				style = extend(getStyles(action[0]), style);
				doBackground(actions[attr], style);
			}
		}
		
		
		private function drawElement(el:XML) : *
		{
			var nodeName:String,
			action:XML,
			child:*,
			style:Object;
			
			action = el.@action[0];
			nodeName = el.name().toString().toLowerCase();
			
			if (drawMethodExists(nodeName+'Draw'))
			{
				child = this[nodeName+'Draw'](el);
				
				if (action && action.length())
					actions[action.toString().toLowerCase()] = child;
				
				return child;
			}	
			return false;
		}
		
		
		private function drawMethodExists(methodName:String) : Boolean
		{
			var exists:Boolean;
			try {
				exists = this[methodName] != null;
			} catch (e:Error) {
				exists = false;
			} 
			return exists;
		}
		
		
		private function spinnerDraw(el:XML) : Spinner
		{
			var style:Object, spinner:Spinner, center:Point;
			
			style = extend({ speed: 50 }, getStyles(el));
					
			center = new Point(Math.round(style.x + style.width/2), Math.round(style.y + style.height/2));
			spinner = new Spinner(center, style.speed);
			doBackground(spinner, style);
						
			spinner.x = style.x;
			spinner.y = style.y;
			return spinner;
		}
		
		
		private function groupDraw(el:XML) : FadingSprite
		{
			var group:FadingSprite = new FadingSprite,
				style:Object = getStyles(el),
				child:*;
			
			if (style.background)
				doBackground(group, style);
			
			for each (var subEl:XML in el.elements()) {
				if (subEl.name().toString().toLowerCase() != 'style') {
					child = drawElement(subEl);
					if (child !== false)
						group.addChild(child);	
				}
			}
			
			group.x = style.x;
			group.y = style.y;
			
			return group;
		}
		
		
		private function buttonDraw(el:XML) : SimpleButton
		{
			var button:SimpleButton = new SimpleButton,
				style:Object = getStyles(el);
			
			button.upState = getState('up', style, el);
			button.overState = getState('over', style, el);
			button.downState = getState('down', style, el);
			button.hitTestState = getState('hittest', style, el);	
			
			button.x = style.x;
			button.y = style.y;
			
			if (style.visible === false)
				button.visible = false;
			
			return button;
		}
		
		
		private function textDraw(el:XML) : TextField
		{			
			var text:TextField = new TextField,
				format:TextFormat = new TextFormat,
				
				defaults:Object = {
					font: 'Verdana',
					color: 0x000000,
					size: 11,
					bold: false,
					align: TextFormatAlign.LEFT,
					selectable: false
				},
				style:Object = extend(defaults, getStyles(el)); 
			
			format.font = style.font;
			format.color = style.color;
			format.size = style.size;
			format.bold = style.bold;
			format.align = style.align;
			
			text.defaultTextFormat = format;
			text.selectable = style.selectable;
			text.antiAliasType = AntiAliasType.ADVANCED;
			text.autoSize = TextFieldAutoSize.NONE;
			
			text.x = style.x;
			text.y = style.y;
			
			text.width = style.width;
			
			return text;
		}
		
		
		private function progressbarDraw(el:XML) : ProgressBar
		{
			var style:Object, bar:ProgressBar;
			
			style = getStyles(el);
			
			bar = new ProgressBar;
			
			doBackground(bar, style);
			
			actions['progress'] = bar.progress;
			actions['buffer'] = bar.buffer;
			
			bar.x = style.x;
			bar.y = style.y;
			
			return bar;
		}
		
		
		private function sliderDraw(el:XML) : Slider
		{
			var style:Object, slider:Slider;
			
			style = getStyles(el);
			
			slider = new Slider;
			
			doBackground(slider, style);
			doBackground(slider.bar, getStyles(el.bar[0]));
			doBackground(slider.handle, getStyles(el.handle[0]));
			
			slider.x = style.x;
			slider.y = style.y;
			
			return slider;
		}
		
		
		private function getState(state:String, style:Object, el:XML) : Shape
		{
			var shape:Shape = new Shape,
				stateStyle:Object = getStyles(el[state][0]);
			
			stateStyle.width = style.width;
			stateStyle.height = style.height;
			
			doBackground(shape, stateStyle);
			return shape;
		}
		
		
		private function getStyles(el:XML) : Object
		{
			var raw:Object = {},
				global:XML = xml.style.(@id == el.@style.toString())[0],
				attr:XML;
						
			// get styles from styles attribute
			if (global && global.length()) 
				for each (attr in global.attributes()) 
					raw[attr.name().toString().toLowerCase()] = attr.toString();			
		
			// get local styles, and override global ones were met
			for each (attr in el.attributes())
				raw[attr.name().toString().toLowerCase()] = attr.toString();	
				
			raw['parent_height'] = getDimension(el.parent(), 'height');
			raw['parent_width'] = getDimension(el.parent(), 'width');
			
			// every element must have some width/height, if not present, will be set to 100%
			raw['width'] = raw.hasOwnProperty('width') ? getDimension(el, 'width') : raw['parent_width'];
			raw['height'] = raw.hasOwnProperty('height') ? getDimension(el, 'height') : raw['parent_height'];
			
			return normalizeStyles(raw);			
		}
		
		
		private function normalizeStyles(raw:Object) : Object
		{
			var style:Object = {}, name:String, value:String;

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
					case 'font':
						style[name] = value;  
						break;
					
					case 'speed':
					case 'size':
					case 'radius':
						style[name] = Number(value);
						break;	
					
					case 'color':
						style[name] = uint(value.replace('#', '0x'));
						break;
					
					case 'background':	
						var background:String = value;
						if (/^#/.test(background)) 
							style.background = uint(background.replace('#', '0x'));	
						else
							style.background = background.split(' ');
						break;
					
					case 'bold':
					case 'repeat':
					case 'visible':
					case 'selectable':
						style[name] = (value.toLowerCase() == 'true');
						break;	
					
					case 'width':
					case 'height':
					case 'parent_width':
					case 'parent_height':
						style[name] = value;
						break;
					
					case 'align':
						var allowed:Array = ['left', 'right', 'center', 'justify'];
												
						if (allowed.indexOf(value.toLowerCase()) === -1)
							value = 'left';
						
						style[name] = TextFormatAlign[value.toLocaleUpperCase()];
						break;
				}
			}		
			
			if (!style.hasOwnProperty('x'))
				style.x = 0;
			
			if (!style.hasOwnProperty('y'))
				style.y = 0;
			
			return style;
		}
		
		
		private function extend(obj1:*, obj2:*, strict:Boolean = false, propsOnly:Boolean = true) : *
		{
			for (var key:String in obj2) {
				if (propsOnly && obj2[key] is Function)
					continue;
				
				if (strict) {
					if (obj1.hasOwnProperty(key))
						obj1[key] = obj2[key];
				} else {
					obj1[key] = obj2[key];
				}
			}
			return obj1;
		}
		
		
		private function getDimension(el:XML, attr:String) : Number
		{
			var max:Number, percentage:Number;
			
			// if we reached top node (mode) return max possible dimension
			if (el.name().toString() == 'mode')
				return this['max' + (attr == 'width' ? 'Width' : 'Height')];
			
			var value:* = el.attribute(attr).toString();
			if (!value.length) {
				
				// check for dimension in associated style
				value = xml.style.(@id == el.@style.toString()).attribute(attr).toString();
				if (!value.length)
					return getDimension(el.parent(), attr);
			}
			
			// handle dimension specified in percents
			if (/%$/.test(value)) 
			{					
				max = getDimension(el.parent(), attr);
				percentage = value.replace(/%$/, '');
				
				value = (max / 100 * percentage);	
			}	
			else if (/^-/.test(value)) {
				max = getDimension(el.parent(), attr);
				value = (max - value.replace(/^-/, ''));     
			}
			return Number(value);
		}
		
		
		private function doBackground(obj:*, style:Object) : void 
		{
			if (style.background is uint) 
			{
				obj.graphics.clear();
				obj.graphics.beginFill(style.background);
			}
			else if (style.background is Array)
			{
				var xy:Array = style.background,
					bitmap:BitmapData = new BitmapData((style.repeat ? 4 : style.width), style.height);
				
				bitmap.copyPixels(sprite.bitmapData, new Rectangle(xy[0], xy[1], (style.repeat ? 4 : style.width), style.height), new Point(0, 0));
				obj.graphics.clear();
				obj.graphics.beginBitmapFill(bitmap, null, false, true);
			}
			else
				return;
			
			if (style.hasOwnProperty('radius'))
				obj.graphics.drawRoundRect(0, 0, style.width, style.height, style.radius);
			else
				obj.graphics.drawRect(0, 0, style.width, style.height);
			
			obj.graphics.endFill();	  		
		}
				

	}
}

