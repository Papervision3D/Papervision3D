package org.papervision3d.core.render.clipping
{
	import org.papervision3d.core.math.Plane3D;
	
	public interface IPolygonClipper
	{
		/**
		 * Clips a polygon to a plane.
		 * 
		 * @param iVertexData
		 * @param iUvtData
		 * @param oVertexData
		 * @param oUvtData
		 * @param plane
		 */
		function clipPolygonToPlane(iVertexData:Vector.<Number>, iUvtData:Vector.<Number>, 
									oVertexData:Vector.<Number>, oUvtData:Vector.<Number>, 
									plane:Plane3D) : void;	
	}
}