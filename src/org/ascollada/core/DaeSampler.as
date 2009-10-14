package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeSampler extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var input : DaeSource;
		
		/**
		 * 
		 */
		public var output : DaeSource;
		
		/**
		 * 
		 */
		public var interpolations : DaeSource;
		
		/**
		 * 
		 */
		public var in_tangents : DaeSource;
		
		/**
		 * 
		 */
		public var out_tangents : DaeSource;
		
		/**
		 * 
		 */
		public function DaeSampler(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			this.input = null;
			this.output = null;
			this.interpolations = null;
			this.in_tangents = null;
			this.out_tangents = null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element["input"];
			var child : XML;
			
			for each(child in list) {
				var input : DaeInput = new DaeInput(this.document, child);
				switch(input.semantic) {
					case "INPUT":
						this.input = this.document.sources[input.source];
						break;
					case "OUTPUT":
						this.output = this.document.sources[input.source];
						break;
					case "INTERPOLATION":
						this.interpolations = this.document.sources[input.source];
						break;
					case "IN_TANGENT":
						this.in_tangents = this.document.sources[input.source];
						break;
					case "OUT_TANGENT":
						this.out_tangents = this.document.sources[input.source];
						break;
					default:
						trace("[DaeSampler] unhandled semantic: " + input.semantic);
						break;	
				}
			}
		}
	}
}
