package org.papervision3d.core.render.raster
{
	import __AS3__.vec.Vector;
	
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.IDrawable;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.view.Viewport3D;
	
	public class DefaultRasterizer implements IRasterizer
	{
		public var drawArray:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		
		public function DefaultRasterizer()
		{
		}

		public function rasterize(renderData:RenderData):void{
			
			var hw :Number = renderData.viewport.viewportWidth / 2;
			var hh :Number = renderData.viewport.viewportHeight / 2;
			var drawable :IDrawable;
			var triangle :TriangleDrawable;
			var line :LineDrawable;
			
			drawArray.length = 0;
			renderData.viewport.containerSprite.graphics.clear();	

			for each (drawable in renderData.drawManager.drawables)
			{
				if (drawable is TriangleDrawable)
				{
					triangle = drawable as TriangleDrawable;
					triangle.toViewportSpace(hw, -hh);
					drawArray.push(triangle.shader.drawProperties, triangle.path, triangle.shader.clear);
				}
				else if (drawable is LineDrawable)
				{
					line = drawable as LineDrawable;	
					line.toViewportSpace(hw, -hh);
					drawArray.push(line.shader.drawProperties, line.path, line.shader.clear);
				}
			}

			renderData.viewport.containerSprite.graphics.drawGraphicsData(drawArray);
			
		}
	}
}