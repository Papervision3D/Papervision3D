package org.ascollada.fx {
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;

	/**
	 * Binds geometry vertex inputs to effect vertex inputs upon instantiation. 
	 * 
	 * <p><strong>CONCEPTS</strong></p>
	 * <p>This element is useful, for example, in binding a vertex-program parameter to a <source>. The vertex 
	 * program needs data already gathered from sources. This data comes from the <input> elements under 
	 * the collation elements such as <polygons> or <triangles>. Inputs access the data in <source>s and 
	 * guarantee that it corresponds with the polygon vertex “fetch”. To reference the <input>s for binding, use 
	 * <bind_vertex_input>.</p>
	 * 
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeBindVertexInput extends DaeElement {
		use namespace collada;

		/**
		 * 
		 */
		public var semantic : String;
		
		/**
		 * 
		 */
		public var input_semantic : String;
		
		/**
		 * 
		 */
		public var input_set : uint;
		
		/**
		 * 
		 */
		public function DaeBindVertexInput(document : DaeDocument, element : XML = null) {
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
			
			this.semantic = readAttribute(element, "semantic");
			this.input_semantic = readAttribute(element, "input_semantic");
			
			var setid : String = readAttribute(element, "input_set");
			
			this.input_set = (setid && setid.length) ? parseInt(setid, 10) : 0;
		}
	}
}
