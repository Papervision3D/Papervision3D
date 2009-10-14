package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeAnimation extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var animations : Array;
		
		/**
		 * 
		 */
		public var channels : Array;
		
		/** */
		public var clips : Array;
		
		/**
		 * 
		 */
		private static var _newID : int = 0;
		
		/**
		 * 
		 */
		public function DaeAnimation(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			if(this.animations) {
				for each(var animation:DaeAnimation in this.animations) {
					animation.destroy();
				}
				this.animations = null;
			}
			
			if(this.channels) {
				for each(var channel:DaeChannel in this.channels) {
					channel.destroy();
				}
				this.channels = null;
			}
			
			this.clips = null;
		}
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.id = (this.id && this.id.length) ? this.id : "animation" + (_newID++);
			this.name = (this.name && this.name.length) ? this.name : this.id;
			this.animations = new Array();
			this.channels = new Array();
			
			var samplers : Object = new Object();
			var sampler : DaeSampler;
			var list : XMLList = element.children();
			var num : int = list.length();
			var child : XML;
			var i : int;
			
			for(i = 0; i < num; i++) {
				child = list[i];
				
				switch(child.localName() as String) {
					case "animation":
						this.animations.push(new DaeAnimation(this.document, child));
						break;
					case "sampler":
						sampler = new DaeSampler(this.document, child);
						samplers[sampler.id] = sampler;
						break;
					case "channel":
						this.channels.push(new DaeChannel(this.document, this, child));
						break;
					default:
						break;
				}
			}
			
			for(i = 0; i < this.channels.length; i++) {
				var channel : DaeChannel = this.channels[i];
				if(samplers[channel.source] is DaeSampler) {
					channel.sampler = samplers[channel.source];
				} else {
					throw new Error("[DaeAnimation] no sampler!");
				}
			}
		}
	}
}
