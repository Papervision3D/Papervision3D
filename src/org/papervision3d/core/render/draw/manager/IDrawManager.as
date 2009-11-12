package org.papervision3d.core.render.draw.manager
{
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface IDrawManager
	{
		function reset():void;
		function handleList():void;
		function addDrawable(drawable:AbstractDrawable):void;
		function get drawables():Vector.<AbstractDrawable>;
		function pushDisplayObject(do3d:DisplayObject3D):void;
		function popDisplayObject():void;
	}
}