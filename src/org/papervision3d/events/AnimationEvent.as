package org.papervision3d.events 
{
	import flash.events.Event;
	
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class AnimationEvent extends Event 
	{
		public static const NEXT_FRAME :String = "animationNextFrame";
		
		public var keyframe :Keyframe3D;

		public function AnimationEvent(type : String, keyframe:Keyframe3D=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			this.keyframe = keyframe;
		}

		override public function clone() : Event 
		{
			return new AnimationEvent(type, keyframe, bubbles, cancelable);
		}
	}
}
