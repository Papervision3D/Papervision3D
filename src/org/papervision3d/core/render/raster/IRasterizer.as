package org.papervision3d.core.render.raster
{
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.view.Viewport3D;
	
	public interface IRasterizer
	{
		function rasterize(renderList:IDrawableList, viewport:Viewport3D):void;
	
	}
}