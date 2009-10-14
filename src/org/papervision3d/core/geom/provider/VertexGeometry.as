package org.papervision3d.core.geom.provider
{
	import org.papervision3d.core.geom.Geometry;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.ns.pv3d;
	
	public class VertexGeometry extends Geometry
	{
		public var vertices :Vector.<Vertex>;
		public var uvtData :Vector.<Number>;
		public var vertexData :Vector.<Number>;
		public var screenVertexLength : int = 0;
		public var viewVertexLength : int = 0;
		
		/**
		 * Constructor
		 */ 
		public function VertexGeometry(name:String=null)
		{
			super();
			
			vertices = new Vector.<Vertex>();
			
			vertexData = new Vector.<Number>();
			uvtData = new Vector.<Number>();
		}
		
		/**
		 * Adds a new Vertex.
		 * 
		 * @param	vertex
		 * 
		 * @return The added vertex.
		 * 
		 * @see org.papervision3d.core.geom.Vertex
		 */ 
		public function addVertex(vertex:Vertex):Vertex 
		{
			var index :int = vertices.indexOf(vertex);
			
			if (index >= 0)
			{
				return vertices[index];
			}
			else
			{
				vertex.vertexGeometry = this;
				
				
				vertex.vectorIndexX = vertexData.push(vertex.x) - 1;
				vertex.vectorIndexY = vertexData.push(vertex.y) - 1;
				vertex.vectorIndexZ = vertexData.push(vertex.z) - 1;
				
				viewVertexLength += 3;
				vertex.screenIndexX = screenVertexLength;
				
				vertex.screenIndexY = screenVertexLength+1;
				screenVertexLength += 2;
				uvtData.push(0, 0, 0);
				vertices.push(vertex);
				
				return vertex;
			}
		}
		
		/**
		 * Finds a vertex within the specified range.
		 * 
		 * @param	vertex
		 * @param	range
		 * 
		 * @return 	The found vertex or null if not found.
		 */ 
		public function findVertexInRange(vertex:Vertex, range:Number=0.01):Vertex
		{
			var v :Vertex;
			
			for each (v in vertices)
			{
				if (vertex.x > v.x - range && vertex.x < v.x + range &&
					vertex.y > v.y - range && vertex.y < v.y + range &&
					vertex.z > v.z - range && vertex.z < v.z + range)
				{
					return v;
				}
			}
			
			return null;	
		}
		
		/**
		 * Removes a new Vertex.
		 * 
		 * @param	vertex	The vertex to remove.
		 * 
		 * @return The removed vertex or null on failure.
		 * 
		 * @see org.papervision3d.core.geom.Vertex
		 */ 
		public function removeVertex(vertex:Vertex):Vertex 
		{
			var index :int = vertices.indexOf(vertex);
			
			if (index < 0)
			{
				return null;
			}
			else
			{
				vertices.splice(index, 1);
				
				vertex.vertexGeometry = null;
				vertex.vectorIndexX = vertex.vectorIndexY = vertex.vectorIndexZ = -1;
				vertex.screenIndexX = vertex.screenIndexY = -1;
				
				updateIndices();
				
				return vertex;
			}
		}
		
		/**
		 * 
		 */ 
		public function removeAllVertices():void
		{
			this.vertices.length = 0;
			updateIndices();
		}
		
		/**
		 * 
		 */ 
		public function updateIndices():void
		{
			var vertex :Vertex;
			
			vertexData.length = 0;
			viewVertexLength = 0;
			screenVertexLength = 0;
			uvtData.length = 0;
			
			for each (vertex in vertices)
			{
				vertex.vectorIndexX = vertexData.push(vertex.x) - 1;
				vertex.vectorIndexY = vertexData.push(vertex.y) - 1;
				vertex.vectorIndexZ = vertexData.push(vertex.z) - 1;
				
				viewVertexLength += 3;
				vertex.screenIndexX = screenVertexLength;
				
				vertex.screenIndexY = screenVertexLength+1;
				screenVertexLength += 2;
				uvtData.push(0, 0, 0);
				
			}
		}
	}
}