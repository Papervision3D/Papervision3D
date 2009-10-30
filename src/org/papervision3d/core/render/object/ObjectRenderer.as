package org.papervision3d.core.render.object
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.BSP.BSPTree;
	import org.papervision3d.core.geom.Line;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.math.Frustum3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class ObjectRenderer
	{
		public var geometry : VertexGeometry;
		public var viewVertexData :Vector.<Number>;
		public var screenVertexData :Vector.<Number>;
		public var uvtData : Vector.<Number>;
		protected var object : DisplayObject3D;
		public var renderList : Vector.<Triangle>;
		
			
		public function ObjectRenderer(obj:DisplayObject3D)
		{
			this.object = obj;
			renderList = new Vector.<Triangle>();	
			viewVertexData = new Vector.<Number>();
			screenVertexData = new Vector.<Number>();
			uvtData = new Vector.<Number>();
				
		}
		
		public function updateIndices():void{
			//trace(geometry, "in updateIndices");
			viewVertexData.length = geometry.viewVertexLength;
			screenVertexData.length = geometry.screenVertexLength;
			uvtData.length = geometry.viewVertexLength;
			
		}
		
		
		private var _clipFlags :uint;

		public function fillRenderList(camera:Camera3D, renderData:RenderData, clipper:IPolygonClipper, drawablePool:DrawablePool ):void 
		{
			use namespace pv3d;
			var stats : RenderStats = renderData.stats;
			var child :DisplayObject3D;
			var clipPlanes :Vector.<Plane3D> = camera.frustum.viewClippingPlanes;
			var v0 :Vector3D = new Vector3D();
			var v1 :Vector3D = new Vector3D();
			var v2 :Vector3D = new Vector3D();
			var sv0 :Vector3D = new Vector3D();
			var sv1 :Vector3D = new Vector3D();
			var sv2 :Vector3D = new Vector3D();
		
			
			stats.totalObjects++;
			
			
			if(object is BSPTree){
				//walk the tree!
				(object as BSPTree).walkTree(camera, renderData);
				return;
			}
			
			
			
			
			if (object.cullingState == 0 && geometry is TriangleGeometry)
			{
				var triangle :Triangle;
				var inside :Boolean;
				var flags :int = 0;

				var tris:Vector.<Triangle> = renderList ? renderList : (geometry as TriangleGeometry).triangles;
			//trace(tris.length, geometry.triangles.length);
				for each (triangle in tris)
				{
					triangle.clipFlags = triangle.cullFlags = 0;
					triangle.visible = false;
					
					stats.totalTriangles++;
					
					// get vertices in view / camera space
					v0.x = viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = viewVertexData[ triangle.v2.vectorIndexZ ];
					
					// Setup clipflags for the triangle (detect whether the tri is in, out or straddling 
					// the frustum).
					// First test the near plane, as verts behind near project to infinity.
					if (_clipFlags & ClipFlags.NEAR)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.NEAR], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; triangle.cullFlags = 1; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.NEAR; }
					}
					
					// passed the near test loosely, verts may have projected to infinity
					// we do it here, cause - paranoia - even these array accesses may cost us
					sv0.x = screenVertexData[ triangle.v0.screenIndexX ];	
					sv0.y = screenVertexData[ triangle.v0.screenIndexY ];
					sv1.x = screenVertexData[ triangle.v1.screenIndexX ];	
					sv1.y = screenVertexData[ triangle.v1.screenIndexY ];
					sv2.x = screenVertexData[ triangle.v2.screenIndexX ];	
					sv2.y = screenVertexData[ triangle.v2.screenIndexY ];
					
					// When *not* straddling the near plane we can safely test for backfacing triangles 
					// (as we're sure the infinity case is filtered out).
					// Hence we can have an early out by a simple backface test.
					if (triangle.clipFlags != ClipFlags.NEAR)
					{
						if ((sv2.x - sv0.x) * (sv1.y - sv0.y) - (sv2.y - sv0.y) * (sv1.x - sv0.x) > 0)
						{
						//	stats.culledTriangles ++;
							//triangle.clipFlags = 128;
						
							continue;
						}
					}
					
					// Okay, all vertices are in front of the near plane and backfacing tris are gone.
					// Continue setting up clipflags
					if (_clipFlags & ClipFlags.FAR)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.FAR], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.FAR; }
					}
					
					if (_clipFlags & ClipFlags.LEFT)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.LEFT], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.LEFT; }
					}
					
					if (_clipFlags & ClipFlags.RIGHT)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.RIGHT], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.RIGHT; }
					}
					
					if (_clipFlags & ClipFlags.TOP)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.TOP], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.TOP; }
					}
					
					if (_clipFlags & ClipFlags.BOTTOM)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.BOTTOM], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.BOTTOM };
					}
						
					if (triangle.clipFlags == 0)
					{
						// Triangle completely inside the (view) frustum
						var drawable :TriangleDrawable = triangle.drawable as TriangleDrawable || new TriangleDrawable();
						
						drawable.screenZ = (v0.z + v1.z + v2.z) / 3;
						
						drawable.x0 = sv0.x;
						drawable.y0 = sv0.y;
						drawable.x1 = sv1.x;
						drawable.y1 = sv1.y;
						drawable.x2 = sv2.x;
						drawable.y2 = sv2.y;
						
						drawable.uvtData = drawable.uvtData || new Vector.<Number>(9, true);
						drawable.uvtData[0] = triangle.uv0.u;
						drawable.uvtData[1] = triangle.uv0.v;
						drawable.uvtData[2] = uvtData[ triangle.v0.vectorIndexZ ];
						drawable.uvtData[3] = triangle.uv1.u;
						drawable.uvtData[4] = triangle.uv1.v;
						drawable.uvtData[5] = uvtData[ triangle.v1.vectorIndexZ ];
						drawable.uvtData[6] = triangle.uv2.u;
						drawable.uvtData[7] = triangle.uv2.v;
						drawable.uvtData[8] = uvtData[ triangle.v2.vectorIndexZ ];
						drawable.shader = triangle.shader;
						//trace(renderer.geometry.uvtData);
						renderData.drawManager.addDrawable(drawable);
						
						triangle.drawable = drawable;
					}
					else
					{
						// Triangle straddles some plane of the (view) camera frustum, we need clip 'm
						clipViewTriangle(camera, triangle, v0, v1, v2, renderData, clipper, drawablePool);
					}	
				}
			}
			
			
			
			
			// Recurse
			
		}
		
		
		/**
		 * Clips a triangle in view / camera space. Typically used for the near and far planes.
		 * 
		 * @param	camera
		 * @param	triangle
		 * @param	v0
		 * @param	v1
		 * @param 	v2
		 */ 
		private function clipViewTriangle(camera:Camera3D, triangle:Triangle, v0:Vector3D, v1:Vector3D, v2:Vector3D, renderData:RenderData, clipper:IPolygonClipper, drawablePool:DrawablePool):void
		{		
			use namespace pv3d;
			var stats : RenderStats = renderData.stats;
			var plane :Plane3D = camera.frustum.viewClippingPlanes[ Frustum3D.NEAR ];
			var inV :Vector.<Number> = Vector.<Number>([v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z]);
			var outV :Vector.<Number> = new Vector.<Number>();
			var outUVT :Vector.<Number> = new Vector.<Number>();
			var uvtData :Vector.<Number> = uvtData;
			var inUVT :Vector.<Number> = Vector.<Number>([
				triangle.uv0.u, triangle.uv0.v, 0,
				triangle.uv1.u, triangle.uv1.v, 0,
				triangle.uv2.u, triangle.uv2.v, 0
			]);
			
			stats.clippedTriangles++;
			
			if (triangle.clipFlags & ClipFlags.NEAR)
			{
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.FAR && inV.length > 0)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.FAR ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.LEFT && inV.length > 0)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.LEFT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.RIGHT && inV.length > 0)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.RIGHT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.TOP && inV.length > 0)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.TOP ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.BOTTOM && inV.length > 0)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.BOTTOM ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			Utils3D.projectVectors(camera.projectionMatrix, inV, outV, inUVT);
			
			var numTriangles : int = 1 + ((inV.length / 3)-3);
			var i:int, i2 :int, i3 :int;

			stats.totalTriangles += numTriangles - 1;
			
			for(i = 0; i < numTriangles; i++)
			{
				i2 = i * 2;
				i3 = i * 3; 
				
				v0.x = outV[0];
				v0.y = outV[1];
				v1.x = outV[i2+2];
				v1.y = outV[i2+3];
				v2.x = outV[i2+4];
				v2.y = outV[i2+5];
				
				if (!triangle.shader.doubleSided && (v2.x - v0.x) * (v1.y - v0.y) - (v2.y - v0.y) * (v1.x - v0.x) > 0)
				{
					stats.culledTriangles ++;
					continue;
				}
				
				var drawable :TriangleDrawable = drawablePool.drawable as TriangleDrawable;
							
				drawable.x0 = v0.x;
				drawable.y0 = v0.y;
				drawable.x1 = v1.x;
				drawable.y1 = v1.y;
				drawable.x2 = v2.x;
				drawable.y2 = v2.y;
				
				drawable.uvtData = drawable.uvtData || new Vector.<Number>(9, true);

				drawable.uvtData[0] = inUVT[0];
				drawable.uvtData[1] = inUVT[1];
				drawable.uvtData[2] = inUVT[2];
				drawable.uvtData[3] = inUVT[i3+3];
				drawable.uvtData[4] = inUVT[i3+4];
				drawable.uvtData[5] = inUVT[i3+5];
				drawable.uvtData[6] = inUVT[i3+6];
				drawable.uvtData[7] = inUVT[i3+7];
				drawable.uvtData[8] = inUVT[i3+8];
					
				drawable.screenZ = (inV[2]+inV[i3+5]+inV[i3+8])/3;
				drawable.shader = triangle.shader;
				
				renderData.drawManager.addDrawable(drawable);
			}
		}
		
		/**
		 * 
		 */ 
		private function getClipFlags(plane:Plane3D, v0:Vector3D, v1:Vector3D, v2:Vector3D):int
		{
			var flags :int = 0;
			if ( plane.distance(v0) < 0 ) flags |= 1;
			if ( plane.distance(v1) < 0 ) flags |= 2;
			if ( plane.distance(v2) < 0 ) flags |= 4;
			return flags;
		}
		
		/**
		 * Clip flags.
		 * 
		 * @see org.papervision3d.core.render.clipping.ClipFlags
		 */
		public function get clipFlags():int
		{
			return _clipFlags;
		}
		
		public function set clipFlags(value:int):void
		{
			if (value >= 0 && value <= ClipFlags.ALL)
			{
				_clipFlags = value;
			}
			else
			{
				throw new IllegalOperationError("clipFlags should be a value between 0 and " + ClipFlags.ALL + "\nsee org.papervision3d.core.render.clipping.ClipFlags");
			}
		}


	}
}