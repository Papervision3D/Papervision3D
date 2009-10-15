package org.papervision3d.materials.textures
{
	import flash.utils.Dictionary;
	
	public class TextureManager
	{
		protected static var textureDictionary : Dictionary = new Dictionary(true);;
		
		public function TextureManager()
		{
			textureDictionary = new Dictionary(true);
		}
		
		public static function addTexture(texture:Texture):Texture{
			textureDictionary[texture] = texture;
			return texture;
		}
		
		public static function updateTextures():void{
			for each(var t:Texture in textureDictionary){
				t.update();
			}
				
		}

	}
}