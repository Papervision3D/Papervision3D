package org.papervision3d.materials.shaders
{
	import flash.display.BitmapData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.textures.Texture;

	public class AbstractShader implements IShader
	{
		protected var _texture : Texture;
		protected var _baseBitmap : BitmapData;
		protected var _outputBitmap : BitmapData;
		protected var _material : AbstractMaterial;
		
		public function AbstractShader()
		{
		}

		public function process(renderData:RenderData):void
		{
		}
		
		public function set texture(value:Texture):void{
			_texture = value;
		}
		
		public function set bitmap(bitmapData:BitmapData):void
		{
			_baseBitmap = bitmapData.clone();
			_outputBitmap = bitmapData.clone();
		}
		
		public function set material(value:AbstractMaterial) : void{
			
			_material = value;
			
		}
		
		public function get bitmap():BitmapData
		{
			return _outputBitmap;
		}
		
	}
}