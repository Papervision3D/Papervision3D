package org.papervision3d.core.math
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.geom.Vertex;
	
	public class BoundingSphere3D
	{
		/** */
		public var origin :Vector3D;
		
		/** */
		public var worldOrigin :Vector3D;
		
		/** */
		public var radius :Number;
		
		/** */
		public var worldRadius :Number;
		
		/** */
		private var _bbox :AABoundingBox3D;
		
		/**
		 * 
		 */ 
		public function BoundingSphere3D(origin:Vector3D=null, radius:Number=0)
		{
			this.origin = origin || new Vector3D();
			this.worldOrigin = this.origin.clone();
			this.radius = radius;
			this.worldRadius = radius;
		}
		
		/**
		 * 
		 */
		public function intersects(sphere:BoundingSphere3D):Boolean
		{
			// get the separating axis
			var sepAxis :Vector3D = this.origin.subtract(sphere.worldOrigin);
			//Vector3f vSepAxis = this->Center() - refSphere.Center();
		
			// get the sum of the radii
			var radiiSum :Number = this.radius + sphere.worldRadius;
			//float fRadiiSum = this->Radius() + refSphere.Radius();
		
			trace( sepAxis.lengthSquared + " " + (radiiSum*radiiSum));
			// if the distance between the centers is less than the sum
			// of the radii, then we have an intersection
			// we calculate this using the squared lengths for speed
			if (sepAxis.lengthSquared < (radiiSum * radiiSum))
				return true;
			//if(vSepAxis.getSqLength() < (fRadiiSum * fRadiiSum))
			//	return(true);
			// otherwise they are separated
			return false;
		} 
		/**
		 * 
		 */
		public function setFromVertices(vertices:Vector.<Vertex>, fast:Boolean=true):void
		{		
			var v:Vertex;
			if (fast)
			{
				if (_bbox)
				{
					_bbox.setFromVertices(vertices);
				}
				else
				{
					_bbox = AABoundingBox3D.createFromVertices(vertices);
				}
				
				origin.x = _bbox.origin.x;
				origin.y = _bbox.origin.y;
				origin.z = _bbox.origin.z;
				
				radius = _bbox.max.subtract(origin).length;
			}
			else
			{
				var vertex :Vector3D, dist :Vector3D;
				var temp :Number, radiusSqr :Number = 0;
				var n :int = 1 / vertices.length;
				
				origin.x = origin.y = origin.z = 0;
				
				for each (vertex in vertices)
				{
					origin.x += vertex.x;
					origin.y += vertex.y;
					origin.z += vertex.z;
				}
				
				origin.x *= n;
				origin.y *= n;
				origin.z *= n;
				
				for each (vertex in vertices)
				{
					dist.x = vertex.x - origin.x;
					dist.y = vertex.y - origin.y;
					dist.z = vertex.z - origin.z;
					
					temp = dist.x * dist.x + dist.y * dist.y + dist.z * dist.z;
					
					if (temp > radiusSqr)
					{
						radiusSqr = temp;
					}
				}
				
				radius = Math.sqrt(radiusSqr);
			}
		}  
	}
}