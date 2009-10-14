package org.papervision3d.core.geom
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	
	public class Vertex extends Vector3D
	{
		
		
		/** Vertex normal */
		public var normal :Vector3D;
		
		public var vertexGeometry :VertexGeometry;
		public var vectorIndexX:int = -1;
		public var vectorIndexY:int = -1;
		public var vectorIndexZ:int = -1;
		public var screenIndexX:int = -1;
		public var screenIndexY:int = -1;
		
		public function Vertex(x:Number=0, y:Number=0, z:Number=0, w:Number=0)
		{
			super(x, y, z, w);
			this.normal = new Vector3D();
		}
	}
}