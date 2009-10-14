package org.ascollada.fx {
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeInstanceMaterial extends DaeElement {
		use namespace collada;
		
		public var symbol :String;
		public var target :String;
		public var bind_vertex_input :Array;
		
		/**
		 * 
		 */ 
		public function DaeInstanceMaterial(document:DaeDocument, element:XML=null) {
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
		public function findBindVertexInput(semantic:String, input_semantic:String):DaeBindVertexInput {
			for each(var bv:DaeBindVertexInput in this.bind_vertex_input) {
				if(bv.semantic == semantic && bv.input_semantic == input_semantic)
					return bv;
			}
			return null;
		}
		
		/**
		 * 
		 */ 
		public override function read(element:XML):void {
			super.read(element);
			
			this.symbol = readAttribute(element, "symbol");
			this.target = readAttribute(element, "target");
			this.bind_vertex_input = new Array();
			
			var list :XMLList = element["bind_vertex_input"];
			var i :int;
			
			for(i = 0; i < list.length(); i++) {
				this.bind_vertex_input.push(new DaeBindVertexInput(document, list[i]));
			}		
		}
	}
}