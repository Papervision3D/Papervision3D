package org.papervision3d.core.memory.pool
{
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class DrawablePool
	{
		public var growSize :uint;
		
		protected var drawables :Vector.<AbstractDrawable>;
		
		private var _drawableClass :Class;
		private var _currentItem :uint;
		private var _numItems :uint;
		
		public function DrawablePool(drawableClass:Class=null, growSize:uint=20)
		{
			this.growSize = growSize;
			this.drawables = new Vector.<AbstractDrawable>();
			
			_drawableClass = drawableClass;
			_currentItem = 0;
			_numItems = 0;
			
			grow();
		}
		
		public function get drawable():AbstractDrawable
		{
			if (_currentItem < _numItems)
			{
				return drawables[ _currentItem++ ];
			}
			else
			{
				_currentItem = drawables.length;
			
				grow();
			
				return drawables[ _currentItem++ ];
			}
		}
		
		public function reset():void
		{
			_currentItem = 0;	
		}
		
		protected function grow():void
		{
			var i :int;
			
			for (i = 0; i < growSize; i++)
			{
				drawables.push( new _drawableClass() );
			}
			
			_numItems = drawables.length;
			
			trace("[DrawablePool] grown to " + _numItems + " items of type " + _drawableClass);
		}
	}
}