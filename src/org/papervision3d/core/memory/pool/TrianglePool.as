package org.papervision3d.core.memory.pool
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.UVCoord;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.materials.shaders.IShader;
	

	
	/**
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class TrianglePool
	{
		public var growSize :uint;
		
		public var triangles :Vector.<Triangle>;
		
		private var _drawableClass :Class;
		private var _currentItem :uint;
		private var _numItems :uint;
		
		
		
		public function TrianglePool(drawableClass:Class=null, growSize:uint=20)
		{
			this.growSize = growSize;
			this.triangles = new Vector.<Triangle>();

			_currentItem = 0;
			_numItems = 0;
			
			grow();
		}
		
		public function getTriangle(shader:IShader, v0:Vertex, v1:Vertex, v2:Vertex, uv0:UVCoord, uv1:UVCoord, uv2:UVCoord):Triangle{
			var t:Triangle = triangle;
			t.shader = shader;
			t.v0.clonePosition(v0);
			t.v1.clonePosition(v1);
			t.v2.clonePosition(v2);
			t.uv0 = uv0;
			t.uv1 = uv1;
			t.uv2 = uv2;
			return t;
		}
		
		public function get triangle():Triangle
		{
			
			if (_currentItem < _numItems)
			{
				return triangles[ _currentItem++ ];
			}
			else
			{
				_currentItem = triangles.length;
			
				grow();
			
				return triangles[ _currentItem++ ];
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
				triangles.push( new Triangle(null, new Vertex, new Vertex, new Vertex, null, null, null) );
			}
			
			_numItems = triangles.length;
			
			trace("[TrianglePool] grown to " + _numItems);
		}
	}
}