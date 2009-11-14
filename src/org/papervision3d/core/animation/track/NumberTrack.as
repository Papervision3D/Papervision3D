package org.papervision3d.core.animation.track 
{
	import flash.errors.IllegalOperationError;
	
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	import org.papervision3d.core.animation.keyframe.NumberKeyframe3D;	
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class NumberTrack extends AbstractTrack 
	{	
		/**
		 * 
		 */
		public function NumberTrack() 
		{
			super();
		}

		/**
		 * 
		 */
		override protected function init() : void 
		{
			super.init();
		}

		/**
		 * 
		 */
		override public function addKeyframe(keyframe:Keyframe3D) : Keyframe3D 
		{
			if(!(keyframe is NumberKeyframe3D)) 
			{
				throw new IllegalOperationError("Keyframe should be a NumberKeyframe3D!");	
			}
			
			if(!NumberKeyframe3D(keyframe).data || NumberKeyframe3D(keyframe).data.length < 1) 
			{
				throw new IllegalOperationError("Keyframe should have at least one value!");
			}
			
			var dataSize : int = this.keyFrames.length ? NumberKeyframe3D(this.keyFrames[0]).data.length : NumberKeyframe3D(keyframe).data.length;
			if(dataSize != NumberKeyframe3D(keyframe).data.length) 
			{
				throw new IllegalOperationError("All keyframes should have the same data size!");	
			}
			
			if(this.keyFrames.length == 0) 
			{
				this.floatOutput = new Vector.<Number>(dataSize);
			}
			return super.addKeyframe(keyframe);
		}

		/**
		 * 
		 */
		override public function updateToTime(time : Number) : Boolean 
		{
			if(super.updateToTime(time)) 
			{
				var currentData :Vector.<Number> = NumberKeyframe3D(current).data;
				var nextData :Vector.<Number> = current.next ? NumberKeyframe3D(current.next).data : null;
				var interpolation :int = nextData && current.interpolation == 1 ? current.interpolation : 0;
				var i : int;
				
				switch(interpolation) 
				{
					case 0:	// step
						floatOutput = currentData;
						break;
						
					case 1: // linear
					default:
						for(i = 0; i < currentData.length; i++) 
						{
							floatOutput[i] = currentData[i] + (alpha * (nextData[i] - currentData[i]));
						}
						break;
				}
				return true;
			}
			return false;
		}
	}
}
