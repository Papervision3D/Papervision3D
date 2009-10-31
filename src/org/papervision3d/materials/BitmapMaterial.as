package org.papervision3d.materials
{
	import flash.display.BitmapData;
	
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.textures.Texture2D;
	
	public class BitmapMaterial extends Material
	{
		
		public function BitmapMaterial(bitmapData:BitmapData, doubleSided:Boolean = false)
		{
			super(new Texture2D(bitmapData), new BasicShader(), doubleSided);

		}

		
	}
}