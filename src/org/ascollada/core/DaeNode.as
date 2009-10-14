package org.ascollada.core {
	import org.ascollada.core.ns.collada;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeNode extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var nodes : Array;
		
		/** */
		public var type : String;
		
		/** */
		public var layer : String;
		
		/**
		 * 
		 */
		public var transforms : Array;
		
		/**
		 * 
		 */
		public var cameraInstances : Array;
		
		/**
		 * 
		 */
		public var controllerInstances : Array;
		
		/**
		 * 
		 */
		public var geometryInstances : Array;
		
		/**
		 * 
		 */
		public var lightInstances : Array;
		
		/**
		 * 
		 */
		public var nodeInstances : Array;
		
		/**
		 * 
		 */
		public var channels : Array;
		
		/**
		 * 
		 */
		public function DaeNode(document : DaeDocument, element : XML = null) {
			super(document, element);
		}
		
		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			var element : DaeElement;
			
			if(this.nodes) {
				while(this.nodes.length) {
					element = this.nodes.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.nodes = null;
			}
			
			if(this.transforms) {
				while(this.transforms.length) {
					element = this.transforms.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.transforms = null;
			}
			
			if(this.cameraInstances) {
				while(this.cameraInstances.length) {
					element = this.cameraInstances.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.cameraInstances = null;
			}
			
			if(this.controllerInstances) {
				while(this.controllerInstances.length) {
					element = this.controllerInstances.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.controllerInstances = null;
			}
			
			if(this.geometryInstances) {
				while(this.geometryInstances.length) {
					element = this.geometryInstances.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.geometryInstances = null;
			}
			
			if(this.lightInstances) {
				while(this.lightInstances.length) {
					element = this.lightInstances.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.lightInstances = null;
			}
			
			if(this.nodeInstances) {
				while(this.nodeInstances.length) {
					element = this.nodeInstances.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				this.nodeInstances = null;
			}
		}

		/**
		 * Gets a transform by SID.
		 * 
		 * @param sid
		 * 
		 * @return The found transform or null on error.
		 * 
		 * @see org.ascollada.core.DaeTransform
		 */
		public function getTransformBySID(sid : String) : DaeTransform {
			if(this.transforms) {
				var transform : DaeTransform;
				for each(transform in this.transforms) {
					if(transform.sid == sid) {
						return transform;
					}
				}
			}
			return null;
		}

		/**
		 * 
		 */
		public function getTransformChannelBySID(sid : String) : DaeChannel {
			var channel : DaeChannel;
			for each(channel in this.channels) {
				if(channel.targetSID == sid) {
					return channel;
				}
			}
			return null;
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			var list : XMLList = element.children();
			var child : XML;
			var num : int = list.length();
			var i : int;
			
			this.type = readAttribute(element, "type");
			this.type = this.type.length == 0 ? "NODE" : this.type;
			this.layer = readAttribute(element, "layer");
			this.name = (this.name && this.name.length) ? this.name : this.id;
			this.nodes = new Array();
			this.transforms = new Array();
			this.cameraInstances = new Array();
			this.controllerInstances = new Array();
			this.geometryInstances = new Array();
			this.lightInstances = new Array();
			this.nodeInstances = new Array();
			
			for(i = 0; i < num; i++) {
				child = list[i];
				
				switch(child.localName() as String) {
					case "lookat":
					case "matrix":
					case "scale":
					case "skew":
					case "rotate":
					case "translate":
						this.transforms.push(new DaeTransform(this.document, child));
						break;
					case "node":
						this.nodes.push(new DaeNode(this.document, child));
						break;
					case "instance_camera":
					trace("CAMERA!");
						this.cameraInstances.push(new DaeInstanceCamera(this.document, child));
						break;
					case "instance_controller":
						this.controllerInstances.push(new DaeInstanceController(this.document, child));
						break;
					case "instance_geometry":
						this.geometryInstances.push(new DaeInstanceGeometry(this.document, child));
						break;
					case "instance_light":
						this.lightInstances.push(new DaeInstanceLight(this.document, child));
						break;
					case "instance_node":
						this.nodeInstances.push(new DaeInstanceNode(this.document, child));
						break;
					case "extra":
						break;
					default:
						trace(child.localName());
						break;
				}
			}
		}
	}
}
