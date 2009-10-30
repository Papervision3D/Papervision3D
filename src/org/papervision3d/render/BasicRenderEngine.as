package org.papervision3d.render
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
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
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.core.render.draw.manager.DefaultDrawManager;
	import org.papervision3d.core.render.draw.sort.NullDrawSorter;
	import org.papervision3d.core.render.engine.AbstractRenderEngine;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.core.render.raster.DefaultRasterizer;
	import org.papervision3d.core.render.raster.IRasterizer;
	import org.papervision3d.materials.textures.TextureManager;
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
		public var drawManager : DefaultDrawManager;
		
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
			drawManager = new DefaultDrawManager();
			(drawManager as DefaultDrawManager).drawList.sorter  = new NullDrawSorter();
			
			clipper = new SutherlandHodgmanClipper();
			rasterizer = new DefaultRasterizer();
			renderData = new RenderData();
			stats = new RenderStats();
		
			
			_clipFlags = ClipFlags.ALL;
			
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
			renderData.drawManager = drawManager;
			
			renderData.lights.clear();
			
			TextureManager.updateTextures();
			camera.update(renderData.viewport.sizeRectangle);
						
			pipeline.execute(renderData);
 
 			drawManager.reset();
 			stats.clear();
 			
 			_drawablePool.reset();
 			
			fillRenderList(camera, scene);
			
			drawManager.handleList();
			
			rasterizer.rasterize(renderData);
		}
		
			/**
		 * Fills our renderlist.
		 * <p>Get rid of triangles behind the near plane, clip straddling triangles if needed.</p>
		 * 
		 * @param	camera
		 * @param	object
		 */ 
		
		private function fillRenderList(camera:Camera3D, object:DisplayObject3D):void{
			
			var child :DisplayObject3D;
			object.renderer.fillRenderList(camera, renderData, clipper, _drawablePool, _clipFlags);
			
			if(object.material)
				object.material.shader.process(renderData, object);	
				
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
			var uvtData :Vector.<Number> = renderer.uvtData;
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
				drawable.shader = triangle.shader;
				
				drawManager.addDrawable(drawable);
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