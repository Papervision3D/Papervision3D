package org.ascollada.core {
	import org.ascollada.core.DaeElement;
	
	/**
	 * @author Tim Knip
	 */
	public class DaeInput extends DaeElement {
		
		public var semantic :String;
		public var source :String;
		public var offset :int;
		public var setnum :int;
		
		/**
		 * 
		 */
		public function DaeInput(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		override public function destroy() : void {
			super.destroy();
		}

		override public function read(element : XML) : void {
			super.read(element);
			this.semantic = readAttribute(element, "semantic");
			this.source = readAttribute(element, "source", true);
			this.offset = element.@offset.length() ? parseInt(element.@offset.toString(), 10) : 0;
			this.setnum = element.@set.length() ? parseInt(element.@set.toString(), 10) : 0;
		}
	}
}
