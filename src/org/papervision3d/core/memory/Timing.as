package org.papervision3d.core.memory
{
	import flash.utils.getTimer;
	
	public class Timing
	{
		public function Timing()
		{
		}
		
		private static var _startTime: Number = 0;
		
		
		public static function startTime():void{
			_startTime = getTimer();
		}
		
		public static function stopTime():Number{
			return getTimer()-_startTime;
		}
		
		public static function printInfo():void{
			trace("TIME INFO:");
			trace("Render Time: "+renderTime+" ms");
			trace("Project Time: "+projectTime+" ms");
			trace("Transform Time: "+transformTime+" ms");
			trace("-----||-----");
		}

		public static var renderTime : Number = 0;
		public static var projectTime : Number = 0;
		public static var transformTime : Number = 0;
		
	}
}