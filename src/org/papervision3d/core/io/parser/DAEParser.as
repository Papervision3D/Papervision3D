package org.papervision3d.core.io.parser {
	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeGeometry;
	import org.ascollada.core.DaeImage;
	import org.ascollada.core.DaeInput;
	import org.ascollada.core.DaeInstanceGeometry;
	import org.ascollada.core.DaeMesh;
	import org.ascollada.core.DaeNode;
	import org.ascollada.core.DaePrimitive;
	import org.ascollada.core.DaeSource;
	import org.ascollada.fx.DaeBindMaterial;
	import org.ascollada.fx.DaeColorOrTexture;
	import org.ascollada.fx.DaeEffect;
	import org.ascollada.fx.DaeInstanceMaterial;
	import org.ascollada.fx.DaeMaterial;
	import org.ascollada.fx.DaeTexture;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.TriangleMesh;
	import org.papervision3d.core.geom.UVCoord;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip / Floorplanner.com
	 */
	public class DAEParser extends EventDispatcher {
		
		/** */
		public var document :DaeDocument;
		
		/** */
		public var target :DisplayObject3D;
		
		private var _objectToNode :Dictionary;
		private var _nodeToObject :Dictionary;
		private var _numVertices :uint;
		private var _numTriangles :uint;
		private var _parseStartTime :int;
		private var _fileSearchPaths :Array;
		
		/**
		 *  
		 */
		public function DAEParser() 
		{
			super();
			_fileSearchPaths = new Array();
		}

		/**
		 * Adds a path to search for referenced files like images, xrefs etc.
		 * 
		 * @param path
		 */
		public function addFileSearchPath(path : String) : void 
		{
			_fileSearchPaths.push(path);			
		}
		
		/**
		 *  
		 */
		public function load(target:DisplayObject3D, asset:*) : void 
		{
			this.target = target;
			
			if (asset is ByteArray || asset is XML) 
			{
				parseXML(new XML(asset));
			} 
			else if (asset is String) 
			{
				var loader :URLLoader = new URLLoader();
				
				loader.addEventListener(Event.COMPLETE, onFileLoadComplete);
				loader.addEventListener(ProgressEvent.PROGRESS, onFileLoadProgress);
				
				loader.load(new URLRequest(String(asset)));
			} 
			else 
			{
				throw new IllegalOperationError("Expected an url, some XML or a ByteArray!");
			}
		}
		
		/**
		 * 
		 * @param parent
		 * @param node
		 */
		private function buildGeometries(parent : TriangleMesh, node : DaeNode) : void 
		{
			var geometryInstance :DaeInstanceGeometry;
			var geometry :DaeGeometry;
			
			for each(geometryInstance in node.geometryInstances) 
			{
				var url : String = geometryInstance.url;
				
				if(url.charAt(0) == "#") 
				{
					// local to file
					url = url.substr(1);
				} 
				else 
				{
					// TODO: handle geometry xrefs
					continue;
				}
				
				geometry = this.document.geometries[url];
				if(geometry && geometry.mesh) 
				{
					buildMesh(parent, geometry.mesh, geometryInstance.bindMaterial);
				}
			}
		}
		
		/**
		 * 
		 */
		private function buildMaterial(daeInstanceMaterial:DaeInstanceMaterial, shader:String="diffuse"):AbstractMaterial 
		{
			var material : AbstractMaterial = null;
			
			if(!daeInstanceMaterial) 
			{
				return material;
			}
			
			var url : String = daeInstanceMaterial.target;
				
			if(url.charAt(0) == "#") 
			{
				// local to file
				url = url.substr(1);
			} 
			else 
			{
				// TODO: handle material xrefs
				return material;
			}
				
			var daeMaterial :DaeMaterial = this.document.materials[url];
			if(!daeMaterial) 
			{
				return material;
			}
			
			var daeEffect :DaeEffect = this.document.effects[daeMaterial.instance_effect];
			if(!daeEffect) 
			{
				return material;
			}
			
			var daeColorOrTexture :DaeColorOrTexture = daeEffect.shader[ shader ];
			if(!daeColorOrTexture) 
			{
				return material;
			}
			
			if(daeEffect.surface || daeColorOrTexture.texture is DaeTexture) 
			{
				var image :DaeImage = daeEffect.surface ? 
									  this.document.images[daeEffect.surface.init_from] : 
									  this.document.images[daeColorOrTexture.texture.texture];

				if(image && image.bitmapData is BitmapData) 
				{
					material = new BitmapMaterial(image.bitmapData.clone());
				}
			} 
			else if(daeColorOrTexture.color) 
			{
				var r :int = daeColorOrTexture.color.r * 255.0;
				var g :int = daeColorOrTexture.color.g * 255.0;
				var b :int = daeColorOrTexture.color.b * 255.0;
				var a :int = daeColorOrTexture.color.a * 255.0;
				var color :uint = (a << 24 | r << 16 | g << 8 | b);

				var bitmapData : BitmapData = new BitmapData(1, 1, true, color);
				material = new BitmapMaterial(bitmapData);
			}
			return material;
		}
		 
		/**
		 * Builds a mesh.
		 * 
		 * @param parent
		 * @param daeMesh
		 * @param daeBindMaterial
		 */
		private function buildMesh(parent:TriangleMesh, daeMesh:DaeMesh, daeBindMaterial:DaeBindMaterial):void 
		{
			var vertexStart : uint = parent.triangleGeometry.vertices.length;
			var daeInstMaterial :DaeInstanceMaterial;
			var daePrimitive :DaePrimitive;
			var verticesSource :DaeSource = daeMesh.vertices.source;
			
			buildVertices(parent, daeMesh);
			
			for each(daePrimitive in daeMesh.primitives) 
			{
				daeInstMaterial = daeBindMaterial ? daeBindMaterial.getInstanceMaterialBySymbol(daePrimitive.material) : null;	
				buildPrimitive(parent, daePrimitive, daeInstMaterial, vertexStart);
			}
			
			if(verticesSource && verticesSource.channels && verticesSource.channels.length) 
			{
				trace("vertices are animated!");
			}
		}
		
		/**
		 * Builds a node.
		 * 
		 * @param node
		 * @param parent
		 */
		private function buildNode(node:DaeNode, parent:DisplayObject3D) : void 
		{
			var object : DisplayObject3D;
			var i : int;

			if(node.geometryInstances.length || node.controllerInstances.length) 
			{
				object = new TriangleMesh(null, node.name);
				
				buildGeometries(object as TriangleMesh, node);
			} 
			else 
			{
				object = new DisplayObject3D(node.name);
			}
			
			parent.addChild(object);

			for(i = 0; i < node.nodes.length; i++) 
			{
				buildNode(node.nodes[i], object);
			}
			
		//	object.transform.matrix3D = buildNodeMatrix(node);
			
			_objectToNode[object] = node;
			_nodeToObject[node] = object;
			
		//	buildAnimations(node);
		}
		
		/**
		 * Builds a primitive.
		 * 
		 * @param parent
		 * @param daePrimitive
		 * @param daeInstMaterial
		 * @param vertexStart
		 */
		private function buildPrimitive(parent : TriangleMesh, daePrimitive : DaePrimitive, 
										daeInstMaterial : DaeInstanceMaterial, vertexStart : uint) : void {
			var material : AbstractMaterial;
			var defaultTexCoordInput :DaeInput = (daePrimitive.texCoordInputs && daePrimitive.texCoordInputs.length) ? daePrimitive.texCoordInputs[0] : null;
			var uvIndices : Array = defaultTexCoordInput ? daePrimitive.uvSets[defaultTexCoordInput.setnum] : null;
			var uvs : Array = buildUV(daePrimitive, daeInstMaterial);
			var tri : Array;
			var uv : Array;
			var i : int;
			
			material = buildMaterial(daeInstMaterial);
			
			if(!material) 
			{
				var bmp : BitmapData = new BitmapData(512,512,false,0xFF0000);
				bmp.perlinNoise(64, 64, 5, 1, false, false);			
				material = new BitmapMaterial(bmp);
			}
			
			if(daePrimitive.triangles) 
			{
				for(i = 0; i < daePrimitive.triangles.length; i++) 
				{
					tri = daePrimitive.triangles[i];
					
					var v0 : Vertex = parent.triangleGeometry.vertices[vertexStart + tri[0]];
					var v1 : Vertex = parent.triangleGeometry.vertices[vertexStart + tri[1]];
					var v2 : Vertex = parent.triangleGeometry.vertices[vertexStart + tri[2]];
					var t0 : UVCoord;
					var t1 : UVCoord;
					var t2 : UVCoord;

					if(uvs && uvIndices && uvIndices.length == daePrimitive.triangles.length) 
					{
						uv = uvIndices[i];
						t0 = uvs[uv[0]];
						t1 = uvs[uv[1]];
						t2 = uvs[uv[2]];
					} 
					else 
					{
						t0 = new UVCoord();
						t1 = new UVCoord();
						t2 = new UVCoord();
					}
					
					parent.triangleGeometry.addTriangle(new Triangle(material.shader, v0, v1, v2, t0, t1, t2));
					
					_numTriangles++;
				}
			}
		}
		
		/**
		 * 
		 */
		private function buildScene():void
		{
			_objectToNode = new Dictionary(true);
			_nodeToObject = new Dictionary(true);
			_numVertices = 0;
			_numTriangles = 0;
			
			target.name = this.document.scene.name;
			
			buildNode(this.document.scene, target);
			
	//		linkControllers(_outputObject);
			
			var elapsed : Number = (getTimer() - _parseStartTime) / 1000;
			
			trace("parsed COLLADA scene '" + target.name + "' in about " + elapsed.toFixed(2) + " seconds.");
			trace(" -> #vertices : " + _numVertices);
			trace(" -> #triangles: " + _numTriangles);
		} 
		
		/**
		 * Builds uvs.
		 * 
		 * @param p
		 * @param im
		 * 
		 * @return Array of UVCoord
		 */
		private function buildUV(p:DaePrimitive, im:DaeInstanceMaterial) : Array 
		{
			var input : DaeInput = p.texCoordInputs && p.texCoordInputs.length ? p.texCoordInputs[0] : null;
			var source : DaeSource = input ? this.document.sources[input.source] : null;
			var uvs : Array;
			var i : int;
			
			if(im && im.bind_vertex_input && im.bind_vertex_input.length) 
			{
				
			}
			
			if(source) 
			{
				uvs = new Array();
				for(i = 0; i < source.data.length; i++) 
				{
					var data : Array = source.data[i];
					uvs.push(new UVCoord(data[0], 1- data[1]));
				}
			}

			return uvs;
		}
		
		/**
		 * Builds vertices for the specified TriangleMesh.
		 * 
		 * @param target
		 * @param mesh
		 */
		private function buildVertices(target:TriangleMesh, mesh:DaeMesh) : void 
		{
			var i : int;
			var data : Array = mesh.vertices.source.data;
			var v :Vertex;
			
			for(i = 0; i < data.length; i++) 
			{
				v = new Vertex(data[i][0], data[i][1], data[i][2]);	
				target.triangleGeometry.addVertex(v);
			}
			
			_numVertices += target.triangleGeometry.vertices.length;
		}
		
		/**
		 * 
		 */
		protected function parseXML(xml:XML):void
		{
			_parseStartTime = getTimer();
			
			this.document = new DaeDocument();
			
			for(var i:int = 0; i < _fileSearchPaths.length; i++) 
			{
				this.document.addFileSearchPath(_fileSearchPaths[i]);
			}
			
			this.document.addEventListener(Event.COMPLETE, onParseComplete);
			this.document.read(xml);	
		}
		
		/**
		 * 
		 */
		protected function onFileLoadComplete(event:Event):void 
		{
			var loader :URLLoader = event.target as URLLoader;
			
			parseXML(new XML(loader.data));
		}
		
		/**
		 * 
		 */
		protected function onFileLoadProgress(event:ProgressEvent):void
		{
			
		}
		
		/**
		 * 
		 */
		protected function onParseComplete(event:Event):void 
		{
			buildScene();
			
			dispatchEvent(event);
		}
	}
}
