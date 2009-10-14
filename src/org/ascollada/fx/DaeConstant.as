package org.ascollada.fx
{
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeConstant extends DaeElement {
		use namespace collada;
		
		public var emission:DaeColorOrTexture;
		public var reflective:DaeColorOrTexture;
		public var reflectivity:Number = 0;
		public var transparent:DaeColorOrTexture;
		public var transparency:Number = 0;
		public var index_of_refraction:Number = 0;
		
		/**
		 * 
		 */ 
		public function DaeConstant(document:DaeDocument, element:XML=null) {
			super(document, element);
		}
		
		/**
		 * 
		 */ 
		public override function read(element:XML):void {
			super.read(element);
			
			var children:XMLList = element.children();
			var numChildren:int = children.length();
			
			for( var i:int = 0; i < numChildren; i++ ) {
				var child:XML = children[i];
				
				switch(child.localName()) {
					case "emission":
						this.emission = new DaeColorOrTexture(document, child);
						break;
					case "reflective":
						this.reflective = new DaeColorOrTexture(document, child);
						break;
					case "transparant":
						this.reflective = new DaeColorOrTexture(document, child);
						break;
					case "reflectivity":
						this.reflectivity = child["float"][0] ? parseFloat(readText(child["float"][0])) : this.reflectivity;
						break;
					case "transparency":
						this.transparency = child["float"][0] ? parseFloat(readText(child["float"][0])) : this.transparency;
						break;
					case "index_of_refraction":
						this.index_of_refraction = child["float"][0] ? parseFloat(readText(child["float"][0])) : this.index_of_refraction;
						break;
					default:
						break;		
				}
			}
		}
	}
}