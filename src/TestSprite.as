package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class TestSprite extends Sprite
	{
		private var bitmap:BitmapData;
		public function TestSprite()
		{
			super();
			bitmap = new BitmapData(128, 128, false);
			addChild(new Bitmap(bitmap));
			addEventListener(Event.ENTER_FRAME, handleFrame);
		}
		
		private var offsets:Point = new Point();
		private function handleFrame(e:Event):void{
			
			bitmap.perlinNoise(16, 56, 1, 40403, false, true, 7, false, [offsets]);
			offsets.x += 4;
			offsets.y -= 6;
		}
		
	}
}