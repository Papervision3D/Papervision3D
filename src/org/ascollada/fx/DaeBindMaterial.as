package org.ascollada.fx {
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeBindMaterial extends DaeElement {
		use namespace collada;
		
		public var instanceMaterials : Array;
		
		/**
		 * 
		 */
		public function DaeBindMaterial(document : DaeDocument, element : XML = null) {
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
		public function getInstanceMaterialBySymbol(symbol : String) : DaeInstanceMaterial {
			if(instanceMaterials) {
				for each(var m : DaeInstanceMaterial in instanceMaterials) {
					if(m.symbol == symbol) {
						return m;
					}
				}
			}
			return null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element..instance_material;
			var child : XML;

			this.instanceMaterials = new Array();
			
			for each(child in list) {
				this.instanceMaterials.push(new DaeInstanceMaterial(this.document, child));
			}
		}
	}
}
