package org.papervision3d.core.animation.keyframe 
{
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class NumberKeyframe3D extends Keyframe3D 
	{
		public var data :Vector.<Number>;
		
		public function NumberKeyframe3D(time : Number, data:Vector.<Number>, interpolation : uint = 1) 
		{
			super(time, interpolation);
			this.data = data;
		}
	}
}
