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
		private var _fileSearchPaths :Array;
		
		/**
		 * 
		 */
		public function DAE(name : String = null) 
		{
			super(name);
			
			_fileSearchPaths = new Array();
		}
		
		/**
		 * Adds a path to search for referenced files like images, xrefs etc.
		 * 
		 * @param path
		 */
		public function addFileSearchPath(path : String) : void 
		{
			_fileSearchPaths.push(path);			
		}
		
		/**
		 * 
		 */
		public function load(asset:*):void
		{
			var parser :DAEParser = new DAEParser();
			
			for(var i:int = 0; i < _fileSearchPaths.length; i++) 
			{
				parser.addFileSearchPath(_fileSearchPaths[i]);
			}
			
			parser.addEventListener(Event.COMPLETE, onParseComplete);
			
			parser.load(this, asset);
		}
		
		/**
		 *  
		 */
		protected function onParseComplete(event:Event):void
		{
			var parser :DAEParser = event.target as DAEParser;
		}
	}
}
