package org.papervision3d.materials.shaders
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	
	public class ColorShader extends AbstractShader
	{
		//This should be a graphicsSolidFill but i can't get the damn thing working!
		private var graphicsFill : GraphicsGradientFill;
		public function ColorShader()
		{
			super();
			this.drawProperties = new GraphicsStroke(0);
			(_drawProperties as GraphicsStroke).fill = graphicsFill = new GraphicsGradientFill("linear", [0xFFFFFF, 0x202020], [1,1], [0, 0xFF]);
			this.clear = new GraphicsStroke();
		}
		
		public override function get drawProperties():IGraphicsData{
			
			//graphicsFill.color = 0xFFFFFFFF;
			//graphicsFill.alpha = 1;
			return _drawProperties;
		}
		
	}
}