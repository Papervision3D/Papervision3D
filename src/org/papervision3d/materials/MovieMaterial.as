package org.papervision3d.materials
{
	import flash.display.DisplayObject;
	
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.textures.AnimatedTexture;
	
	public class MovieMaterial extends Material
	{
		public function MovieMaterial(texture:DisplayObject, transparent:Boolean = false, doubleSided:Boolean = false)
		{
			super(new AnimatedTexture(texture, transparent), new BasicShader(), doubleSided);
		}
		
	}
}