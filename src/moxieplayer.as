package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mxi.Utils;
	import mxi.player.Controls;
	import mxi.player.ControlsEvent;
		
	[SWF(backgroundColor="#000000")] 
	public class moxieplayer extends Sprite
	{
		[Embed(source="skin.png")]
		private var SkinSprite : Class;
		
		[Embed(source="skin.xml", mimeType="application/octet-stream")]
		private var SkinXML : Class;
		
		private var sprite:Bitmap = null;
		private var xml:XML = null;
		
		private var params:Object = {}
		
		private var net:NetConnection;
		private var stream:NetStream;
		private var poster:Bitmap;
		private var video:Video;
		private var controls:Controls = null;
		
		private var videoInPlayer:Boolean = false;
		private var isPaused:Boolean = true;
		private var isStopped:Boolean = true;
		
		private var volume:uint = 80;
		private var duration:Number;
		
		public function moxieplayer()
		{	
			// use only FlashVars, ignore QueryString
			var url:String, urlParts:Object, pos:int, query:Object;
			
			params = root.loaderInfo.parameters;
			pos = root.loaderInfo.url.indexOf('?');
			if (pos !== -1) {
				query = Utils.parseStr(root.loaderInfo.url.substr(pos + 1));		
				
				for (var key:String in params) {	
					if (query.hasOwnProperty(Utils.trim(key))) {
						delete params[key];
					}
				}
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			/* we do not need to support dynamic skins in this build
			
			var loader:Loader, urlLoader:URLLoader;
			
			if (root.loaderInfo.parameters.hasOwnProperty(sprite) && root.loaderInfo.parameters.hasOwnProperty(xml)) {
				loader = new Loader;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, spriteLoadComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, spriteLoadFailed);
				loader.load(new URLRequest(root.loaderInfo.parameters.sprite)); 
				
				urlLoader = new URLLoader;
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				urlLoader.addEventListener(Event.COMPLETE, xmlLoadComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadFailed);
				urlLoader.load(new URLRequest(root.loaderInfo.parameters.xml));
			} else {*/
				spriteLoadFailed();
				xmlLoadFailed();
			// }
		}
		
		
		/*private function spriteLoadComplete(event:Event) : void 
		{
			sprite = event.target.loader.content;
			initialize();
		}
		
		private function xmlLoadComplete(event:Event) : void 
		{
			try {
				xml = new XML(event.target.data);
				initialize();
			} catch (e:TypeError) {
				xmlLoadFailed();
			}
		}*/
		
		private function spriteLoadFailed(event:* = null) : void
		{
			sprite = new SkinSprite;
			initialize();
		}

		private function xmlLoadFailed(event:* = null) : void
		{
			var byteArray:ByteArray = new SkinXML;
			xml = new XML(byteArray.readUTFBytes(byteArray.length));
			initialize();
		}
		
		
		private function initialize() : void 
		{
			if (sprite === null || xml === null)
				return;
			
			// preload poster
			preloadPoster();
			
			// initialize video stream
			net = new NetConnection;
			net.connect(null);
			stream = new NetStream(net);
			
			stream.bufferTime = 10;
			video = new Video;
			video.attachNetStream(stream);
			
			// draw and activate player controls
			activateControls('normal');
			
			addEventListeners();					
		}
		
		
		private function preloadPoster() : void
		{
			if (!params.hasOwnProperty('poster')) {
				return;	
			}
			
			var	loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event) : void 
			{
				event.target.removeEventListener(Event.COMPLETE, arguments.callee);
				poster = event.target.loader.content;
				showPoster();
			});
			loader.load(new URLRequest(params['poster'])); 
		}
		
		
		private function activateControls(mode:String = 'normal') : void
		{	
			controls = new Controls(mode, sprite, xml, stage.stageWidth, stage.stageHeight);	
			
			// play button ...
			controls.addEventListener(ControlsEvent.PLAY_CLICK, function () : void 
			{				
				if (!videoInPlayer && params.hasOwnProperty('url'))
					load(params['url']);
					//load('sample.flv');
				else
					stream.resume();
				
				isPaused = false;	
				isStopped = false;
			});   
			
			// pause button ...
			controls.addEventListener(ControlsEvent.PAUSE_CLICK, function () : void 
			{
				stream.pause();
				isPaused = true;
			});
			
			// progress bar ...
			controls.addEventListener(ControlsEvent.PROGRESS_CLICK, function(event:ControlsEvent) : void 
			{
				stream.seek(Math.floor(event.data/100*controls.duration));				
			});
			
			// volume
			controls.addEventListener(ControlsEvent.VOLUME_CHANGE, function(event:ControlsEvent) : void
			{
				volume = event.data;
				stream.soundTransform = new SoundTransform(volume / 100);
			});
			
			controls.addEventListener(ControlsEvent.VOLUMEUP_CLICK, function(event:ControlsEvent) : void 
			{
				controls.setVolume(100);
			});
			
			controls.addEventListener(ControlsEvent.VOLUMEDOWN_CLICK, function(event:ControlsEvent) : void 
			{
				controls.setVolume(0);
			});
			
			// fullscreen ...
			controls.addEventListener(ControlsEvent.FULLSCREEN_CLICK, function() : void 
			{
				destroyControls();
				stage.displayState = StageDisplayState.FULL_SCREEN;
			});
			
			// back to normal screen
			controls.addEventListener(ControlsEvent.NORMSCREEN_CLICK, function() : void 
			{
				destroyControls();
				stage.displayState = StageDisplayState.NORMAL;
			});
			
			
			controls.addEventListener(Event.ADDED_TO_STAGE, function() : void
			{
				// show/hide controls on mouse move
				stage.addEventListener(Event.MOUSE_LEAVE, hideControls);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, showControls);	
			});
			
			// restore media info after mode switch
			controls.duration = duration;
			controls.setVolume(volume);
			
			if (isPaused)
				controls.showPlayButton();
			else
				controls.showPauseButton();
			
			addChild(controls);		
		} 
		
		
		private function addEventListeners() : void
		{
			// find out video duration
			stream.client = { 
				onMetaData : function(meta:Object):void {
					controls.duration = (duration = meta.duration);
				}
			};
			
			// monitor for playback end and reset everything
			stream.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) : void 
			{
				if (event.info.code == 'NetStream.Play.Stop') {
					isStopped = true;
					stream.seek(0);
					controls.reset();
					hideVideo();
					showPoster();
				}
			});
			
			// fullscreen toggle event
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, function(event:FullScreenEvent) : void 
			{				
				if (event.fullScreen) {
					activateControls('fullscreen');	
					showControls();
				} else {
					activateControls('normal');
					Mouse.show();
				}
				if (isStopped) {
					showPoster();
				} else {
					videoInPlayer = false; 
					scaleVideo();
				}
			});
			
			stage.addEventListener(Event.RESIZE, function(event:Event) : void 
			{
				destroyControls();
				activateControls('normal');
				Mouse.show();
				if (isStopped) {
					showPoster();
				} else {
					videoInPlayer = false; 
					scaleVideo();
				}
			});
			
			
			addEventListener(Event.ENTER_FRAME, function() : void 
			{			
				// update UI
				if (!isStopped) {
					controls.elapsed = stream.time;
					controls.loaded = stream.bytesLoaded / stream.bytesTotal * 100;
				}
			});
		}
		
		private function hidePoster() : void
		{
			if (poster) {
				try {
					getChildIndex(poster);
					removeChild(poster);
				} catch (ex:ArgumentError) {}
			}
		}
		
		
		private function showPoster() : void
		{
			if (!poster || !isStopped || videoInPlayer) {
				return;
			}
						
			var ratio:Number = Math.max(stage.stageWidth / poster.width, stage.stageHeight / poster.height);
			
			poster.width = Math.round(poster.width * ratio);
			poster.height = Math.round(poster.height * ratio);
			poster.x = Math.round((stage.stageWidth - poster.width) / 2);
			poster.y = Math.round((stage.stageHeight - poster.height) / 2);
			
			addChildAt(poster, 0);
		}
		
		private function hideVideo() : void
		{
			if (video) {
				try {
					getChildIndex(video);
					removeChild(video);
				} catch (ex:ArgumentError) {}
			}
			videoInPlayer = false; 
		}
		
		
		private function scaleVideo() : void 
		{					
			if (videoInPlayer) {
				return;
			}
			
			if (video.videoWidth <= 0) {
				setTimeout(scaleVideo, 200);
				return;
			}
						
			var ratio:Number = Math.min(stage.stageWidth / video.videoWidth, stage.stageHeight / video.videoHeight);
			
			//if (ratio < 1) {
			video.width = Math.round(video.videoWidth * ratio);
			video.height = Math.round(video.videoHeight * ratio);
			//}
			
			// center video element horizontally and vertically
			video.x = Math.round((stage.stageWidth - video.width) / 2);
			video.y = Math.round((stage.stageHeight - video.height) / 2);
			
			controls.loading = false;
			addChildAt(video, 0);
			
			videoInPlayer = true;
		}
		
		
		public function load(src:String) : void
		{			
			hidePoster();
			controls.loading = true;
			stream.play(src);
			scaleVideo();
		}
		
		
		private function hideControls(... args) : void
		{
			controls.fadeOut(300);
		}
		
		private function showControls(... args) : void
		{
			controls.fadeIn(300);
		}
		
		private function destroyControls() : void 
		{
			if (controls != null) {
				stage.removeEventListener(Event.MOUSE_LEAVE, hideControls);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, showControls);
				controls.destroy();
			}
			removeChild(controls);
			controls = null; 
		}
		
		public static function log(... args) : void
		{
			ExternalInterface.call('console.log', args);	
		}
		
	}
}