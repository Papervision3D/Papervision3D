package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeScene extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var url : String;
		
		/**
		 * 
		 */
		public function DaeScene(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			var list : XMLList = element["instance_visual_scene"];
			
			if(list.length()) {
				this.url = readAttribute(list[0], "url", true);
			}
		}
	}
}
