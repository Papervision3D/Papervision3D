package org.papervision3d.core.geom.provider
{
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.Vertex;
	
	public class TriangleGeometry extends VertexGeometry
	{
		/** */
		public var triangles :Vector.<Triangle>; 
		/**
		 * 
		 */ 
		public function TriangleGeometry(name:String=null)
		{
			super(name);
			
			this.triangles = new Vector.<Triangle>();
		}
		
		/**
		 * Adds a triangle.
		 * 
		 * @param	triangle
		 * 
		 * @return The added triangle.
		 */ 
		public function addTriangle(triangle:Triangle):Triangle
		{
			var index :int = triangles.indexOf(triangle);
			
			if (index < 0)
			{
				triangle.v0 = addVertex(triangle.v0);
				triangle.v1 = addVertex(triangle.v1);
				triangle.v2 = addVertex(triangle.v2);
				
				triangles.push(triangle);

				return triangle;	
			}
			else
			{
				return triangles[index];
			}
		}
		
		/**
		 * 
		 */
		public function mergeVertices(treshold:Number=0.01):void
		{
			var triangle :Triangle;
			
			removeAllVertices();
			
			for each (triangle in triangles)
			{
				var v0 :Vertex = findVertexInRange(triangle.v0, treshold);
				var v1 :Vertex = findVertexInRange(triangle.v1, treshold);
				var v2 :Vertex = findVertexInRange(triangle.v2, treshold);
				
				if (!v0) v0 = addVertex(triangle.v0);
				if (!v1) v1 = addVertex(triangle.v1);
				if (!v2) v2 = addVertex(triangle.v2);
				
				triangle.v0 = v0;
				triangle.v1 = v1;
				triangle.v2 = v2;
			}
		} 
	}
}