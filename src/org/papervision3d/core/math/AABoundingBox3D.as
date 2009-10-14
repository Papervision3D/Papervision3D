package org.papervision3d.core.math
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.Vertex;
	
	public class AABoundingBox3D
	{
		/** */
		public var origin :Vector3D;
		
		/** */
		public var min :Vector3D;
		
		/** */
		public var max :Vector3D;
		
		/**
		 * Constructor.
		 */ 
		public function AABoundingBox3D()
		{
			this.origin = new Vector3D();
			this.min = new Vector3D();
			this.max = new Vector3D();
		}
		
		/**
		 * Sets the axis-aligned bounding box from a set of vertices.
		 * 
		 * @param	vertices
		 */
		public function setFromVertices(vertices:Vector.<Vertex>):void
		{
			var vertex :Vertex;
			
			if (!vertices || !vertices.length)
			{
				min.x = min.y = min.z = 0;
				max.x = max.y = max.z = 0;
			}
			else
			{
				min.x = min.y = min.z = Number.MAX_VALUE;
				max.x = max.y = max.z = -Number.MAX_VALUE;
				
				for each (vertex in vertices)
				{
					min.x = Math.min(min.x, vertex.x);
					min.y = Math.min(min.y, vertex.y);
					min.z = Math.min(min.z, vertex.z);
					max.x = Math.max(max.x, vertex.x);
					max.y = Math.max(max.y, vertex.y);
					max.z = Math.max(max.z, vertex.z);
				}	
			}
			
			origin.x = min.x + ((max.x - min.x) * 0.5);
			origin.y = min.y + ((max.y - min.y) * 0.5);
			origin.z = min.z + ((max.z - min.z) * 0.5);
		}
		
		/**
		 * Creates a axis-aligned bounding box from a set of vertices.
		 * 
		 * @param	vertices
		 * 
		 * @return The created bounding box.
		 */
		public static function createFromVertices(vertices:Vector.<Vertex>):AABoundingBox3D
		{
			var bbox :AABoundingBox3D = new AABoundingBox3D();
			
			bbox.setFromVertices(vertices);
			
			return bbox;
		} 
	}
}