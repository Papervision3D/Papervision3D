package org.papervision3d.core.render.pipeline
{
	import org.papervision3d.core.render.data.RenderData;
	
	public interface IRenderPipeline
	{
		function execute(renderData:RenderData):void
	}
}