package org.papervision3d.core.animation.keyframe 
{
	import org.papervision3d.core.geom.Vertex;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class VertexKeyframe3D extends Keyframe3D 
	{
		public var data :Vector.<Vertex>;
		
		public function VertexKeyframe3D(time : Number, data:Vector.<Vertex>, interpolation : uint = 1) 
		{
			super(time, interpolation);
			this.data = data;
		}
	}
}

