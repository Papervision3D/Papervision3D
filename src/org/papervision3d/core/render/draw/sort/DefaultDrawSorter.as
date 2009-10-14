package org.papervision3d.core.render.draw.sort
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.list.IDrawableList;

	public class DefaultDrawSorter implements IDrawSorter
	{
		protected var _drawList : IDrawableList;
		public function DefaultDrawSorter()
		{
		}

		public function sort():void
		{
			var v:Vector.<AbstractDrawable> = _drawList.drawables;
			v.sort(screenZCompare);
			
		}
		
		public function set drawlist(list:IDrawableList):void{
			_drawList = list;
		}
		
		private function screenZCompare(x:AbstractDrawable, y:AbstractDrawable):Number{
			return x.screenZ-y.screenZ;
		}
		
	}
}