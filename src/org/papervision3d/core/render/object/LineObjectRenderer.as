package org.papervision3d.core.render.object
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Line;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.render.clipping.IPolygonClipper;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.LineDrawable;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class LineObjectRenderer extends ObjectRenderer
	{
		public var lineGeometry : LineGeometry;
		public function LineObjectRenderer(obj:DisplayObject3D)
		{
			super(obj);
			geometry = lineGeometry = new LineGeometry();
			 
		}
		
		public override function fillRenderList(camera:Camera3D, renderData:RenderData, clipper:IPolygonClipper, drawablePool:DrawablePool, _clipFlags:uint ):void{
			
			var sv0 :Vector3D = new Vector3D();
			var sv1 :Vector3D = new Vector3D();
			
			if (object.cullingState == 0)
			{
			
				var line :Line;
					
				for each (line in lineGeometry.lines)
				{
					var lineDrawable :LineDrawable = line.drawable as LineDrawable || new LineDrawable();
					
					sv0.x = screenVertexData[ line.v0.screenIndexX ];	
					sv0.y = screenVertexData[ line.v0.screenIndexY ];
					sv1.x = screenVertexData[ line.v1.screenIndexX ];	
					sv1.y = screenVertexData[ line.v1.screenIndexY ];
				
					lineDrawable.x0 = sv0.x;
					lineDrawable.y0 = sv0.y;
					lineDrawable.x1 = sv1.x;
					lineDrawable.y1 = sv1.y;
					lineDrawable.screenZ = (viewVertexData[line.v0.vectorIndexZ]+viewVertexData[line.v1.vectorIndexZ])*0.5;
					lineDrawable.shader = line.shader;
					
					renderData.drawManager.addDrawable(lineDrawable);
				}
			}
			
		}

	}
}