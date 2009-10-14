package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeTransform extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var data : Array;
		
		/**
		 * 
		 */
		public function DaeTransform(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			this.data = null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.data = readStringArray(element);
			
			for(var i : int = 0; i < this.data.length; i++) {
				this.data[i] = parseFloat(this.data[i]);
			}
		}
	}
}
