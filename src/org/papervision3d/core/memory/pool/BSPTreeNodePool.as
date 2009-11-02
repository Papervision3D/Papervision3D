
	/**
	 * @author andy zupko / zupko.info
	 */ 
	 package org.papervision3d.core.memory.pool
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.BSP.BSPTreeNode;
	

	
	/**
	 * @author andy zupko / zupko.info
	 */ 
	public class BSPTreeNodePool
	{
		public var growSize :uint;
		
		protected var vertices :Vector.<BSPTreeNode>;
		private var _currentItem :uint;
		private var _numItems :uint;
		
		
		
		public function BSPTreeNodePool(drawableClass:Class=null, growSize:uint=20)
		{
			this.growSize = growSize;
			this.vertices = new Vector.<BSPTreeNode>();

			_currentItem = 0;
			_numItems = 0;
			
			grow();
		}
		
		public function getBSPTreeNode(isDynamic:Boolean = false):BSPTreeNode{
			var v:BSPTreeNode = node;
			node.polygonSet.length = 0;
			node.divider = null;
			node.front= node.back = null;
			node.dynamicPolySet.length = 0;
			node.isDynamic = isDynamic;
			return v;
		}
	
		
		public function get node():BSPTreeNode
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
				vertices.push( new BSPTreeNode() );
			}
			
			_numItems = vertices.length;
			
			trace("[BSPTreeNodePool] grown to " + _numItems);
		}
	
	}
}