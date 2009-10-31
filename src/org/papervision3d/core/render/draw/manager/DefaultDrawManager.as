package org.papervision3d.core.render.draw.manager
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.list.AbstractDrawableList;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.draw.sort.DefaultDrawSorter;
	import org.papervision3d.objects.DisplayObject3D;

	public class DefaultDrawManager implements IDrawManager
	{
		private var drawlist : AbstractDrawableList;
		private var _currentDo3d:DisplayObject3D;
		protected var drawLists : Vector.<AbstractDrawableList>;
		protected var _currentList : AbstractDrawableList;
		protected var _listStack : Vector.<AbstractDrawableList>;
		protected var _objectStack : Vector.<DisplayObject3D>;
		
		public function DefaultDrawManager()
		{
			drawlist = new DrawableList();
			drawlist.sorter = new DefaultDrawSorter();
			_listStack = new Vector.<AbstractDrawableList>();
			_objectStack = new Vector.<DisplayObject3D>();
			drawLists = new Vector.<AbstractDrawableList>();
			_listStack.push(drawlist);
		}
		
		public function reset():void{
			drawlist.clear();
			for each(var d:AbstractDrawableList in drawLists)
				d.clear();
			drawLists.length = 0;
		}
		
		public function handleList():void{
			drawlist.sorter.sort();
			for each(var d:AbstractDrawableList in drawLists)
				d.sorter.sort();
		}

		public function addDrawable(drawable:AbstractDrawable):void
		{
			_currentList.addDrawable(drawable);
		}
		
		public function get drawables():Vector.<AbstractDrawable>
		{
			return drawlist.drawables;
		}
		
		public function set drawList(value:AbstractDrawableList):void{
			drawlist = value;
		}
		
		public function get drawList():AbstractDrawableList{
			return drawlist;
		}
		
		public function set currentDisplayObject(do3d:DisplayObject3D):void{
			_currentDo3d = do3d;
			_objectStack.push(_currentDo3d);
			
			
			if(do3d.renderer.drawableList){
				
				_currentList = do3d.renderer.drawableList;
				drawLists.push( _currentList);
				_listStack.push(_currentList);
			}
		}
		
		public function endDisplayObject():void{
			
			if(_currentDo3d.renderer.drawableList){
				var list : AbstractDrawableList = _listStack.pop();
				list.getDepth();
				
				_currentList = _listStack[_listStack.length-1];
				_currentList.addDrawable(list);
			}
				
			_objectStack.pop();
			_currentDo3d = _objectStack.length > 0 ? _objectStack[_objectStack.length-1] : null;
			
		}
		
	}
}