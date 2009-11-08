package org.papervision3d.materials.shaders
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.materials.textures.Texture;
	
	/** 
	 * @author: andy zupko / zupko.info
	 **/
	public class ColorShader extends AbstractShader
	{
		
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