package org.papervision3d.core.animation.track {
	import flash.geom.Vector3D;	
	import flash.geom.Matrix3D;	
	
	import org.papervision3d.core.animation.track.NumberTrack;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class RotationTrack extends NumberTrack 
	{
		private var _axis : Vector3D;

		public function RotationTrack() 
		{
			super();
		}

		override protected function init() : void {
			super.init();
			
			this.matrixOutput = new Matrix3D();
			_axis = new Vector3D();
		}

		override public function updateToTime(time : Number) : Boolean 
		{
			if(super.updateToTime(time)) 
			{
				_axis.x = floatOutput[0];
				_axis.y = floatOutput[1];
				_axis.z = floatOutput[2];
				
				this.matrixOutput.identity();
				this.matrixOutput.appendRotation(floatOutput[3], _axis);
				
				return true;
			}
			else 
			{
				trace("[RotationTrack] error");
			}
			return false;
		}
	}
}
