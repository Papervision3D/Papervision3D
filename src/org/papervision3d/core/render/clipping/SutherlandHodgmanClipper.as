package org.papervision3d.core.render.clipping 
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.math.Plane3D;	

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class SutherlandHodgmanClipper implements IPolygonClipper
	{
		protected static const OUTSIDE:uint = 0;
		protected static const INSIDE:uint = 1;
		protected static const OUT_IN:uint = 2;
		protected static const IN_OUT:uint = 3;
		protected var _p0 :Vector3D;
		protected var _p1 :Vector3D;
		
		public function SutherlandHodgmanClipper() 
		{
			_p0 = new Vector3D();
			_p1 = new Vector3D();
		}

		/**
		 * Clips a polygon to a plane.
		 * 
		 * @param iVertexData
		 * @param iUvtData
		 * @param oVertexData
		 * @param oUvtData
		 * @param plane
		 */
		public function clipPolygonToPlane(iVertexData:Vector.<Number>, iUvtData:Vector.<Number>, 
										   oVertexData:Vector.<Number>, oUvtData:Vector.<Number>, 
										   plane :Plane3D) : void 
		{
	
			if(iVertexData.length != iUvtData.length) 
			{
				throw new ArgumentError("UVT data doesn't match passed in vertexData!");	
			}
			
			_p0.x = iVertexData[0];
			_p0.y = iVertexData[1];
			_p0.z = iVertexData[2];
			
			var dist1 :Number = plane.distance(_p0);
			var count :int = iVertexData.length / 3;
			var t0u:Number, t0v:Number, t1u:Number, t1v:Number;
			var i:int, j:int;

			for(i = 0; i < count; i++) 
			{
				j = (i+1) % count;
				
				_p0.x = iVertexData[i*3];
				_p0.y = iVertexData[(i*3)+1];
				_p0.z = iVertexData[(i*3)+2];
				
				_p1.x = iVertexData[j*3];
				_p1.y = iVertexData[(j*3)+1];
				_p1.z = iVertexData[(j*3)+2];
				
				t0u = iUvtData[i*3];
				t0v = iUvtData[(i*3)+1];
				t1u = iUvtData[j*3];
				t1v = iUvtData[(j*3)+1];
				
				var dist2:Number = plane.distance(_p1);
				var d:Number = dist1 / (dist1-dist2);
				
				var status:uint = compareDistances( dist1, dist2 );
				
				switch(status) 
				{
					case INSIDE:
						oVertexData.push(_p1.x);
						oVertexData.push(_p1.y);
						oVertexData.push(_p1.z);
						oUvtData.push(t1u);
						oUvtData.push(t1v);
						oUvtData.push(0);
						break;
					case IN_OUT:
						oVertexData.push(_p0.x + (_p1.x - _p0.x) * d);
						oVertexData.push(_p0.y + (_p1.y - _p0.y) * d);
						oVertexData.push(_p0.z + (_p1.z - _p0.z) * d);
						oUvtData.push(t0u + (t1u - t0u) * d);
						oUvtData.push(t0v + (t1v - t0v) * d);
						oUvtData.push(0);
						break;
					case OUT_IN:
						oVertexData.push(_p0.x + (_p1.x - _p0.x) * d);
						oVertexData.push(_p0.y + (_p1.y - _p0.y) * d);
						oVertexData.push(_p0.z + (_p1.z - _p0.z) * d);
						oVertexData.push(_p1.x);
						oVertexData.push(_p1.y);
						oVertexData.push(_p1.z);
						oUvtData.push(t0u + (t1u - t0u) * d);
						oUvtData.push(t0v + (t1v - t0v) * d);
						oUvtData.push(0);
						oUvtData.push(t1u);
						oUvtData.push(t1v);
						oUvtData.push(0);
						break;
					default:
						break;
				}
				dist1 = dist2;
			}
		}
		
		protected function compareDistances( dist1:Number, dist2:Number, e:Number=0 ):uint 
		{			
			if( dist1 < -e && dist2 < -e )
				return OUTSIDE;
			else if( dist1 > e && dist2 > e )
				return INSIDE;
			else if( dist1 > e && dist2 < -e )
				return IN_OUT;	
			else
				return OUT_IN;
		}
	}
}
