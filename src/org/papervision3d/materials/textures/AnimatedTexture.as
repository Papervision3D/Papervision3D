package org.papervision3d.materials.textures
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class AnimatedTexture extends Texture2D
	{
		private var drawItem : DisplayObject;
		public function AnimatedTexture(drawItem:DisplayObject, transparent:Boolean = false)
		{
			_bitmap = new BitmapData(drawItem.width, drawItem.height, transparent);
			_bitmap.draw(drawItem);
			this.drawItem = drawItem;
			super(bitmap);
		}
		
		public override function update():void{
			
			_bitmap.fillRect(_bitmap.rect, 0 );
			_bitmap.draw(drawItem);
		}
		
	}
}