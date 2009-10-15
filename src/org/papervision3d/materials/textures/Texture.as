package org.papervision3d.materials.textures
{
	public class Texture
	{
		public var color : uint = 0x66666666;
		public var alpha : Number = 1;
		
		public function Texture(color : uint = 0x666666, alpha : Number = 1)
		{
			this.color = color;
			this.alpha = alpha;
		}

		public function updateTexture():void{
			
		}
	}
}