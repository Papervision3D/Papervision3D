package org.papervision3d.core.render.draw.sort
{
	import org.papervision3d.core.render.draw.list.IDrawableList;
	
	public interface IDrawSorter
	{
		function sort():void;
		function set drawlist(list:IDrawableList):void;
	}
}