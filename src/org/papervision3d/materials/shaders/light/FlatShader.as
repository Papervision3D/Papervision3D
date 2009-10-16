package org.papervision3d.materials.shaders.light
{
	import __AS3__.vec.Vector;
	
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
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
		}
		private var lightMatrix:Matrix3D;
		private var drawCommand:Vector.<IGraphicsData> = new Vector.<IGraphicsData>;
		private var bh:Number = 1;
		private var bw:Number = 1;
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
				drawCommand.length = 0;
				
				
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
					for each(var t:Triangle in (object.renderer.geometry as TriangleGeometry).triangles){
						handleTriangle(t, pos, light);
					}
					
				}else{
					_overlayTexture.fillRect(_overlayTexture.rect, 0xFF0499);
				}
				
				//see below
				//_drawContext.graphics.drawGraphicsData(drawCommand);

				_outputBitmap.draw(_drawContext, null, null, "add");

		}
		
		private function handleTriangle(t:Triangle, lightVector:Vector3D, light:ILight):void{
			
			if(!t.normal)
				t.createNormal();
			var g : Number = t.normal.dotProduct(lightVector);
			if(g < 0)
				g = 0;

			_drawContext.graphics.moveTo(t.uv0.u*bh,  (1-t.uv0.v)*bh);
			_drawContext.graphics.beginFill(g*0xFFFFFF, 1);
			_drawContext.graphics.lineTo(t.uv1.u*bw, (1-t.uv1.v)*bh);
			_drawContext.graphics.lineTo(t.uv2.u*bw, (1-t.uv2.v)*bh);
			_drawContext.graphics.lineTo(t.uv0.u*bw, (1-t.uv0.v)*bh);
			_drawContext.graphics.endFill();
			/*
			//grrr - what am i doing wrong here?!?!?
			drawCommand.push(new GraphicsSolidFill(g*0xFF0000, 1));
			drawCommand.push(new GraphicsTrianglePath(new Vector.<Number>([t.uv1.u*bw, (1-t.uv1.v)*bh, t.uv2.u*bw, (1-t.uv2.v)*bh, t.uv0.u*bw,  (1-t.uv0.v)*bh])));
			drawCommand.push(new GraphicsEndFill());*/
		}

	}
}