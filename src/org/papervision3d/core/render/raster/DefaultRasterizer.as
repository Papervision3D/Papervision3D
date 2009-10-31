package org.papervision3d.core.render.raster
{
	import __AS3__.vec.Vector;
	
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.list.AbstractDrawableList;
	
	public class DefaultRasterizer implements IRasterizer
	{
		public var drawArray:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
		private var stroke:GraphicsStroke = new GraphicsStroke(1);
		private var endStroke:GraphicsStroke = new GraphicsStroke();
		
		public function DefaultRasterizer()
		{
			stroke.fill = new GraphicsSolidFill(0x334059);
		}
		
		private var hw:Number;
		private var hh:Number;
		private var drawable:AbstractDrawable;
		
		public function rasterize(renderData:RenderData):void{
			
			hw = renderData.viewport.viewportWidth / 2;
			hh = renderData.viewport.viewportHeight / 2;
			
			drawArray.length = 0;
			renderData.viewport.containerSprite.graphics.clear();	

			drawDrawableList(renderData.drawManager.drawables);

			renderData.viewport.containerSprite.graphics.drawGraphicsData(drawArray);
			
		}
		
		protected function drawDrawableList(drawables:Vector.<AbstractDrawable>):void{
			for each (drawable in drawables)
			{
				if(drawable is AbstractDrawableList){
					//trace("drawing the list", (drawable as AbstractDrawableList).drawables.length);
					drawDrawableList((drawable as AbstractDrawableList).drawables);
				}else{
					drawable.toViewportSpace(hw, -hh);
					//drawArray.push(stroke, drawable.shader.drawProperties, drawable.path, drawable.shader.clear, endStroke);
					drawArray.push(drawable.shader.drawProperties, drawable.path, drawable.shader.clear);
				}
							
			}
		}
	}
}