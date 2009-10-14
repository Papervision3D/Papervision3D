package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.sort.IDrawSorter;
	
	public interface IDrawableList
	{
		function addDrawable(drawable:AbstractDrawable):void;
		function clear():void;
		function get drawables():Vector.<AbstractDrawable>; 
		function set sorter(sorter:IDrawSorter):void;
		function get sorter():IDrawSorter;
		
	}
}