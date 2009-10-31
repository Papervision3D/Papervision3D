package org.papervision3d.core.render.draw.manager
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.draw.sort.DefaultDrawSorter;
	import org.papervision3d.objects.DisplayObject3D;

	public class DefaultDrawManager implements IDrawManager
	{
		private var drawlist:DrawableList;
		private var _currentDo3d:DisplayObject3D;
		
		public function DefaultDrawManager()
		{
			drawlist = new DrawableList();
			drawlist.sorter = new DefaultDrawSorter();
		}
		
		public function reset():void{
			drawlist.clear();
		}
		
		public function handleList():void{
			drawlist.sorter.sort();
		}

		public function addDrawable(drawable:AbstractDrawable):void
		{
			drawlist.addDrawable(drawable);
		}
		
		public function get drawables():Vector.<AbstractDrawable>
		{
			return drawlist.drawables;
		}
		
		public function set drawList(value:DrawableList):void{
			drawlist = value;
		}
		
		public function get drawList():DrawableList{
			return drawlist;
		}
		
		public function set currentDisplayObject(do3d:DisplayObject3D):void{
			
		}
	}
}