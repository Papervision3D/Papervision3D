package org.ascollada.core {
	import org.ascollada.fx.DaeBindMaterial;	
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeInstanceGeometry extends DaeElement {
		use namespace collada;

		/**
		 * The URL of the location of the &lt;geometry&gt; element to instantiate. Required. Can 
		 * refer to a local instance or external reference.
		 */
		public var url : String;
		
		/**
		 * 
		 */
		public var bindMaterial : DaeBindMaterial;

		/**
		 * 
		 */
		public function DaeInstanceGeometry(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			if(this.bindMaterial) {
				this.bindMaterial.destroy();
				this.bindMaterial = null;
			}
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.url = readAttribute(element, "url");
			
			var list : XMLList = element["bind_material"];
			if(list.length()) {
				this.bindMaterial = new DaeBindMaterial(this.document, list[0]);
			}
		}
	}
}
