package org.ascollada.core {
	import org.ascollada.core.DaeElement;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeParam extends DaeElement {
		/** */
		public var type : String;
		
		/**
		 * 
		 */
		public function DaeParam(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		override public function read(element : XML) : void {
			super.read(element);
			this.type = element.@type.toString();
		}
	}
}
