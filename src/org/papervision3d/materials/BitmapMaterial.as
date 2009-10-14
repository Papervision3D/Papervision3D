package org.papervision3d.materials
{
	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	
	public class BitmapMaterial extends AbstractMaterial
	{
		public function BitmapMaterial(bitmapData:BitmapData)
		{
			super();
			
			var graphicsFill : GraphicsBitmapFill = new GraphicsBitmapFill(bitmapData);
			this.drawProperties = graphicsFill;
			this.clear = new GraphicsEndFill();
		}
		
	}
}