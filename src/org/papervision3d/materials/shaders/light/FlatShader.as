package org.papervision3d.materials.shaders.light
{
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.render.data.LightVector;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.lights.ILight;
	import org.papervision3d.objects.lights.PointLight;
	
	public class FlatShader extends AbstractLightShader
	{

		public function FlatShader()
		{
			super();
			//buildMap();
		}
		private var lightMatrix:Matrix3D;
		private var drawCommand:Vector.<IGraphicsData> = new Vector.<IGraphicsData>;
		private var bh:Number = 1;
		private var bw:Number = 1;
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
			
				drawCommand.length = 0;
				_drawContext.graphics.clear();
				
				lightMatrix = object.transform.worldTransform.clone();
				lightMatrix.invert();
				
				_outputBitmap.copyPixels(_baseBitmap, _outputBitmap.rect, new Point());
				bh = _outputBitmap.height;
				bw = _outputBitmap.width;

				
				var lights:LightVector = renderData.lights;

				if(lights.vector.length > 0){
					
					var light:PointLight = lights.vector[0] as PointLight;	
					var pos:Vector3D = lightMatrix.transformVector(light.transform.position);
					
					pos.normalize();
				//	trace((object.renderer.geometry as TriangleGeometry).triangles.length);
					var i:int = 0;
					for each(var t:Triangle in (object.renderer.geometry as TriangleGeometry).triangles){

								handleTriangle(t, pos, light);
					}
					//trace("----------");
					
				}else{
					_overlayTexture.fillRect(_overlayTexture.rect, 0xFF0499);
				}
				
				//see below
				//_drawContext.graphics.drawGraphicsData(drawCommand);
				
				_outputBitmap.draw(_drawContext, null, null, "multiply");

		}
		public function getOutput():Sprite{
			return _drawContext;
		}
		
		public function getOutputBitmap():Bitmap{
			return new Bitmap(_outputBitmap);
		}
		
		public function getBaseBitmap():Bitmap{
			return new Bitmap(_baseBitmap);
		}
		
		private function handleTriangle(t:Triangle, lightVector:Vector3D, light:ILight):void{
			
			if(!t.normal)
				t.createNormal();
			var g : Number = t.normal.dotProduct(lightVector);
			
			if(g < 0)
				g = 0;


			_drawContext.graphics.moveTo(t.uv0.u*bw,  (1-t.uv0.v)*bh);
			_drawContext.graphics.beginFill(light.getFlatMap().getPixel(g*0xFF, 0),1);
			_drawContext.graphics.lineTo(t.uv1.u*bw, (1-t.uv1.v)*bh);
			_drawContext.graphics.lineTo(t.uv2.u*bw, (1-t.uv2.v)*bh);
			_drawContext.graphics.lineTo(t.uv0.u*bw, (1-t.uv0.v)*bh);
			

			_drawContext.graphics.endFill();
			

			//grrr - what am i doing wrong here?!?!?
			/* drawCommand.push(new GraphicsSolidFill(flatMap.getPixel(g*0xFF, 0), 1));
			drawCommand.push(new GraphicsTrianglePath(new Vector.<Number>([t.uv0.u*bw,  (1-t.uv0.v)*bh, t.uv1.u*bw, (1-t.uv1.v)*bh, t.uv2.u*bw, (1-t.uv2.v)*bh])));
			drawCommand.push(new GraphicsEndFill()); */
		}
		
		
	}
}