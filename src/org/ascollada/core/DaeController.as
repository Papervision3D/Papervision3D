package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeController extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var skin : DaeSkin;

		/**
		 * 
		 */
		public var morph : DaeMorph;

		/**
		 * 
		 */
		public function DaeController(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			if(this.skin) {
				this.skin.destroy();
				this.skin = null;
			}
			
			if(this.morph) {
				this.morph.destroy();
				this.morph = null;
			}
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element["skin"];
			
			if(list.length()) {
				this.skin = new DaeSkin(this.document, list[0]);
			} else {
				list = element["morph"];
				if(list.length()) {
					this.morph = new DaeMorph(this.document, list[0]);
				} else {
					throw new Error("[DaeController] Could not find a <skin> or <morph> element!");
				}
			}
		}
	}
}
