package org.papervision3d.core.render.data
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.objects.lights.ILight;
	
	public class LightVector
	{
		protected var vector : Vector.<ILight>;
		public function LightVector()
		{
			vector = new Vector.<ILight>();	
		}
		
		public function addLight(light:ILight):void{
			vector.push(light);
		}
		
				
		public function clear():void{
			vector.length = 0;
		}

	}
}