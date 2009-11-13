package org.papervision3d.objects.parsers 
{
	import flash.events.Event;
	import org.papervision3d.core.io.parser.DAEParser;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip / Floorplanner.com
	 */
	public class DAE extends DisplayObject3D 
	{
		/**
		 * 
		 */
		public function DAE(name : String = null) 
		{
			super(name);
		}
		
		/**
		 * 
		 */
		public function load(asset:*):void
		{
			var parser :DAEParser = new DAEParser();
			
			parser.addEventListener(Event.COMPLETE, onParseComplete);
			
			parser.load(this, asset);
		}
		
		/**
		 *  
		 */
		protected function onParseComplete(event:Event):void
		{
			trace("COMPLETE");
		}
	}
}
