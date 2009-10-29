package org.papervision3d.core.render.draw.sort
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.list.IDrawableList;

	public class NullDrawSorter implements IDrawSorter
	{
		protected var _drawList : IDrawableList;
		public function NullDrawSorter()
		{
		}

		public function sort():void
		{
	
			
		}
		
		public function set drawlist(list:IDrawableList):void{
			_drawList = list;
		}
		
		
	}
}