package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeChannel extends DaeElement {
		use namespace collada;
		
		public static const MEMBER_ACCESS :uint = 0;
		public static const ARRAY_ACCESS :uint = 1;
		
		/**
		 * 
		 */
		public var animation : DaeAnimation;
		
		/**
		 * 
		 */
		public var source : String;
		
		/**
		 * 
		 */
		public var target : String;
		
		/**
		 * 
		 */
		public var sampler : DaeSampler;

		public var type :int = -1;
		public var targetID :String;
		public var targetSID :String;
		public var targetMember :String;
		public var arrayIndex0 :int;
		public var arrayIndex1 :int;
		
		/**
		 * 
		 */
		public function DaeChannel(document : DaeDocument, animation : DaeAnimation, element : XML = null) {
			this.animation = animation;
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			if(this.sampler) {
				this.sampler.destroy();
				this.sampler = null;
			}
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.source = readAttribute(element, "source", true);
			this.target = readAttribute(element, "target");

			var parts : Array = this.target.split("/");
			
			if(parseArraySyntax(this.target)) {
				this.type = ARRAY_ACCESS;
			} else if(parseDotSyntax(this.target)) {
				this.type = MEMBER_ACCESS;
			} else if(this.target.length && parts.length) {
				this.targetSID = parts.pop() as String;
				this.type = MEMBER_ACCESS;
			} else {
				trace("[ERROR while parsing DaeChannel] " + target);
				return;
			}
			
			if(parts.length) {
				this.targetID = this.targetID || parts.shift() as String;
			} else {
				this.targetID = this.targetID || this.targetSID;
				this.targetSID = null;
			}
			
			if(this.targetSID.indexOf("/") != -1) {
				parts = this.targetSID.split("/");
				this.targetSID = parts.pop() as String;
			}
			
			if(this.targetID.indexOf("(") != -1) {
				parts = this.targetID.split("(");
				this.targetID = parts.shift() as String;
			}
		}
		
		/**
		 * 
		 */
		private function parseArraySyntax(target : String) : Boolean {	
			this.arrayIndex0 = -1;
			this.arrayIndex1 = -1;
			
			if(target.indexOf("(") != -1) {
				var pattern :RegExp = /.+\/(.+)\((\d+)\)\((\d+)\)/g;
				
				var matches:Array = pattern.exec(target);
				
				if(!matches) {
					pattern = /.+\/(.+)\((\d+)\)/g;
					matches = pattern.exec(target);
					if(!matches) {
						pattern = /(.+)\((\d+)\)\((\d+)\)/g;
						matches = pattern.exec(target);
						if(!matches) {
							pattern = /(.+)\((\d+)\)/g;
							matches = pattern.exec(target);
						}
					}
				}
				
				if(matches && matches.length > 2)  {
					this.targetSID = matches[1];
					this.arrayIndex0 = parseInt(matches[2], 10);
					if(matches.length > 3)
						this.arrayIndex1 = parseInt(matches[3], 10);
					return true;
				} else {
					trace("[WARNING] channel target contains '(...)', but failed to extract values! " + target);
				}
			}
			
			return false;
		}
		
		/**
		 * 
		 */
		private function parseDotSyntax(target : String) : Boolean {
			if(target.indexOf(".") != -1) {
				var parts :Array = target.split(".");
				if(parts.length < 2) {
					return false;
				}
				this.targetSID = parts.shift() as String;
				this.targetMember = parts.shift() as String;
				return true;
			}
			return false;
		}
		
		override public function toString():String {
			var str :String = "[DaeChannel ";
			if(this.type == MEMBER_ACCESS) {
				str += " (member access) targetID: '" + targetID + "' targetSID: '" + targetSID + "' targetMember: '" + targetMember +"'";
			} else {
				str += " (array access) targetID: '" + targetID + "' targetSID: '" + targetSID + "' idx0: " + arrayIndex0;
				if(arrayIndex1 >= 0)
					str += " idx1: " + arrayIndex1;
			}
			str += "]";
			return str;
		}
	}
}
