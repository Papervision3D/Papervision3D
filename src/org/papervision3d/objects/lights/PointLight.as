package org.papervision3d.objects.lights
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class PointLight extends DisplayObject3D implements ILight
	{
		protected var ambientColor:uint = 0x101010;
		protected var lightColor:uint = 0xFFFFFF;
		protected var specularLevel : uint = 1;
		
		public function PointLight(lightColor:uint=0xAAAAAA, ambientColor:uint=0x000000, specular:int = 0)
		{
			this.specularLevel = specular;
			this.ambientColor = ambientColor;
			this.lightColor = lightColor;	
		}

		private var flatMap : BitmapData = new BitmapData(256, 1, false, 0);
		private var flatMapCreated :Boolean = false;
		public function getFlatMap():BitmapData{
			
			if(!flatMapCreated){
				var s:Sprite = new Sprite();
				var m:Matrix = new Matrix();
				m.createGradientBox(255,1,0,0,0);
				s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0,255],m);
				s.graphics.drawRect(0,0,255,1);
				s.graphics.endFill();
				flatMap.draw(s);
				flatMapCreated = true;
			}
			return flatMap;
		}
		
		private var gouraudMap : BitmapData = new BitmapData(256, 1, false, 0);
		private var	gouraudMapCreated :Boolean = false;
		
		public function getGouraudMap( ):BitmapData
		{
			if(!gouraudMapCreated){
				gouraudMap = new BitmapData(255,3,false,0xFFFFFF);
				var s:Sprite = new Sprite();
				var m:Matrix = new Matrix();
				m.createGradientBox(255,3,0,0,0);
	//			s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,lightColor],[1,1],[0,255],m);
				s.graphics.beginGradientFill(GradientType.LINEAR, [ambientColor,ambientColor,lightColor],[1,1,1],[0,specularLevel,0xFF],m);
				s.graphics.drawRect(0,0,255,3);
				s.graphics.endFill();
				gouraudMap.draw(s);
				gouraudMapCreated = true;
			}
			return gouraudMap;
		}
	}
}