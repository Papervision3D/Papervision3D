package org.ascollada.fx {
	import flash.errors.IllegalOperationError;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	public class DaeMaterial extends DaeElement {
		use namespace collada;
		
		public var instance_effect :String;
		
		/**
		 * 
		 */ 
		public function DaeMaterial(document:DaeDocument, element:XML=null) {
			super(document, element);
		}
		
		/**
		 * 
		 */ 
		public override function read(element:XML):void
		{
			super.read(element);
			
			if(element["instance_effect"][0]) {
				this.instance_effect = readAttribute(element["instance_effect"][0], "url", true);
			} else {
				throw new IllegalOperationError("DaeMaterial expected a single <instance_effect> element!");	
			}
		}	
	}
}