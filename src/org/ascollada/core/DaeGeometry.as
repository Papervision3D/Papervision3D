package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeGeometry extends DaeElement {
		use namespace collada;
		
		public var mesh : DaeMesh;

		/**
		 * 
		 */
		public function DaeGeometry(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			if(this.mesh) {
				this.mesh.destroy();
				this.mesh = null;
			}
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element["mesh"];
			
			if(list.length()) {
				this.mesh = new DaeMesh(this.document, list[0]);
			} else {
				list = element["convex_mesh"];
				if(list.length()) {
					
				} else {
					list = element["spline"];
					if(list.length()) {
						
					} else {
						throw new Error("");
					}
				}
			}
		}
	}
}
