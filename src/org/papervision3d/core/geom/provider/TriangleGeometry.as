package org.papervision3d.core.geom.provider
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.Vertex;
	
	public class TriangleGeometry extends VertexGeometry
	{
		/** */
		public var triangles :Vector.<Triangle>; 
		
		protected var vectorFaceLinks : Dictionary = new Dictionary(false);
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
				
				
				if(!vectorFaceLinks[triangle.v0]){
					vectorFaceLinks[triangle.v0] = new Vector.<Triangle>();
				}
				vectorFaceLinks[triangle.v0].push(triangle);
				
				if(!vectorFaceLinks[triangle.v1]){
					vectorFaceLinks[triangle.v1] = new Vector.<Triangle>();
				}
				vectorFaceLinks[triangle.v1].push(triangle);
				
				if(!vectorFaceLinks[triangle.v2]){
					vectorFaceLinks[triangle.v2] = new Vector.<Triangle>();
				}
				vectorFaceLinks[triangle.v2].push(triangle);

				return triangle;	
			}
			else
			{
				return triangles[index];
			}
		}
		
		public function removeTriangle(triangle:Triangle):void{
			
			var index :int = triangles.indexOf(triangle);
			triangles.splice(index, 1);
			
		}
		
		public var vertexNormalsDirty : Boolean = true;
		
		public function generateVertexNormals():void{
		
			if(!vertexNormalsDirty)
				return;
					
			var tmpNormal : Vector3D;
			for each (var v:Vertex in this.vertices){
			
				var vA:Vector.<Triangle> = vectorFaceLinks[v];
				tmpNormal = new Vector3D();
				for each(var t:Triangle in vA){
					if(!t.normal)
						t.createNormal();
					tmpNormal  = t.normal.add(tmpNormal);
				}
				
				tmpNormal.normalize();
				v.normal = tmpNormal.clone();
			}
			vertexNormalsDirty = false;
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