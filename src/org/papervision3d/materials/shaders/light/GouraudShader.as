package org.papervision3d.materials.shaders.light 
{
	import __AS3__.vec.Vector;
	
	import flash.display.Bitmap;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
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
	
	public class GouraudShader extends AbstractLightShader
	{
		
		public function GouraudShader()
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
					
					_lightMap = light.getGouraudMap();

					var pos:Vector3D = lightMatrix.transformVector(light.transform.position);
					
					pos.normalize();
					
					if(object.renderer.geometry is TriangleGeometry)
						(object.renderer.geometry as TriangleGeometry).generateVertexNormals();
				
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
		
		private var p0:Number;
		private var transformMatrix:Matrix = new Matrix();
		private var triMatrix:Matrix = new Matrix();
		
		private function handleTriangle(t:Triangle, lightVector:Vector3D, light:ILight):void{
			use namespace pv3d;
			
			if(t.cullFlags > 0)
				return;
				
				
			p0 = lightVector.dotProduct(t.v0.normal)*255;
			transformMatrix.tx = p0;
			transformMatrix.ty = 1;
		    transformMatrix.a = (lightVector.dotProduct(t.v1.normal)*255) - p0;
		    transformMatrix.c = (lightVector.dotProduct(t.v2.normal)*255) - p0;
			transformMatrix.b = 2;
			transformMatrix.d = 3;
		    transformMatrix.invert();
		    triMatrix = getUVMatrixForTriangle(t);
		    transformMatrix.concat(triMatrix);
		   
		    
		    var v:Vector.<Number> = new Vector.<Number>();
			v.push(t.uv0.u*bw,  (1-t.uv0.v)*bh,  t.uv1.u*bw, (1-t.uv1.v)*bh, t.uv2.u*bw, (1-t.uv2.v)*bh);
			
			var g:GraphicsBitmapFill = new GraphicsBitmapFill(light.getGouraudMap(), transformMatrix, false);
			 
			
			drawCommand.push(g);
			drawCommand.push(new GraphicsTrianglePath(v));
			drawCommand.push(new  GraphicsEndFill()); 

		}
		
		
	}
}