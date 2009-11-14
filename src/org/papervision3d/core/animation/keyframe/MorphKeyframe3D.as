package org.papervision3d.core.animation.keyframe 
{
	import org.papervision3d.core.geom.Vertex;
		
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class MorphKeyframe3D extends Keyframe3D 
	{	
		/**
		 * 
		 */
		public var data : Vector.<Vertex>;

		/**
		 * 
		 */
		public function MorphKeyframe3D(time : Number, interpolation : uint = 1) 
		{
			super(time, interpolation);
		}
	}
}
