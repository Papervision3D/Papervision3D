package org.ascollada.fx
{
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	import org.ascollada.fx.DaeColor;
	import org.ascollada.fx.DaeTexture;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeColorOrTexture extends DaeElement {
		use namespace collada;
		
		public var color :DaeColor;
		public var texture :DaeTexture;
		
		/**
		 * 
		 */ 
		public function DaeColorOrTexture(document:DaeDocument, element:XML) {
			super(document, element);
		}

		/**
		 * 
		 */ 
		public override function read(element:XML):void
		{
			super.read(element);
			
			if(element["texture"][0]) {
				this.texture = new DaeTexture(document, element["texture"][0]);
			} else if(element["color"][0]) {
				this.color = new DaeColor(document, element["color"][0]);
			}
		}
	}
}