package org.papervision3d.materials
{
	import flash.display.IGraphicsData;
	
	import org.papervision3d.materials.shaders.IShader;
	import org.papervision3d.materials.textures.Texture;
	
	public class AbstractMaterial
	{
		protected var _drawProperties:IGraphicsData;
		public var clear : IGraphicsData;
		
		public var texture : Texture;
		protected var _shader : IShader;
			
		public function AbstractMaterial()
		{
			
			
		}
		
		public function set drawProperties(value:IGraphicsData):void{
			_drawProperties = value;
		}
		
		public function get drawProperties():IGraphicsData{
			return null;
		}
				
		public function set shader(value:IShader):void{
			_shader = value;
			_shader.material = this;
		}
		
		public function get shader():IShader{
			return _shader;
		}
		
		

	}
}