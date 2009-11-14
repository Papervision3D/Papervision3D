package org.papervision3d.core.animation.track {
	import flash.geom.Matrix3D;	
	
	import org.papervision3d.core.animation.track.NumberTrack;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class ScaleTrack extends NumberTrack 
	{
		public function ScaleTrack() 
		{
			super();
		}
		
		override protected function init() : void 
		{
			super.init();
			matrixOutput = new Matrix3D();
		}
		
		override public function updateToTime(time : Number) : Boolean 
		{
			if(super.updateToTime(time)) 
			{	
				var tmp  :Vector.<Number> = this.matrixOutput.rawData;
				tmp[0] = floatOutput[0];
				tmp[5] = floatOutput[1];
				tmp[10] = floatOutput[2];
				this.matrixOutput.rawData = tmp;
				
				return true;
			} 
			else 
			{
				trace("[ScaleTrack] error");
			}
			return false;
		}
	}
}
