package org.papervision3d.core.animation.track 
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix3D;
	
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	import org.papervision3d.core.animation.keyframe.NumberKeyframe3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class MatrixTrack extends AbstractTrack 
	{
		/**
		 * Constructor.
		 */
		public function MatrixTrack() 
		{
			super();
		}

		/**
		 * 
		 */
		override protected function init() : void 
		{
			super.init();
			this.matrixOutput = new Matrix3D();
		}

		/**
		 * 
		 */
		override public function addKeyframe(keyframe:Keyframe3D):Keyframe3D 
		{
			if(!(keyframe is NumberKeyframe3D)) 
			{
				throw new IllegalOperationError("Keyframe should be a NumberKeyframe3D!");	
			}
			
			if(!NumberKeyframe3D(keyframe).data || NumberKeyframe3D(keyframe).data.length < 16) 
			{
				throw new IllegalOperationError("Keyframe should have at least 16 values!");
			}
			return super.addKeyframe(keyframe);
		}

		/**
		 * 
		 */
		override public function destroy() : void 
		{
			super.destroy();
			this.matrixOutput = null;
		}

		/**
		 * 
		 */
		override public function updateToTime(time : Number) : Boolean 
		{
			if(super.updateToTime(time)) 
			{
				var i :int;
				var currentData :Vector.<Number> = NumberKeyframe3D(current).data;
				var nextData :Vector.<Number> = current.next ? NumberKeyframe3D(current.next).data : null;
				var interpolation :int = nextData && current.interpolation == 1 ? current.interpolation : 0;
				var tmp :Vector.<Number> = new Vector.<Number>(16);
				
				switch(interpolation) 
				{
					case 0:	// step
						matrixOutput.rawData = currentData;
						break;
						
					case 1: // linear
					default:
						for(i = 0; i < currentData.length; i++) 
						{
							tmp[i] = currentData[i] + (alpha * (nextData[i] - currentData[i]));
						}
						matrixOutput.rawData = tmp;
						break;
				}
				
				return true;
			} 
			else 
			{
				return false;
			}
		}
	}
}
