package org.papervision3d.core.render.draw.manager
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	
	public interface IDrawManager
	{
		function reset():void;
		function handleList():void;
		function addDrawable(drawable:AbstractDrawable):void;
		function get drawables():Vector.<AbstractDrawable>;
	}
}