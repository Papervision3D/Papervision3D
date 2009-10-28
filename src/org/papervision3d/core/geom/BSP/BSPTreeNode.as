package org.papervision3d.core.geom.BSP
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.math.Plane3D;
	
	public class BSPTreeNode
	{
		
		public var front : BSPTreeNode;
		public var back : BSPTreeNode;
		public var divider : Plane3D;
		public var polygonSet : Vector.<Triangle>;
		
		public function BSPTreeNode(polySet:Vector.<Triangle> = null)
		{
			//front = new BSPTreeNode(null);
			//back = new BSPTreeNode(null);
			polygonSet = polySet ? polySet : new Vector.<Triangle>();
		}

	}
}