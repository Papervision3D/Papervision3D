package org.papervision3d.core.geom
{
	public class UVCoord
	{
		/** */
		public var u :Number;
		
		/** */
		public var v :Number;
		
		/**
		 * 
		 */ 
		public function UVCoord(u:Number=0, v:Number=0)
		{
			this.u = u;
			this.v = v;
		}
		
		public function toString():String{
			return "u: "+u+" v:"+v;
		}
	}
}