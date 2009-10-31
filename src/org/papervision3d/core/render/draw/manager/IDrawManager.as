package org.papervision3d.core.render.draw.manager
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface IDrawManager
	{
		function reset():void;
		function handleList():void;
		function addDrawable(drawable:AbstractDrawable):void;
		function get drawables():Vector.<AbstractDrawable>;
		function set currentDisplayObject(do3d:DisplayObject3D):void;
	}
}