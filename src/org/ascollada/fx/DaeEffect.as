package org.ascollada.fx
{
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;

	public class DaeEffect extends DaeElement {
		use namespace collada;
		
		public var shader :DaeConstant;
		
		public var surface :DaeSurface;
		
		public var sampler2D :DaeSampler2D;
		
		public var double_sided :Boolean;
		public var wireframe :Boolean;
		
		/**
		 * 
		 */ 
		public function DaeEffect(document:DaeDocument, element:XML=null) {
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

			this.double_sided = false;
			this.wireframe = false;
			
			if(!readProfileCommon(element["profile_COMMON"][0])) {
				trace("[WARNING] DaeEffect: profile not found!");
			}
			
			if(element["extra"][0]) {
				readExtra(element["extra"][0]);
			}
		}	
		
		private function readExtra(element:XML):void {
			var technique :XML = element["technique"][0];
			
			if(!technique) {
				return;
			}
			
			var profile :String = readAttribute(technique, "profile");
			
			switch(profile) {
				case "MAX3D":
					this.double_sided = (technique["double_sided"][0] && readText(technique["double_sided"][0])) != "0" ? true : false;
					this.wireframe = (technique["wireframe"][0] && readText(technique["wireframe"][0])) != "0" ? true : false;
					break;
				case "GOOGLEEARTH":
					this.double_sided = (technique["double_sided"][0] && readText(technique["double_sided"][0])) != "0" ? true : false;
					break;
				default:
					break;
			}	
		}
		
		private function readProfileCommon(element:XML):Boolean
		{
			if(!element) return false;
			
			if(element..sampler2D[0]) {
				this.sampler2D = new DaeSampler2D(document, element..sampler2D[0]);
				
				var surf :XML = element["newparam"].(@sid == this.sampler2D.source)["surface"][0];
				if(surf) {
					this.surface = new DaeSurface(document, surf);
				}
			}
			
			if(!element["technique"].length)
				return false;
			
			var technique :XML = element["technique"][0];
			
			if(technique["constant"][0]) {
				this.shader = new DaeConstant(document, technique["constant"][0]);
			} else if(technique["lambert"][0]) {
				this.shader = new DaeLambert(document, technique["lambert"][0]);
			} else if(technique["blinn"][0]) {
				this.shader = new DaeBlinn(document, technique["blinn"][0]);	
			} else if(technique["phong"][0]) {
				this.shader = new DaePhong(document, technique["phong"][0]);
			} else {
				trace("[WARNING] DaeEffect : could not find a suitable shader!");
			}
			
			if(element["extra"][0]){
				readExtra(element["extra"][0]);
			}
			
			return true;
		}
		
	}
}