package org.papervision3d.materials
{
	import org.papervision3d.materials.shaders.WireframeShader;
	import org.papervision3d.materials.textures.Texture;
	
	public class WireframeMaterial extends AbstractMaterial
	{
		public function WireframeMaterial(color:uint = 0xFF00FF)
		{
			super();
			shader = new WireframeShader();
			texture = new Texture();
			texture.color = color;
			
		}
		
	}
}