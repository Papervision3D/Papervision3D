package org.papervision3d.materials
{
	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.textures.Texture2D;
	
	public class BitmapMaterial extends AbstractMaterial
	{
		protected var graphicsFill : GraphicsBitmapFill;
		public function BitmapMaterial(bitmapData:BitmapData)
		{
			super();
			this.texture = new Texture2D(bitmapData);
			this.shader = new BasicShader();
			this.shader.texture = texture;
			
			
			graphicsFill = new GraphicsBitmapFill(bitmapData);
			this.drawProperties = graphicsFill;
			this.clear = new GraphicsEndFill();
		}
		
		public override function get drawProperties():IGraphicsData{
			graphicsFill.bitmapData = this.shader.bitmap;
			return _drawProperties;
		}
		
	}
}