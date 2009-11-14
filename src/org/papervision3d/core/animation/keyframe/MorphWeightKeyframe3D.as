package org.papervision3d.core.animation.keyframe 
{
	import org.papervision3d.core.animation.keyframe.NumberKeyframe3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class MorphWeightKeyframe3D extends NumberKeyframe3D 
	{	
		/** */
		public var targetWeight : int;
		
		/**
		 * 
		 */
		public function MorphWeightKeyframe3D(time : Number, data : Vector.<Number>, targetWeight : int, interpolation : uint = 1) 
		{
			super(time, data, interpolation);
			this.targetWeight = targetWeight;
		}
	}
}

