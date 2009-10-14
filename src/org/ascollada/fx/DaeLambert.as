package org.ascollada.fx {
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.ns.collada;

	public class DaeLambert extends DaeConstant {
		use namespace collada;
		
		public var ambient:DaeColorOrTexture;
		public var diffuse:DaeColorOrTexture;
		
		/**
		 * 
		 */ 
		public function DaeLambert(document:DaeDocument, element:XML=null) {
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
		public override function read(element:XML):void {
			super.read(element);
			
			var children:XMLList = element.children();
			var numChildren:int = children.length();
			
			for( var i:int = 0; i < numChildren; i++ ) {
				var child:XML = children[i];
				
				switch(child.localName()) {
					case "ambient":
						this.ambient = new DaeColorOrTexture(document, child);
						break;
					case "diffuse":
						this.diffuse = new DaeColorOrTexture(document, child);
						break;
					default:
						break;		
				}
			}
		}
	}
}