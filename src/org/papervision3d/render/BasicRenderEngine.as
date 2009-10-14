package org.papervision3d.render
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Line;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.math.Frustum3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.clipping.SutherlandHodgmanClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.core.render.draw.sort.DefaultDrawSorter;
	import org.papervision3d.core.render.engine.AbstractRenderEngine;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.core.render.raster.DefaultRasterizer;
	import org.papervision3d.core.render.raster.IRasterizer;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;

	/**
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class BasicRenderEngine extends AbstractRenderEngine
	{
		use namespace pv3d;
		
		public var renderList :IDrawableList;
		public var clipper :IPolygonClipper;
		public var viewport :Viewport3D;
		public var rasterizer : IRasterizer;
		public var geometry :TriangleGeometry;
		public var renderData :RenderData;
		public var stats :RenderStats;
		public var renderer : ObjectRenderer;
		
		private var _clipFlags :uint;
		
		private var _drawablePool :DrawablePool;
		
		/**
		 * 
		 */ 	
		public function BasicRenderEngine()
		{
			super();
			init();
		}
		
		/**
		 * 
		 */ 
		protected function init():void
		{
			pipeline = new BasicPipeline();
			renderList = new DrawableList();
			renderList.sorter = new DefaultDrawSorter();
			
			clipper = new SutherlandHodgmanClipper();
			rasterizer = new DefaultRasterizer();
			renderData = new RenderData();
			stats = new RenderStats();
			
			_clipFlags = ClipFlags.NEAR;
			
			_drawablePool = new DrawablePool(TriangleDrawable);
		}
		
		/**
		 * 
		 */ 
		override public function renderScene(scene:DisplayObject3D, camera:Camera3D, viewport:Viewport3D):void
		{	
			renderData.scene = scene;
			renderData.camera = camera;
			renderData.viewport = viewport;
			renderData.stats = stats;
			
			camera.update(renderData.viewport.sizeRectangle);
						
			pipeline.execute(renderData);
 
 			renderList.clear();
 			stats.clear();
 			
 			_drawablePool.reset();
 			
			fillRenderList(camera, scene);
			renderList.sorter.sort();
			rasterizer.rasterize(renderList, renderData.viewport);
		}
		
		/**
		 * Fills our renderlist.
		 * <p>Get rid of triangles behind the near plane, clip straddling triangles if needed.</p>
		 * 
		 * @param	camera
		 * @param	object
		 */ 
		private function fillRenderList(camera:Camera3D, object:DisplayObject3D):void 
		{
			var child :DisplayObject3D;
			var clipPlanes :Vector.<Plane3D> = camera.frustum.viewClippingPlanes;
			var v0 :Vector3D = new Vector3D();
			var v1 :Vector3D = new Vector3D();
			var v2 :Vector3D = new Vector3D();
			var sv0 :Vector3D = new Vector3D();
			var sv1 :Vector3D = new Vector3D();
			var sv2 :Vector3D = new Vector3D();
		
			renderer = object.renderer;	
			stats.totalObjects++;
			
			if (object.cullingState == 0 && object.renderer.geometry is TriangleGeometry)
			{
				var triangle :Triangle;
				var inside :Boolean;
				var flags :int = 0;
				
				geometry = object.renderer.geometry as TriangleGeometry;
				
				for each (triangle in geometry.triangles)
				{
					triangle.clipFlags = 0;
					triangle.visible = false;
					
					stats.totalTriangles++;
					
					// get vertices in view / camera space
					v0.x = renderer.viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = renderer.viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = renderer.viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = renderer.viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = renderer.viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = renderer.viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = renderer.viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = renderer.viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = renderer.viewVertexData[ triangle.v2.vectorIndexZ ];
					
					// Setup clipflags for the triangle (detect whether the tri is in, out or straddling 
					// the frustum).
					// First test the near plane, as verts behind near project to infinity.
					if (_clipFlags & ClipFlags.NEAR)
					{
						flags = getClipFlags(clipPlanes[Frustum3D.NEAR], v0, v1, v2);
						if (flags == 7 ) { stats.culledTriangles++; continue; }
						else if (flags) { triangle.clipFlags |= ClipFlags.NEAR; }
					}
					
					// passed the near test loosely, verts may have projected to infinity
					// we do it here, cause - paranoia - even these array accesses may cost us
					sv0.x = renderer.screenVertexData[ triangle.v0.screenIndexX ];	
					sv0.y = renderer.screenVertexData[ triangle.v0.screenIndexY ];
					sv1.x = renderer.screenVertexData[ triangle.v1.screenIndexX ];	
					sv1.y = renderer.screenVertexData[ triangle.v1.screenIndexY ];
					sv2.x = renderer.screenVertexData[ triangle.v2.screenIndexX ];	
					sv2.y = renderer.screenVertexData[ triangle.v2.screenIndexY ];
					
					// When *not* straddling the near plane we can safely test for backfacing triangles 
					// (as we're sure the infinity case is filtered out).
					// Hence we can have an early out by a simple backface test.
					if (triangle.clipFlags != ClipFlags.NEAR)
					{
						if ((sv2.x - sv0.x) * (sv1.y - sv0.y) - (sv2.y - sv0.y) * (sv1.x - sv0.x) > 0)
						{
							stats.culledTriangles ++;
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
						drawable.uvtData[2] = renderer.geometry.uvtData[ triangle.v0.vectorIndexZ ];
						drawable.uvtData[3] = triangle.uv1.u;
						drawable.uvtData[4] = triangle.uv1.v;
						drawable.uvtData[5] = renderer.geometry.uvtData[ triangle.v1.vectorIndexZ ];
						drawable.uvtData[6] = triangle.uv2.u;
						drawable.uvtData[7] = triangle.uv2.v;
						drawable.uvtData[8] = renderer.geometry.uvtData[ triangle.v2.vectorIndexZ ];
						drawable.material = triangle.material;
						//trace(renderer.geometry.uvtData);
						renderList.addDrawable(drawable);
						
						triangle.drawable = drawable;
					}
					else
					{
						// Triangle straddles some plane of the (view) camera frustum, we need clip 'm
						clipViewTriangle(camera, triangle, v0, v1, v2);
					}	
				}
			}
			else if (object.cullingState == 0 && object.renderer.geometry is LineGeometry)
			{
				var lineGeometry:LineGeometry = LineGeometry(object.renderer.geometry);
				var line :Line;
					
				for each (line in lineGeometry.lines)
				{
					var lineDrawable :LineDrawable = line.drawable as LineDrawable || new LineDrawable();
					
					sv0.x = renderer.screenVertexData[ line.v0.screenIndexX ];	
					sv0.y = renderer.screenVertexData[ line.v0.screenIndexY ];
					sv1.x = renderer.screenVertexData[ line.v1.screenIndexX ];	
					sv1.y = renderer.screenVertexData[ line.v1.screenIndexY ];
				
					lineDrawable.x0 = sv0.x;
					lineDrawable.y0 = sv0.y;
					lineDrawable.x1 = sv1.x;
					lineDrawable.y1 = sv1.y;
					lineDrawable.screenZ = (renderer.viewVertexData[line.v0.vectorIndexZ]+renderer.viewVertexData[line.v1.vectorIndexZ])*0.5;
					lineDrawable.material = line.material;
					
					renderList.addDrawable(lineDrawable);
				}
			}
				
			// Recurse
			for each (child in object._children)
			{
				fillRenderList(camera, child);
			}
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
		private function clipViewTriangle(camera:Camera3D, triangle:Triangle, v0:Vector3D, v1:Vector3D, v2:Vector3D):void
		{		
			var plane :Plane3D = camera.frustum.viewClippingPlanes[ Frustum3D.NEAR ];
			var inV :Vector.<Number> = Vector.<Number>([v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z]);
			var outV :Vector.<Number> = new Vector.<Number>();
			var outUVT :Vector.<Number> = new Vector.<Number>();
			var uvtData :Vector.<Number> = renderer.geometry.uvtData;
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
			
			if (triangle.clipFlags & ClipFlags.FAR)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.FAR ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.LEFT)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.LEFT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.RIGHT)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.RIGHT ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.TOP)
			{
				plane = camera.frustum.viewClippingPlanes[ Frustum3D.TOP ];
				outV = new Vector.<Number>();
				outUVT = new Vector.<Number>();
				clipper.clipPolygonToPlane(inV, inUVT, outV, outUVT, plane);
				inV = outV;
				inUVT = outUVT;
			}
			
			if (triangle.clipFlags & ClipFlags.BOTTOM)
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
				
				if ((v2.x - v0.x) * (v1.y - v0.y) - (v2.y - v0.y) * (v1.x - v0.x) > 0)
				{
					stats.culledTriangles ++;
					continue;
				}
				
				var drawable :TriangleDrawable = _drawablePool.drawable as TriangleDrawable;
							
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
				drawable.material = triangle.material;
				
				renderList.addDrawable(drawable);
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