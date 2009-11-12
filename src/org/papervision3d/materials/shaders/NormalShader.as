package org.papervision3d.materials.shaders
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.materials.shaders.light.AbstractLightShader;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class NormalShader extends AbstractLightShader
	{
		public function NormalShader()
		{
			super();
			
		}
		
		private var bh:Number = 1;
		private var bw:Number = 1;
		private var drawCommand:Vector.<IGraphicsData> = new Vector.<IGraphicsData>;
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
			bh = _outputBitmap.height;
			bw = _outputBitmap.width;
			_drawContext.graphics.clear();
			drawCommand.length = 0;
			
			for each(var t:Triangle in (object.renderer.geometry as TriangleGeometry).triangles){
							//trace(t.uv0.u, t.uv0.v, t.uv1.u, t.uv1.v, t.uv2.u, t.uv2.v);
					handleTriangle(t);
			}
			_drawContext.graphics.drawGraphicsData(drawCommand);
			_outputBitmap.draw(_drawContext);	
		}
		
		public function handleTriangle(t:Triangle):void{
			
			if(!t.normal)
				t.createNormal();

			
			var v:Vector.<Number> = new Vector.<Number>();
			v.push(t.uv0.u*bw,  (1-t.uv0.v)*bh,  t.uv1.u*bw, (1-t.uv1.v)*bh, t.uv2.u*bw, (1-t.uv2.v)*bh);
			//trace(getNormalColor(t.normal).toString(16));
/* 			if(getNormalColor(t.normal).toString(16) == "7f7f7f"){
				trace(t, t.normal, t.uv0, t.uv1, t.uv2);
			} */
				
			drawCommand.push(new GraphicsSolidFill(getNormalColor(t.normal)));
			drawCommand.push(new GraphicsTrianglePath(v));
			drawCommand.push(new  GraphicsEndFill());
		}
		private var half : Number = 0xFF/2;
		public function getNormalColor(normal:Vector3D):uint{
			
			var r:Number = normal.x*half+half;
			var g:Number = normal.y*half+half;
			var b:Number = normal.z*half+half;
			
			return r<<16 | g << 8 | b;
		}
		
	}
}