package org.papervision3d.core.io.parser 
{
	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.ascollada.core.*;
	import org.ascollada.fx.*;
	import org.papervision3d.core.animation.keyframe.*;
	import org.papervision3d.core.animation.track.*;
	import org.papervision3d.core.controller.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip / Floorplanner.com
	 */
	public class DAEParser extends EventDispatcher 
	{	
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
		private var _bakeAnimations :Boolean;
		private var _bakeFrameDuration :Number;
		
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
		private function buildAnimations(node : DaeNode) : void 
		{
			if(!node.channels) 
			{
				return;
			}
			
			var target : DisplayObject3D = _nodeToObject[node];
			if(!target) 
			{
				trace("no target for node " + node.id);
				return;
			}
			
			var matrixStackTrack :MatrixStackTrack = buildMatrixStackTrack(node);
			var track : AbstractTrack = matrixStackTrack;
			
			if(matrixStackTrack) 
			{
				var controller :AnimationController = new AnimationController(target);
				if(_bakeAnimations) 
				{
					// bake!
					track = matrixStackTrack.bake(_bakeFrameDuration) || matrixStackTrack;
				} 
				controller.addTrack(track);
				
				target.controllers.unshift(controller);
			}
		}
		
		/**
		 * 
		 */
		private function buildMatrixStackTrack(node : DaeNode) : MatrixStackTrack 
		{
			var transform : DaeTransform;
			var channel : DaeChannel;
			var matrixStackTrack : MatrixStackTrack = new MatrixStackTrack();
			var i : int;
			
			for(i = 0; i < node.transforms.length; i++) 
			{
				var track :AbstractTrack;
				
				transform = node.transforms[i];	
				channel = node.getTransformChannelBySID(transform.sid);
				
				switch(transform.nodeName)
				{
					case "matrix":
						track = channel ? buildMatrixTrack(channel, transform) : new MatrixTrack();
						break;
					case "rotate":
						track = channel ? buildRotationTrack(channel, transform) : new RotationTrack();
						break;
					case "scale":
						track = channel ? buildScaleTrack(channel, transform) : new ScaleTrack();
						break;
					case "translate":
						track = channel ? buildTranslationTrack(channel, transform) : new TranslationTrack();
						break;
					default:
						trace("unhandled transform type : " + transform.nodeName);
						continue;
				}
				
				if(track) 
				{	
					if(!channel) 
					{
						track.addKeyframe(new NumberKeyframe3D(0, Vector.<Number>(transform.data.concat())));
					}
					matrixStackTrack.addTrack(track);	
					
					if(channel && channel.animation.clips) 
					{
						trace("CLIPS: " + channel.animation.id + " " + channel.animation.clips[0].id);	
					}
				}
			}
			
			return matrixStackTrack;
		}
		
		private function buildMatrixTrack(channel : DaeChannel, transform : DaeTransform) : MatrixTrack 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track : MatrixTrack = new MatrixTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;
			
			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : null;
				
				if(channel.type == DaeChannel.ARRAY_ACCESS) 
				{
					data = transform.data;
					if(channel.arrayIndex0 >= 0 && channel.arrayIndex1 >= 0) 
					{
						var idx : int = (channel.arrayIndex1 * 4) + channel.arrayIndex0;
						data[idx] = output[i];
					}
				}
				
				if(!data) 
				{
					trace("DAEParser#buildBakedMatrixTrack : invalid data!");
					continue;
				}
				var matrix : Matrix3D = new Matrix3D(Vector.<Number>(data));
				
				matrix.transpose();

				track.addKeyframe(new NumberKeyframe3D(time, matrix.rawData));
			}
			
			return track;
		}
		
		private function buildRotationTrack(channel:DaeChannel, transform:DaeTransform):RotationTrack 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track : RotationTrack = new RotationTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number>;
				
				switch(channel.targetMember) 
				{
					case "ANGLE":
						vdata = new Vector.<Number>(4);
						vdata[0] = transform.data[0];
						vdata[1] = transform.data[1];
						vdata[2] = transform.data[2];
						vdata[3] = data[0];
						track.addKeyframe(new NumberKeyframe3D(time, vdata));
						break;
					default:
						trace("unhandled channel " + channel);
						break;
				}
			}
			return track;
		}
		
		private function buildScaleTrack(channel:DaeChannel, transform:DaeTransform):ScaleTrack 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track : ScaleTrack = new ScaleTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number> = new Vector.<Number>(3);
				
				vdata[0] = transform.data[0];
				vdata[1] = transform.data[1];
				vdata[2] = transform.data[2];
						
				switch(channel.targetMember) {
					case "X":
						vdata[0] = data[0];
						break;
					case "Y":
						vdata[1] = data[0];
						break;
					case "Z":
						vdata[2] = data[0];
						break;
					default:
						trace("DAEParser#buildScaleTrack : unhandled " + channel);
						continue;
				}
				track.addKeyframe(new NumberKeyframe3D(time, vdata));
			}
			return track;
		}
		
		/**
		 * 
		 */
		private function buildTranslationTrack(channel:DaeChannel, transform:DaeTransform):TranslationTrack 
		{
			if(!channel.sampler || !channel.sampler.input || !channel.sampler.output) 
			{
				trace("invalid animation channel! " + channel.source + " " + channel.target);
				return null;
			}
			
			var track : TranslationTrack = new TranslationTrack();
			var input : Array = channel.sampler.input.data;
			var output : Array = channel.sampler.output.data;
			var i : int;

			for(i = 0; i < input.length; i++) 
			{
				var time : Number = input[i];
				var data : Array = output[i] is Array ? output[i] : [output[i]];
				var vdata : Vector.<Number> = new Vector.<Number>(3);
				
				vdata[0] = transform.data[0];
				vdata[1] = transform.data[1];
				vdata[2] = transform.data[2];
						
				switch(channel.targetMember) 
				{
					case "X":
						vdata[0] = data[0];
						break;
					case "Y":
						vdata[1] = data[0];
						break;
					case "Z":
						vdata[2] = data[0];
						break;
					default:
						if(channel.targetMember == null && data.length == 3) 
						{
							vdata = Vector.<Number>(data);
						} 
						else 
						{
							trace("DAEParser#buildTranslationTrack : unhandled " + channel);
							continue;
						}
						break;
				}
				track.addKeyframe(new NumberKeyframe3D(time, vdata));
			}
			return track;
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
		 * 
		 */
		private function buildModifiers(target:TriangleMesh, node : DaeNode) : void 
		{
			var controllerInstance : DaeInstanceController;
			var controller : DaeController;
			var i : int;
			
			for(i = 0; i < node.controllerInstances.length; i++) 
			{
				controllerInstance = node.controllerInstances[i];
				controller = this.document.controllers[ controllerInstance.url ]; 
				
				if(controller.skin) 
				{
				//	buildSkinModifier(target, controllerInstance);
				} 
				else if(controller.morph) 
				{
				//	buildMorphModifier(target, controllerInstance);
				}
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
			
			buildAnimations(node);
		}
		
		/**
		 * Builds a matrix for a node.
		 * 
		 * @param node
		 * 
		 * @return The created Matrix3D
		 */
		private function buildNodeMatrix(node : DaeNode) : Matrix3D 
		{
			var matrix : Matrix3D = new Matrix3D();
			var transform : DaeTransform;
			var i : int;
			
			for(i = 0; i < node.transforms.length; i++) 
			{
				transform = node.transforms[i];
				switch(transform.nodeName) 
				{
					case "rotate":
						var axis : Vector3D = new Vector3D(transform.data[0], transform.data[1], transform.data[2]);
						matrix.prependRotation(transform.data[3], axis);
						break;
					case "scale":
						matrix.prependScale(transform.data[0], transform.data[1], transform.data[2]);
						break;
					case "translate":
						matrix.prependTranslation(transform.data[0], transform.data[1], transform.data[2]);
						break;
					case "matrix":
						var m : Matrix3D = new Matrix3D(Vector.<Number>(transform.data));
						m.transpose();
						matrix.append(m);
						break;
					default:
						break;
				}
			}
			return matrix;
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
