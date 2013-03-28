package mxi.player
{	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	
	import mxi.display.FadingSprite;
	import mxi.display.GreenTimer;
	import mxi.display.Slider;
	import mxi.events.SliderEvent;
	
	import org.osmf.events.LoaderEvent;
	
	
	public class Controls extends FadingSprite
	{	
		public var skin:SkinParser;
		public var mode:String;
		
		private var sprite:Bitmap = null;
		private var xml:XML = null;
		
		// functional UI elements
		private var playButton:SimpleButton;
		private var pauseButton:SimpleButton;
		private var volumeUpButton:SimpleButton;
		private var volumeDownButton:SimpleButton;
		private var volumeSlider:Slider;
		private var fullscreenButton:SimpleButton;
		private var normscreenButton:SimpleButton;
		private var timeElapsed:TextField;
		private var timeLeft:TextField;
		private var progressBar:ProgressBar;
		private var controlPanel:FadingSprite;
		private var mouseOverControlPanel:Boolean;
		
		private var _loading:*;
		
		// setters, getters and their helpers
		private var _duration:Number = 0;
		private var _elapsed:Number = 0;
		private var _loaded:Number = 0;
				
		
		private var fadeTimer:GreenTimer = null;
		
		
		/* setters, getters and their helpers */
		public function get duration() : Number 
		{
			return _duration;
		}
		
		public function set duration(value:Number) : void
		{
			_duration = value;
			
			if (!duration && timeLeft)
				timeLeft.text = '-'+toHHIISS(duration);
		}
		
		public function get elapsed() : Number
		{
			return _elapsed;
		}
		
		public function set elapsed(value:Number) : void
		{
			_elapsed = value;
			
			if (timeElapsed)
				timeElapsed.text = toHHIISS(value);
			
			if (timeLeft)
				timeLeft.text = '-'+toHHIISS(duration - value);  
						
			// redraw progress bar
			if (progressBar && duration) {
				var newWidth:Number = value * progressBar.width / duration;
				if (newWidth > progressBar.width)
					newWidth = progressBar.width;
				
				skin.redoBackground('progress', {
					width: newWidth,
					height: progressBar.height
				});
			}
		}
		
		
		public function set loaded(value:Number) : void
		{
			_loaded = value;
			
			// redraw progress bar
			if (progressBar && duration) {
				skin.redoBackground('buffer', {
					width: Math.floor(value) / 100 * progressBar.width,
					height: progressBar.height
				});
			}
		}
		
		public function get loaded() : Number
		{
			return _loaded;
		}
		
		
		public function set loading(status:Boolean) : void 
		{
			if (_loading) {
				if (status)
					_loading.show();
				else
					_loading.hide();
			}
		}
		
		
		public function reset() : void
		{
			//duration = 0;
			elapsed = 0;
			loaded = 0;
			
			onPauseButton(new MouseEvent(MouseEvent.CLICK));
		}
		
		
		public function Controls(mode:String, sprite:Bitmap, xml:XML, w:Number, h:Number)
		{			
			var loader:Loader, urlLoader:URLLoader, overlay:Sprite;
			
			this.mode = mode;	
		
			skin = new SkinParser(sprite, xml);
			skin.draw(this, mode, w, h);
			
			initialize();
							
			// make video area clickable
			overlay = new Sprite;
			overlay.buttonMode = true;
			overlay.useHandCursor = false;
			overlay.graphics.beginFill(0x000000, 0);
			overlay.graphics.drawRect(0, 0, w, h);
			overlay.graphics.endFill();
			overlay.addEventListener(MouseEvent.CLICK, onTogglePlayPause);
			addChildAt(overlay, numChildren - 1);	
		}
		
		
		private function initialize() : void
		{
			controlPanel = skin.get('controls');
			if (controlPanel) {
				controlPanel.addEventListener(MouseEvent.ROLL_OVER, function() : void {
					mouseOverControlPanel = true;
				});
				controlPanel.addEventListener(MouseEvent.ROLL_OUT, function() : void {
					mouseOverControlPanel = false;
				});
			}
			
			
			_loading = skin.get('loading');
			if (_loading)
				this.setChildIndex(_loading, 0);
						
			playButton = skin.get('play');
			if (playButton)
				playButton.addEventListener(MouseEvent.CLICK, onPlayButton);
			
			pauseButton = skin.get('pause');
			if (pauseButton)
				pauseButton.addEventListener(MouseEvent.CLICK, onPauseButton);
			
			progressBar = skin.get('progressbar');
			if (progressBar) 
			{				
				var dispatchProgressClick:Function = function (e:MouseEvent) : void 
				{
					dispatchEvent(new ControlsEvent(
						ControlsEvent.PROGRESS_CLICK, 
						Math.floor(e.localX/progressBar.width*100)
					));					
				};
				progressBar.progress.addEventListener(MouseEvent.CLICK, dispatchProgressClick);
				progressBar.buffer.addEventListener(MouseEvent.CLICK, dispatchProgressClick);
			}
			
			volumeSlider = skin.get('volumeslider');
			if (volumeSlider)
			{
				var dispatchVolumeChange:Function = function(e:SliderEvent) : void
				{
					dispatchEvent(new ControlsEvent(ControlsEvent.VOLUME_CHANGE, e.data));
				}
				
				volumeSlider.addEventListener(SliderEvent.SLIDE, dispatchVolumeChange); 
				volumeSlider.addEventListener(SliderEvent.CHANGE, dispatchVolumeChange);
			}
			
			volumeUpButton = skin.get('volumeup');
			if (volumeUpButton) 
			{
				volumeUpButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) : void {
					if (mode == 'normal') {
						volumeUpButton.visible = false;
						if (volumeDownButton) 
							volumeDownButton.visible = true;
						
						dispatchEvent(new ControlsEvent(ControlsEvent.VOLUMEDOWN_CLICK));
					} else
						dispatchEvent(new ControlsEvent(ControlsEvent.VOLUMEUP_CLICK));
				});
			}
			
			volumeDownButton = skin.get('volumedown');
			if (volumeDownButton) 
			{
				volumeDownButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) : void {
					if (mode == 'normal') {
						volumeDownButton.visible = false;
						if (volumeUpButton) 
							volumeUpButton.visible = true;
						dispatchEvent(new ControlsEvent(ControlsEvent.VOLUMEUP_CLICK));
					} else
						dispatchEvent(new ControlsEvent(ControlsEvent.VOLUMEDOWN_CLICK));
				});
			}
			
			
			fullscreenButton = skin.get('fullscreen');
			if (fullscreenButton)
				fullscreenButton.addEventListener(MouseEvent.CLICK, function() : void {
					dispatchEvent(new ControlsEvent(ControlsEvent.FULLSCREEN_CLICK));
				});
			
			normscreenButton = skin.get('normscreen');
			if (normscreenButton)
				normscreenButton.addEventListener(MouseEvent.CLICK, function() : void {
					dispatchEvent(new ControlsEvent(ControlsEvent.NORMSCREEN_CLICK));
				});
			
			timeElapsed = skin.get('timeelapsed');
			if (timeElapsed)
				timeElapsed.text = '00:00';
			
			timeLeft = skin.get('timeleft');
			if (timeLeft)
				timeLeft.text = '-00:00'; 
		}
		
	
		/* event handlers */
		
		private function onTogglePlayPause(event:MouseEvent) : void
		{
			if (playButton.visible)
				onPlayButton(event);
			else
				onPauseButton(event); 
		}
		
		
		private function onPlayButton(event:MouseEvent) : void 
		{
			showPauseButton();
			dispatchEvent(new ControlsEvent(ControlsEvent.PLAY_CLICK));
		}
		
		
		private function onPauseButton(event:MouseEvent) : void 
		{
			showPlayButton();
			dispatchEvent(new ControlsEvent(ControlsEvent.PAUSE_CLICK));
		}
		
		
		public function showPauseButton() : void
		{
			if (pauseButton)
				pauseButton.visible = true;
			
			if (playButton)
				playButton.visible = false;
		}
		
		
		public function showPlayButton() : void
		{
			if (pauseButton)
				pauseButton.visible = false;
			
			if (playButton)
				playButton.visible = true;
		}
		
		
		private function toHHIISS(seconds:Number) : String
		{
			var h:Number, i:Number, s:Number,
			HHIISS:String,
			
			padZero:Function = function(number:uint) : String {
				return number > 9 ? number.toString() : '0' + number.toString();
			};
			
			s = seconds % 60;
			i = Math.floor((seconds % 3600) / 60);
			h = Math.floor(seconds / (3600));
			
			HHIISS = padZero(s);
			HHIISS = (i > 0 ? padZero(i) : '00') + ':' + HHIISS;
			if (h > 0)
				HHIISS = padZero(h) + ':' + HHIISS;
			
			return HHIISS;
		}
		
		
		public function setVolume(value:uint) : void
		{
			if (volumeSlider) {
				volumeSlider.value = value;
			} else {
				dispatchEvent(new ControlsEvent(ControlsEvent.VOLUME_CHANGE, value));
			}
		}
		
		
		override public function fadeIn(duration:uint = 300) : void
		{			
			if (mode == 'fullscreen') 
			{
				if (fadeTimer !== null) {
					fadeTimer.stop();
					fadeTimer.removeAllEvents();
					fadeTimer = null;
				} else {
					super.fadeIn(duration);
					Mouse.show();
				}
				
				fadeTimer = new GreenTimer(2000, 1);
				fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function() : void {
					fadeOut();
				});
				fadeTimer.start();
			}
			else	
			{
				Mouse.show();
				super.fadeIn(duration);
			}
							
		}
		
		override public function fadeOut(duration:uint = 300) : void
		{
			
			if (mode == 'fullscreen') 
			{	
				if (mouseOverControlPanel)
					return;
				
				Mouse.hide();
				super.fadeOut(duration);
				
				if (fadeTimer !== null) {
					fadeTimer.stop();
					fadeTimer.removeAllEvents();
					fadeTimer = null;
				}
			}
			else
				super.fadeOut(duration);
			
			Mouse.hide();
		}
		
		
		public function destroy() : void
		{
			if (volumeSlider) {
				volumeSlider.destroy();
			}
			
			removeAllEvents();
		}
		
	}
}