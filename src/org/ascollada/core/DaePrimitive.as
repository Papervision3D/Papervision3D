package org.ascollada.core {
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaePrimitive extends DaeElement {
		use namespace collada;
		
		/**
		 * 
		 */
		public var material : String;
		
		/**
		 * 
		 */
		public var vertices : DaeVertices;
		
		/**
		 * 
		 */
		public var count : int;
		
		/**
		 * 
		 */
		public var triangles : Array;
		
		/**
		 * 
		 */
		public var texCoordInputs : Array;
		
		/**
		 * 
		 */
		public var uvSets : Object;
		
		/**
		 * 
		 */
		public function DaePrimitive(document : DaeDocument, vertices :DaeVertices, element : XML = null) {
			this.vertices = vertices;
			super(document, element);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			var element : DaeElement;
			if(texCoordInputs) {
				while(texCoordInputs.length) {
					element = texCoordInputs.pop() as DaeElement;
					element.destroy();
					element = null;
				}
				texCoordInputs = null;
			}

			uvSets = null;
			triangles = null;
			vertices = null;
			material = null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.material = readAttribute(element, "material", true);
			this.count = parseInt(readAttribute(element, "count"), 10);
			this.triangles = new Array();
			this.uvSets = new Object();
			this.texCoordInputs = new Array();
			
			var list : XMLList = element["input"];
			var child : XML;
			var input : DaeInput;
			var inputs : Array = new Array();
			var maxOffset : int = 0;
			
			for each(child in list) {
				input = new DaeInput(this.document, child);		
				switch(input.semantic) {
					case "VERTEX":
						input.source = this.vertices.source.id;
						break;
					case "TEXCOORD":
						this.uvSets[input.setnum] = new Array();
						this.texCoordInputs.push(input);
						break;
					default:
						break;
				}
				maxOffset = Math.max(maxOffset, input.offset);
				inputs.push(input);
			}
			
			var primitives : XMLList = element["p"];
			var vc : XML = element["vcount"][0];
			var vcount : Array = vc ? readStringArray(vc) : null;
			
			switch(this.nodeName) {
				case "triangles":
					buildTriangles(primitives, inputs, maxOffset + 1);
					break;
				case "polylist":
					buildPolylist(primitives[0], vcount, inputs, maxOffset + 1);
					break;
				default:
					trace("don't know how to process primitives of type : " + this.nodeName);
					break;
			}
		}
		
		private function buildPolylist(primitive : XML, vcount:Array, inputs : Array, maxOffset : int) : void {
			var input : DaeInput;
			var p : Array = readStringArray(primitive);
			var i : int, j : int, index : int, pid : int = 0;
			var tmpUV : Object = new Object();

			for each(input in inputs) {
				if(input.semantic == "TEXCOORD") {
					tmpUV[input.setnum] = new Array();
				}
			}
				
			for(i = 0; i < vcount.length; i++) {
				var numVerts : int = parseInt(vcount[i], 10);
				var poly : Array = new Array();
				var uvs : Object = new Object();
				
				for(j = 0; j < numVerts; j++) {
					for each(input in inputs) {
						
						uvs[input.setnum] = uvs[input.setnum] || new Array();
						index = parseInt(p[pid + input.offset], 10);
						
						switch(input.semantic) {
							case "VERTEX":
								poly.push(index);
								break;
							case "TEXCOORD":
								uvs[input.setnum].push(index);
								break;
							default:
								break;
						}
					}
					pid += maxOffset;	
				}
				
				// simple triangulation
				for(j = 1; j < poly.length - 1; j++) {
					this.triangles.push([poly[0], poly[j], poly[j+1]]);
					var uv : Array;
					for(var o:String in uvs) {
						uv = uvs[o];
						this.uvSets[o].push([uv[0], uv[j], uv[j+1]]);
					}
				}
			}
		}
		
		private function buildTriangles(primitives : XMLList, inputs : Array, maxOffset : int) : void {
			var input : DaeInput;
			var primitive : XML;
			var index : int;
			var source : DaeSource;
			var i : int;
			
			for each(primitive in primitives) {
				var p : Array = readStringArray(primitive);
				var tri : Array = new Array();
				var tmpUV : Object = new Object();
				
				for each(input in inputs) {
					if(input.semantic == "TEXCOORD") {
						tmpUV[input.setnum] = new Array();
					}
				}
				
				while(i < p.length) {
					for each(input in inputs) {
						source = this.document.sources[input.source];
						index = parseInt(p[i + input.offset], 10);
						
						switch(input.semantic) {
							case "VERTEX":
								tri.push(index);
								if(tri.length == 3) {
									this.triangles.push(tri);
									tri = new Array();
								}
								break;
							case "TEXCOORD":
								tmpUV[input.setnum].push(index);
								if(tmpUV[input.setnum].length == 3) {
									this.uvSets[input.setnum].push(tmpUV[input.setnum]);
									tmpUV[input.setnum] = new Array();
								}
								break;
							case "NORMAL":
								break;
							default:
								break;
						}
					}
					i += maxOffset;
				}
			}
		}
	}
}
