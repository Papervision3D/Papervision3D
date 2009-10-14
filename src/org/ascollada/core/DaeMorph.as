package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeMorph extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */ 
		public var source : String;
		
		/**
		 * 
		 */
		public var method : String;
		
		/**
		 * 
		 */
		public var targets : DaeSource;
		
		/**
		 * 
		 */
		public var weights : DaeSource;
		
		/**
		 * 
		 */
		public function DaeMorph(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			this.targets = null;
			this.weights = null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.source = readAttribute(element, "source", true);
			this.method = readAttribute(element, "method") || "NORMALIZED";

			var targetInputs : XMLList = element["targets"].input;
			var num : int = targetInputs.length();
			var i : int;
			
			for(i = 0; i < num; i++) {
				var input : DaeInput = new DaeInput(document, targetInputs[i]);
				
				var src : DaeSource = document.sources[ input.source ];
				
				switch(input.semantic) {
					case "MORPH_TARGET":
						this.targets = src;
						break;
						
					case "MORPH_WEIGHT":
						this.weights = src;
						break;
					default:
						break;
				}
			}
		}
	}
}
