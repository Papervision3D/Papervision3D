package org.papervision3d.materials
{
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	
	public class WireframeMaterial extends AbstractMaterial
	{
		public function WireframeMaterial(color:uint = 0xFF00FF)
		{
			super();
			drawProperties = new GraphicsStroke(1);
			(drawProperties as GraphicsStroke).fill = new GraphicsSolidFill(color, 1);
			clear = new GraphicsStroke();
		}
		
	}
}