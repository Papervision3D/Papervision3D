package org.papervision3d.core.controller
{
	import flash.geom.Matrix3D;
	import flash.utils.getTimer;
	
	import org.papervision3d.core.animation.track.AbstractTrack;
	import org.papervision3d.core.controller.AbstractController;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * Class AnimationController
	 * 
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class AnimationController extends AbstractController
	{
		public var target :DisplayObject3D;
		public var output :Matrix3D;
		public var tracks:Vector.<AbstractTrack>;
		public var startTime : Number;
		public var endTime : Number;
		private var t : int;
		
		/**
		 * 
		 */ 
		public function AnimationController(target:DisplayObject3D)
		{
			super();
			this.target = target;
			init();
		}
		
		/**
		 * 
		 */ 
		private function init():void
		{
			tracks = new Vector.<AbstractTrack>();
			output = new Matrix3D();
			startTime = 0;
			endTime = 0;
			t = getTimer();
		}
		
		/**
		 * 
		 */ 
		override public function update():void
		{
			var cur : int = getTimer();
			var elapsed : int = cur - t;
			var time:Number = elapsed * 0.001;
			var track : AbstractTrack;
			var l:int = tracks.length;
			
			if(time > (endTime - startTime)) 
			{
				t = cur;
				time = 0;
			}
			
			if(l == 1) 
			{
				track = tracks[0];
				track.updateToTime(time);
				if(track.matrixOutput) 
				{
				//	target.transform.matrix3D = track.matrixOutput;
				}
			} 
			else 
			{
				output.identity();
				for(var i:int = 0; i<l; i++)
				{
					track = tracks[i];
					track.updateToTime(time);
				
					if(track.matrixOutput) 
					{
						output.prepend(track.matrixOutput);	
					}
				}
	//			target.transform.matrix3D = output;
			}
		}
		
		/**
		 * Adds a track.
		 * 
		 * @param	track
		 * 
		 * @return boolean indication success.
		 */ 
		public function addTrack(track : AbstractTrack) : Boolean
		{
			var ind:int = tracks.indexOf(track);
			if(ind == -1)
			{
				tracks.push(track);
				updateTimes();
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 */ 
		public function removeTrack(track : AbstractTrack) : Boolean
		{
			var ind : int = tracks.indexOf(track);
			if(ind != -1)
			{
				tracks.splice(ind,1);
				updateTimes();
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 */ 
		private function updateTimes() : void
		{
			if(tracks.length) 
			{
				var track : AbstractTrack;
				
				startTime = Number.MAX_VALUE;
				endTime = -startTime;
				
				for each(track in tracks) 
				{
					startTime = Math.min(startTime, track.startTime);
					endTime = Math.max(endTime, track.endTime);	
				}
			} 
			else 
			{
				startTime = endTime = 0.0;
			}
		}
	}
}
