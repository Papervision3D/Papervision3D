package org.papervision3d.materials
{
	import org.papervision3d.materials.shaders.WireframeShader;
	import org.papervision3d.materials.textures.Texture;
	
	public class WireframeMaterial extends Material
	{
		public function WireframeMaterial(color:uint = 0xFF00FF, alpha:Number = 1)
		{
			
			super(new Texture(), new WireframeShader());
			texture.color = color;
			texture.alpha = 1;	
			
			
		}
		
	}
}