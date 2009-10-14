package org.papervision3d.core.render.engine
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	public interface IRenderEngine
	{
		function renderScene(scene:DisplayObject3D, camera:Camera3D, viewport:Viewport3D):void;
	}
}