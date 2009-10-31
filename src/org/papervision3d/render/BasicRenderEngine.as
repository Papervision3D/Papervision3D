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
			//(drawManager as DefaultDrawManager).drawList.sorter  = new NullDrawSorter();
			
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
			drawManager.currentDisplayObject = object;
			object.renderer.fillRenderList(camera, renderData, clipper, _drawablePool, _clipFlags);
			
			if(object.material)
				object.material.shader.process(renderData, object);	
				
			for each (child in object._children)
			{
				fillRenderList(camera, child);
			}
			
			drawManager.endDisplayObject();
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