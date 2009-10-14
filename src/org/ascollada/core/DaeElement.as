package org.ascollada.core {
	import flash.events.EventDispatcher;	
	
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeElement extends EventDispatcher {
		use namespace collada;
		
		/** */
		public var document : DaeDocument;

		/** */
		public var id : String;
		
		/** */
		public var sid : String;
		
		/** */
		public var name : String;
		
		/** */
		public var nodeName : String;
		
		/**
		 * 
		 */
		public function DaeElement(document : DaeDocument, element : XML=null) {
			this.document = document;
			
			if(element) {
				read(element);
			}
		}
		
		/**
		 *  
		 */
		public function destroy() : void {
			this.document = null;
			//this.id = this.sid = this.name = this.nodeName = null;
		}

		/**
		 *  
		 */
		public function read(element:XML) : void {
			this.id = element.@id.toString();
			this.sid = element.@sid.toString();
			this.name = element.@name.toString();
			this.nodeName = element.localName() as String;
		}
		
		/**
		 * 
		 */ 
		public function readAttribute(element:XML, name:String, stripPound:Boolean=false):String
		{
			var attr:String = element.@[name].toString();
			if(stripPound && attr.charAt(0) == "#")
				attr = attr.substr(1);
			return attr;
		}
		
		/**
		 * 
		 */ 
		public function readText(element:XML, stripPound:Boolean=false):String {
			if(!element) {
				return null;
			}
			var string :String = element.text().toString();
			if(stripPound && string.charAt(0) == "#") {
				string = string.substr(1);
			}
			return string;
		}
		
		/**
		 * 
		 */ 
		public function readStringArray(element:XML) : Array {
			return element.text().toString().split(/\s+/);
		}
	}
}
