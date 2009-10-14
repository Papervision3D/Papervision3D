package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeAccessor extends DaeElement {
		use namespace collada;
		
		public var params :Vector.<DaeParam>;
		public var count :int;
		public var stride :int;
		public var offset :int;
		
		/**
		 * 
		 */
		public function DaeAccessor(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			if(params) {
				while(params.length) {
					var param : DaeParam = params.pop();
					param.destroy();
				}
				params = null;
			}
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.count = parseInt(element.@count.toString(), 10);
			this.stride = element.@stride.length() ? parseInt(element.@stride.toString(), 10) : 1;
			this.offset = element.@offset.length() ? parseInt(element.@offset.toString(), 10) : 0;
			this.params = new Vector.<DaeParam>();
			
			var list :XMLList = element["param"];
			var i :int;
			
			for(i = 0; i < list.length(); i++) {
				this.params.push(new DaeParam(this.document, list[i]));
			}
		}
	}
}
