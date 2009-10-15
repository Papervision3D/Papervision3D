package org.papervision3d.materials.textures
{
	import flash.utils.Dictionary;
	
	public class TextureManager
	{
		protected var textureDictionary : Dictionary;
		
		public function TextureManager()
		{
			textureDictionary = new Dictionary(true);
		}
		
		public function addTexture(texture:Texture):Texture{
			textureDictionary[texture] = texture;
			return texture;
		}
		
		public function updateTextures():void{
			for each(var t:Texture in textureDictionary){
				t.update();
			}
				
		}
		
		private static var _instance:TextureManager;
		public static function getInstance():TextureManager{
			if(!_instance)
				_instance = new TextureManager();
			return _instance;
		}
	}
}