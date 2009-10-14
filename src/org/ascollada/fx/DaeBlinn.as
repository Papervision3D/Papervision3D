package org.ascollada.fx
{
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeBlinn extends DaeLambert {
		use namespace collada;
		
		public var specular :DaeColorOrTexture;
		public var shininess :Number = 0;
		
		/**
		 * 
		 */ 
		public function DaeBlinn(document:DaeDocument, element:XML=null) {
			super(document, element);
		}

		override public function destroy() : void {
			super.destroy();
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
					case "specular":
						this.specular = new DaeColorOrTexture(document, child);
						break;
					case "shininess":
						this.shininess = child["float"][0] ? parseFloat(readText(child["float"][0])) : this.shininess;
						break;
					default:
						break;		
				}
			}
		}
	}
}