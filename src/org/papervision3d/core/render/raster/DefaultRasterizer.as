package org.papervision3d.core.render.raster
{
	import __AS3__.vec.Vector;
	
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	
	public class DefaultRasterizer implements IRasterizer
	{
		public var drawArray:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		
		public function DefaultRasterizer()
		{
		}

		public function rasterize(renderData:RenderData):void{
			
			var hw :Number = renderData.viewport.viewportWidth / 2;
			var hh :Number = renderData.viewport.viewportHeight / 2;
			var drawable : AbstractDrawable;
			var triangle :TriangleDrawable;
			var line :LineDrawable;
			
			drawArray.length = 0;
			renderData.viewport.containerSprite.graphics.clear();	

			for each (drawable in renderData.drawManager.drawables)
			{
				drawable.toViewportSpace(hw, -hh);
				drawArray.push(drawable.shader.drawProperties, drawable.path, drawable.shader.clear);
				
			}

			renderData.viewport.containerSprite.graphics.drawGraphicsData(drawArray);
			
		}
	}
}