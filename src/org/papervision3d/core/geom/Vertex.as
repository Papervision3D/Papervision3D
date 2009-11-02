package org.papervision3d.core.geom
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.memory.pool.VertexPool;
	
	public class Vertex extends Vector3D
	{
		
		protected static var _pool:VertexPool;
		public static function get pool():VertexPool{
			 if(!_pool) _pool = new VertexPool();
			 return _pool;
		}
		
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
		
		public function clonePosition(v:Vertex):void{
			this.x = v.x;
			this.y = v.y;
			this.z = v.z;
		}
		
		public function cloneIndices(v:Vertex):void{
			this.vectorIndexX = v.vectorIndexX;
			this.vectorIndexY = v.vectorIndexY;
			this.vectorIndexZ = v.vectorIndexZ;
			this.screenIndexX = v.screenIndexX;
			this.screenIndexY = v.screenIndexY;
		}
	}
}