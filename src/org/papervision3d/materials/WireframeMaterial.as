package org.papervision3d.materials
{
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	
	public class WireframeMaterial extends AbstractMaterial
	{
		public function WireframeMaterial(color:uint = 0xFF00FF)
		{
			super();
			_drawProperties = new GraphicsStroke(1);
			(_drawProperties as GraphicsStroke).fill = new GraphicsSolidFill(color, 1);
			clear = new GraphicsStroke();
		}
		
	}
}