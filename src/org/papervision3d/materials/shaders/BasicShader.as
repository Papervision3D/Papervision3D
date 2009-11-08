package org.papervision3d.materials.shaders
{
	import flash.display.BitmapData;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.materials.textures.Texture2D;

	public class BasicShader extends AbstractShader
	{
		protected var graphicsFill : GraphicsBitmapFill;
		protected var texture2D : Texture2D;
		public function BasicShader()
		{
			graphicsFill = new GraphicsBitmapFill();
			this.drawProperties = graphicsFill;
			this.clear = new GraphicsEndFill();
		}
		
		public override function get drawProperties():IGraphicsData{
			_outputBitmap = (texture as Texture2D).bitmap;
			graphicsFill.bitmapData = _outputBitmap;
			return _drawProperties;
		}
		
		public override function set texture(value:Texture):void{
			super.texture = value;
			texture2D = (value as Texture2D);
			bitmap = texture2D.bitmap;
			
			graphicsFill.bitmapData = bitmap;
		}
		public override function set bitmap(bitmapData:BitmapData):void{
			trace("setting bitmap");
			_baseBitmap  = bitmapData;
			_outputBitmap = bitmapData.clone();
		}

		
	}
}