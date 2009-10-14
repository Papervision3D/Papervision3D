package org.papervision3d.core.render.engine
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.render.pipeline.IRenderPipeline;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	public class AbstractRenderEngine extends EventDispatcher implements IRenderEngine
	{
		public var pipeline :IRenderPipeline;
		
		public function AbstractRenderEngine(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function renderScene(scene:DisplayObject3D, camera:Camera3D, viewport:Viewport3D):void
		{
			
		}
	}
}