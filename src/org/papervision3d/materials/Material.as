package org.papervision3d.materials
{
	import org.papervision3d.materials.shaders.IShader;
	import org.papervision3d.materials.textures.Texture;
	
	public class Material extends AbstractMaterial
	{
		public function Material(texture:Texture, shader:IShader, doubleSided:Boolean = false)
		{
			super();
			this.texture = texture;
			this.shader = shader;
			this.doubleSided = doubleSided;
		}
		
	}
}