package org.papervision3d.materials.shaders
{
	import flash.display.BitmapData;
	
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.materials.textures.Texture2D;

	public class BasicShader extends AbstractShader
	{
		public function BasicShader()
		{
		}
		
		public override function set texture(value:Texture):void{
			bitmap = (value as Texture2D).bitmap;
		}
		public override function set bitmap(bitmapData:BitmapData):void{
			_baseBitmap = _outputBitmap = bitmapData;
		}

		
	}
}