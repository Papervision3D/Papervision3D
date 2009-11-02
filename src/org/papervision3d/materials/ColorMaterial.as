package org.papervision3d.materials
{
	import org.papervision3d.materials.shaders.ColorShader;
	import org.papervision3d.materials.textures.Texture;

	public class ColorMaterial extends Material
	{
		public function ColorMaterial(color:uint=0x2C6E91, alpha:Number=1, doubleSided:Boolean=false)
		{
			super(new Texture(color, alpha), new ColorShader(), doubleSided);
		}
		
	}
}