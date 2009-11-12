package org.papervision3d.core.memory.pool
{
	import org.papervision3d.core.geom.Vertex;
	

	
	/**
	 * @author andy zupko / zupko.info
	 */ 
	public class VertexPool
	{
		public var growSize :uint;
		
		protected var vertices :Vector.<Vertex>;
		private var _currentItem :uint;
		private var _numItems :uint;
		
		
		
		public function VertexPool(drawableClass:Class=null, growSize:uint=20)
		{
			this.growSize = growSize;
			this.vertices = new Vector.<Vertex>();

			_currentItem = 0;
			_numItems = 0;
			
			grow();
		}
		
		public function getVertex(x:Number=0, y:Number=0, z:Number=0):Vertex{
			var v:Vertex = vertex;
			v.x = x;
			v.y = y;
			v.z = z;
			return v;
		}
	
		
		public function get vertex():Vertex
		{
			
			if (_currentItem < _numItems)
			{
				return vertices[ _currentItem++ ];
			}
			else
			{
				_currentItem = vertices.length;
			
				grow();
			
				return vertices[ _currentItem++ ];
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
				vertices.push( new Vertex() );
			}
			
			_numItems = vertices.length;
			
			trace("[VertexPool] grown to " + _numItems);
		}
	}
}