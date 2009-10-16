package org.papervision3d.materials.shaders.light
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.materials.textures.Texture2D;
	
	public class AbstractLightShader extends BasicShader
	{
		protected var _overlayTexture:BitmapData;
		protected var _overlayBitmap : Bitmap;
		protected var _drawContext : Sprite;
		
		public function AbstractLightShader()
		{
			super();
			_overlayBitmap = new Bitmap();
			_drawContext = new Sprite();
		}

		public override function set texture(value:Texture):void{
			super.texture = value;
			
			if(_texture is Texture2D){
				var t2d:Texture2D = _texture as Texture2D;
				_overlayTexture = new BitmapData(t2d.bitmap.width, t2d.bitmap.height, false, 0);
				_overlayBitmap.bitmapData = _overlayTexture;
			}
		}

	}
}