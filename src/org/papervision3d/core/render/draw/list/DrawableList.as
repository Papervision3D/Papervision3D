package org.papervision3d.core.render.draw.list
{
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.core.render.draw.items.IDrawable;
	
	public class DrawableList extends AbstractDrawableList implements IDrawableList
	{
		private var _drawables :Vector.<AbstractDrawable>;
		
		public function DrawableList()
		{
			_drawables = new Vector.<AbstractDrawable>();
		}

		public override function addDrawable(drawable:AbstractDrawable):void
		{
			_drawables.push(drawable);
		}
		
		public override function clear():void
		{
			_drawables.length = 0;
		}
		
		public override function get drawables():Vector.<AbstractDrawable>
		{
			return _drawables;
		}
		
		
	}
}