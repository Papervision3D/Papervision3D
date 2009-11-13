package org.papervision3d.core.events {

	import flash.events.Event;
	import flash.events.ProgressEvent;
	/**
	 * @author timknip
	 */
	public class FileLoadEvent extends ProgressEvent {
		public static const LOAD_COMPLETE:String = "FileLoadComplete";
		public static const LOAD_ERROR:String = "FileLoadError";
		
		public var message :String;
		
		public function FileLoadEvent(type:String, message:String="", bubbles:Boolean=false, cancelable:Boolean=false, bytesLoaded:uint=0, bytesTotal:uint=0) {
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
			this.message = message;
		}

		override public function clone():Event {
			return new FileLoadEvent(type, message, bubbles, cancelable, bytesLoaded, bytesTotal);
		}
	}
}
