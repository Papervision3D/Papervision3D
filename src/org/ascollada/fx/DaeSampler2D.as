package org.ascollada.fx {
	import flash.errors.IllegalOperationError;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeSampler2D extends DaeElement {
		use namespace collada;
		
		public var source :String;
		public var wrap_s :String;
		public var wrap_t :String;
		public var minfilter :String;
		public var magfilter :String;
		public var mipfilter :String;
		
		/**
		 * 
		 */ 
		public function DaeSampler2D(document:DaeDocument, element:XML=null) {
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
			
			if(element["source"][0]) {
				this.source = readText(element["source"][0]);
			} else {
				throw new IllegalOperationError("DaeSampler2D expected a single <source> element!");
			}
			
			this.wrap_s = element["wrap_s"][0] ? readText(element["wrap_s"][0]) : "NONE";
			this.wrap_t = element["wrap_t"][0] ? readText(element["wrap_t"][0]) : "NONE";
			this.magfilter = element["magfilter"][0] ? readText(element["magfilter"][0]) : "NONE";
			this.minfilter = element["minfilter"][0] ? readText(element["minfilter"][0]) : "NONE";
			this.mipfilter = element["mipfilter"][0] ? readText(element["mipfilter"][0]) : "NONE";
		}
	}
}