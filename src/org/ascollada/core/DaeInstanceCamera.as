package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeInstanceCamera extends DaeElement {
		use namespace collada;

		/**
		 * 
		 */
		public function DaeInstanceCamera(document : DaeDocument, element : XML = null) {
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
		}
	}
}
