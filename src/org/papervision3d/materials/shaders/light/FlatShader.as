package org.papervision3d.materials.shaders.light
{
	import flash.geom.Point;
	
	import org.papervision3d.core.render.data.LightVector;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class FlatShader extends AbstractLightShader
	{
		
		public function FlatShader()
		{
			super();
		}
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
			
				_outputBitmap.copyPixels(_baseBitmap, _outputBitmap.rect, new Point());

				var lights:LightVector = renderData.lights;
				_overlayTexture.perlinNoise(24, 24, 1, 040433, false, true);
				_outputBitmap.draw(_overlayBitmap, null, null, "multiply");

		}

	}
}