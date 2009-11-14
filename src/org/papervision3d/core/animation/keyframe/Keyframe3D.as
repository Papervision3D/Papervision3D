package org.papervision3d.core.animation.keyframe 
{
	import org.papervision3d.core.memory.IDestroyable;	

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class Keyframe3D implements IDestroyable 
	{
		/**
		 * Keyframe time in seconds.
		 */
		public var time :Number;
		
		/** */
		public var interpolation :uint = 1;
		
		/**
		 * Pointer to the first keyframe.
		 */
		public var first :Keyframe3D;
		
		/**
		 * Pointer to the next keyframe.
		 */
		public var next :Keyframe3D;
		
		/**
		 * Pointer to the previous keyframe.
		 */
		public var prev :Keyframe3D;
		
		/**
		 * Pointer to the last keyframe.
		 */
		public var last :Keyframe3D;
		
		/**
		 * Index into track keyFrame array, set by AbstractTrack.
		 */
		public var index :uint;
		
		/**
		 * Constructor.
		 * 
		 * @param time	Time in seconds
		 * @param data
		 */		
		public function Keyframe3D(time:Number, interpolation:uint=1) 
		{
			this.time = time;
			this.interpolation = interpolation;
			this.first = null;
			this.next = null;
			this.prev = null;
			this.index = 0;
		}

		/**
		 * Destroy.
		 */
		public function destroy():void 
		{
			this.first = null;
			this.next = null;
			this.prev = null;
			this.last = null;
		}
	}
}
