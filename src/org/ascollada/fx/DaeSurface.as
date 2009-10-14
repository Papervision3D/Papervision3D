package org.ascollada.fx
{
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	public class DaeSurface extends DaeElement
	{
		use namespace collada;
		
		public var type :String;
		public var init_from :String;
		public var format :String;
		
		/**
		 * 
		 */ 
		public function DaeSurface(document:DaeDocument, element:XML=null)
		{
			super(document, element);
		}
		
		/**
		 * 
		 */ 
		public override function read(element:XML):void
		{
			super.read(element);
			
			this.type = readAttribute(element, "type");
			this.init_from = element["init_from"][0] ? readText(element["init_from"][0]) : "";
			this.format = element["format"][0] ? readText(element["format"][0]) : "";
		}
	}
}