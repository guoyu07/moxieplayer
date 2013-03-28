package mxi
{
	import flash.external.ExternalInterface;

	public class Utils
	{
		public static function parseUrl(str:String) : Object {

			var key:Array = ['source', 'scheme', 'authority', 'userInfo', 'user', 'pass', 'host', 'port', 'relative', 'path', 'directory', 'file', 'query', 'fragment'],
				regex:RegExp = /^(?:([^:\/?#]+):)?(?:\/\/()(?:(?:()(?:([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?))?()(?:(()(?:(?:[^?#\/]*\/)*)()(?:[^?#]*))(?:\?([^#]*))?(?:#(.*))?)/, 
				m:Array = regex.exec(str),
				uri:Object = {},
				i:int = 14;
						
			while (i--) {
				if (m[i]) {
					uri[key[i]] = m[i];  
				}
			}			
			return uri;
		}
	
	
		public static function parseStr (str:String) : Object {
			var hash:Object = {},
				arr1:Array, arr2:Array;
			
			str = unescape(str).replace(/\+/g, " ");
			
			arr1 = str.split('&');
			if (!arr1.length) {
				return {};
			}
			
			for (var i:uint = 0, length:uint = arr1.length; i < length; i++) {
				arr2 = arr1[i].split('=');
				if (!arr2.length) {
					continue;
				}
				hash[Utils.trim(arr2[0])] = Utils.trim(arr2[1]);
			} 
			return hash;
		}
		
		
		public static function trim(str:String) : String {				
			if (!str) {
				return str;	
			}
			
			return str.toString().replace(/^\s*/, '').replace(/\s*$/, '');	
		}
	
	}
}