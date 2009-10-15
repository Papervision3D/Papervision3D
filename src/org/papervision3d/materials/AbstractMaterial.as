package org.papervision3d.materials
{
	import org.papervision3d.materials.shaders.IShader;
	import org.papervision3d.materials.textures.Texture;
	
	public class AbstractMaterial
	{
			
		protected var _texture : Texture;
		protected var _shader : IShader;
			
		public function AbstractMaterial()
		{
			
			
		}
				
				
		public function set texture(value:Texture):void{
			_texture = value;
			if(_shader)
				_shader.texture = _texture;
		}		
		
		public function get texture():Texture{
			return _texture;
		}
				
		public function set shader(value:IShader):void{
			_shader = value;
			_shader.material = this;
			if(_texture)
				_shader.texture = _texture;
		}
		
		public function get shader():IShader{
			return _shader;
		}
		
		

	}
}