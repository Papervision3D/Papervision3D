package org.papervision3d.materials.shaders
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	
	public class ColorShader extends AbstractShader
	{
		//This should be a graphicsSolidFill but i can't get the damn thing working!
		private var graphicsFill : GraphicsSolidFill;
		public function ColorShader()
		{
			super();
			_usesUV = false;
			this.drawProperties = graphicsFill = new GraphicsSolidFill(0, 1);
			this.clear = new GraphicsEndFill();
		}
		
		public override function get drawProperties():IGraphicsData{
			graphicsFill.color = _texture.color;
			graphicsFill.alpha = _texture.alpha;
			return _drawProperties;
		}
		
	}
}