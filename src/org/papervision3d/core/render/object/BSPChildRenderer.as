package org.papervision3d.core.render.object
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.objects.DisplayObject3D;

	public class BSPChildRenderer extends ObjectRenderer
	{
		public function BSPChildRenderer(obj:DisplayObject3D)
		{
			this.geometry = obj.renderer.geometry;
			super(obj);
			
		}
		public override function fillRenderList(camera:Camera3D, renderData:RenderData, clipper:IPolygonClipper, drawablePool:DrawablePool, _clipFlags:uint):void{
			return;
		}	
	}
}