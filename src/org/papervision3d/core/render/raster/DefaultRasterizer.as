package org.papervision3d.core.render.raster
{
	import __AS3__.vec.Vector;
	
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.draw.items.IDrawable;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.IDrawableList;
	import org.papervision3d.view.Viewport3D;
	
	public class DefaultRasterizer implements IRasterizer
	{
		public var drawArray:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		
		public function DefaultRasterizer()
		{
		}

		public function rasterize(renderList:IDrawableList, viewport:Viewport3D):void{
			
			var hw :Number = viewport.viewportWidth / 2;
			var hh :Number = viewport.viewportHeight / 2;
			var drawable :IDrawable;
			var triangle :TriangleDrawable;
			var line :LineDrawable;
			
			drawArray.length = 0;
			viewport.containerSprite.graphics.clear();	

			for each (drawable in renderList.drawables)
			{
				if (drawable is TriangleDrawable)
				{
					triangle = drawable as TriangleDrawable;
					triangle.toViewportSpace(hw, -hh);
					drawArray.push(triangle.material.drawProperties, triangle.path, triangle.material.clear);
				}
				else if (drawable is LineDrawable)
				{
					line = drawable as LineDrawable;	
					line.toViewportSpace(hw, -hh);
					drawArray.push(line.material.drawProperties, line.path, line.material.clear);
				}
			}

			viewport.containerSprite.graphics.drawGraphicsData(drawArray);
			
		}
	}
}