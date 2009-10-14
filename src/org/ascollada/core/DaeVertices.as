package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeVertices extends DaeElement {
		use namespace collada;
		
		public var source : DaeSource;

		/**
		 * 
		 */
		public function DaeVertices(document : DaeDocument, element : XML = null) {
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
			
			var list : XMLList = element["input"];
			var num : int = list.length();
			var i : int;
			
			for(i = 0; i < num; i++) {
				var child : XML = list[i];
				var input : DaeInput = new DaeInput(this.document, child);
				
				if(input.semantic == "POSITION") {
					this.source = this.document.sources[input.source] as DaeSource;
				}
			}
			
			if(!this.source) {
				throw new Error("[DaeVertices] required <input> element with @semantic=\"POSITION\" not found!");
			}
		}
	}
}
