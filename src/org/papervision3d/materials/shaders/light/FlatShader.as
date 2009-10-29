package org.papervision3d.materials.shaders.light
{
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.ns.pv3d;
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
		private var lightMatrix:Matrix3D = new Matrix3D();
		private var drawCommand:Vector.<IGraphicsData> = new Vector.<IGraphicsData>;
		private var bh:Number = 1;
		private var bw:Number = 1;
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
				
				drawCommand.length = 0;
				_drawContext.graphics.clear();
				
				lightMatrix.rawData = object.transform.worldTransform.rawData;
				lightMatrix.invert();
				
				//_outputBitmap.copyPixels(_baseBitmap, _outputBitmap.rect, new Point());
				bh = _outputBitmap.height;
				bw = _outputBitmap.width;

				
				var lights:LightVector = renderData.lights;

				if(lights.vector.length > 0){
					
					
					
					var light:PointLight = lights.vector[0] as PointLight;	
					
					_lightMap = light.getFlatMap();
					
					/*
					 	Why is Y upside down in the inversion??
					*/
					 
					var pos:Vector3D = lightMatrix.transformVector(new Vector3D(light.x, -light.y, light.z));
					
					pos.normalize();
				
					var i:int = 0;
					
					for each(var t:Triangle in (object.renderer.geometry as TriangleGeometry).triangles){

						handleTriangle(t, pos, light);
					}
					
				}else{
					_overlayTexture.fillRect(_overlayTexture.rect, 0xFF0499);
				}
				
				//see below
				_drawContext.graphics.drawGraphicsData(drawCommand);
				
				_outputBitmap.draw(_drawContainer, null, null, "normal");

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
			use namespace pv3d;
			if(t.cullFlags > 0)
				return;
				
			if(!t.normal)
				t.createNormal();
			var g : Number = lightVector.dotProduct(t.normal);
			
			if(g < 0)
				g = 0;
			

			var v:Vector.<Number> = new Vector.<Number>();
			v.push(t.uv0.u*bw,  (1-t.uv0.v)*bh,  t.uv1.u*bw, (1-t.uv1.v)*bh, t.uv2.u*bw, (1-t.uv2.v)*bh);
			
			
			drawCommand.push(new GraphicsSolidFill(_lightMap.getPixel(g*0xFF, 0)));
			drawCommand.push(new GraphicsTrianglePath(v));
			drawCommand.push(new  GraphicsEndFill());
		}
		
		
	}
}