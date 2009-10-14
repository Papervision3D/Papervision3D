package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.sort.IDrawSorter;

	public class AbstractDrawableList implements IDrawableList
	{
		protected var _sorter : IDrawSorter;
		
		public function AbstractDrawableList()
		{
		}

		public function addDrawable(drawable:AbstractDrawable):void
		{
		}
		
		public function clear():void
		{
		}
		
		public function get drawables():Vector.<AbstractDrawable>
		{
			return null;
		}
		
		public function set sorter(sorter:IDrawSorter):void{
			_sorter = sorter;
			_sorter.drawlist = this;
		}
		
		public function get sorter():IDrawSorter{
			return _sorter;
		}
		
	}
}