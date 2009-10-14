package org.ascollada.core {
	import flash.display.BitmapData;	
	
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeImage extends DaeElement {
		use namespace collada;
		
		public var init_from : String;
		public var bitmapData : BitmapData;

		public function DaeImage(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		override public function destroy() : void {
			super.destroy();
			
			if(this.bitmapData) {
				this.bitmapData.dispose();
				this.bitmapData = null;
			}
		}

		override public function read(element : XML) : void {
			super.read(element);
			this.init_from = readText(element..init_from[0]);
		}
	}
}
