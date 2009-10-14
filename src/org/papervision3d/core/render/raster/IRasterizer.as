package org.papervision3d.core.render.raster
{
	import org.papervision3d.core.render.data.RenderData;
	
	public interface IRasterizer
	{
		function rasterize(renderData:RenderData):void;
	
	}
}