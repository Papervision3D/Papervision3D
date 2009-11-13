package org.papervision3d.core.io.parser {
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import org.ascollada.core.DaeDocument;
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip / Floorplanner.com
	 */
	public class DAEParser extends EventDispatcher {
		
		/** */
		public var document :DaeDocument;
		
		/** */
		public var target :DisplayObject3D;
		
		/**
		 *  
		 */
		public function DAEParser() {
			super();
		}

		/**
		 *  
		 */
		public function load(target:DisplayObject3D, asset:*) : void {
			this.target = target;
			this.document = new DaeDocument();
			
			this.document.addEventListener(Event.COMPLETE, onParseComplete);
			
			if (asset is ByteArray || asset is XML) {
				trace(new XML(asset));
				this.document.read(new XML(asset));	
			} else if (asset is String) {
				
			} else {
				throw new IllegalOperationError("Expected an url, some XML or a ByteArray!");
			}
		}
		
		/**
		 * 
		 */
		protected function onParseComplete(event:Event):void {
			dispatchEvent(event);
		}
	}
}
