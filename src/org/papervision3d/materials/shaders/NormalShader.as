package org.papervision3d.materials.shaders
{
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
		
		public override function process(renderData:RenderData, object:DisplayObject3D):void
		{
			bh = _outputBitmap.height;
			bw = _outputBitmap.width;
			_drawContext.graphics.clear();
			
			for each(var t:Triangle in (object.renderer.geometry as TriangleGeometry).triangles){
							//trace(t.uv0.u, t.uv0.v, t.uv1.u, t.uv1.v, t.uv2.u, t.uv2.v);
					handleTriangle(t);
			}
			_outputBitmap.draw(_drawContext);	
		}
		
		public function handleTriangle(t:Triangle):void{
			
			if(!t.normal)
				t.createNormal();
			
			_drawContext.graphics.beginFill(getNormalColor(t.normal), 1);
			_drawContext.graphics.moveTo(t.uv0.u*bh,  (1-t.uv0.v)*bh);
			
			_drawContext.graphics.lineTo(t.uv1.u*bw, (1-t.uv1.v)*bh);
			_drawContext.graphics.lineTo(t.uv2.u*bw, (1-t.uv2.v)*bh);
			_drawContext.graphics.lineTo(t.uv0.u*bw, (1-t.uv0.v)*bh);

			_drawContext.graphics.endFill();
		}
		private var half : Number = 0xFF/2;
		public function getNormalColor(normal:Vector3D):uint{
			
			var r:Number = normal.x*0xFF+half;
			var g:Number = normal.y*0xFF+half;
			var b:Number = normal.z*0xFF+half;
			return r>>16 | g >> 8 | b;
		}
		
	}
}