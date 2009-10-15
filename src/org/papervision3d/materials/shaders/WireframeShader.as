package org.papervision3d.materials.shaders
{
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	
	public class WireframeShader extends AbstractShader
	{
		public function WireframeShader()
		{
			super();
			_drawProperties = new GraphicsStroke(1);
			(_drawProperties as GraphicsStroke).fill = new GraphicsSolidFill(0, 1);
			clear = new GraphicsStroke();
		}
		
		public override function get drawProperties():IGraphicsData{
			((_drawProperties as GraphicsStroke).fill as GraphicsSolidFill).color = _texture.color;
			return _drawProperties;
		}
	}
}