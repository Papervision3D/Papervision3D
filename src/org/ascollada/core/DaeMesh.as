package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeMesh extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */		
		public var vertices : DaeVertices;

		/**
		 * 
		 */
		public var primitives : Array;

		/**
		 * 
		 */
		public function DaeMesh(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			if(this.vertices) {
				this.vertices.destroy();
				this.vertices = null;
			}
			
			if(this.primitives) {
				while(this.primitives.length) {
					var primitive : DaePrimitive = primitives.pop() as DaePrimitive;
					primitive.destroy();
				}
				this.primitives = null;
			}
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element["vertices"];
			var child : XML;
			
			this.primitives = new Array();
			
			if(list.length()) {
				this.vertices = new DaeVertices(this.document, list[0]);
			} else {
				throw new Error("[DaeMesh] Required <vertices> element not found!");
			}
			
			list = element["triangles"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["trifans"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["tristrips"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["polylist"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["polygons"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["lines"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
			
			list = element["linestrips"];
			for each(child in list) {
				this.primitives.push(new DaePrimitive(this.document, this.vertices, child));
			}
		}
	}
}
