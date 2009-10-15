package org.papervision3d.materials.textures
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class Texture2D extends Texture
	{
		public var uvRect : Rectangle;
		protected var _bitmap : BitmapData;
		public function Texture2D(bitmap:BitmapData)
		{
			super();
			this._bitmap = bitmap;
		}
		
		public function get bitmap():BitmapData{
			return _bitmap;	
		}
		
		
		

	}
}