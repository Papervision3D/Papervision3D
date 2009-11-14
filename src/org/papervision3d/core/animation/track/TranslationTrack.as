package org.papervision3d.core.animation.track 
{
	import flash.geom.Matrix3D;
	
	/**
	 * @author timknip
	 */
	public class TranslationTrack extends NumberTrack 
	{
		public function TranslationTrack() 
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
				tmp[12] = floatOutput[0];
				tmp[13] = floatOutput[1];
				tmp[14] = floatOutput[2];
				this.matrixOutput.rawData = tmp;
				return true;
			}
			else 
			{
				trace("[TranslationTrack] error");
			}
			return false;
		}
	}
}
