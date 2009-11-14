package org.papervision3d.core.animation.track 
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix3D;
	
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	import org.papervision3d.core.animation.keyframe.NumberKeyframe3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class MatrixStackTrack extends AbstractTrack 
	{	
		private var _tracks : Vector.<AbstractTrack>;

		public function MatrixStackTrack() 
		{
			super();
		}

		override public function addKeyframe(keyframe:Keyframe3D):Keyframe3D 
		{
			throw new IllegalOperationError("You can't add keyframes to a MatrixStackChannel!");
		}

		public function addTrack(track : AbstractTrack) : AbstractTrack 
		{
			if(_tracks.indexOf(track) == -1) 
			{
				_tracks.push(track);
				updateTimes();
				return track;
			}
			return null;
		}

		/**
		 * 
		 */
		public function bake(sampleSize : Number=0.0333) :MatrixTrack 
		{
			if(_tracks.length > 1) 
			{
				var track : MatrixTrack = new MatrixTrack();
				var time : Number = startTime;
				
				while(time <= endTime) 
				{
					updateToTime(time);
					track.addKeyframe(new NumberKeyframe3D(time, matrixOutput.rawData));
					time += sampleSize;
				}
				return track;
			}
			return null;
		}

		/**
		 * 
		 */
		override protected function init() : void 
		{
			super.init();
			matrixOutput = new Matrix3D();
			_tracks = new Vector.<AbstractTrack>();
		}
				
		public function removeTrack(track : AbstractTrack) : AbstractTrack 
		{
			var idx : int = _tracks.indexOf(track);
			if(idx >= 0) 
			{
				_tracks.splice(idx, 1);
				updateTimes();
				return track;
			}
			return null;
		}

		override public function updateToTime(time : Number) : Boolean 
		{
			super.updateToTime(time);
			
			var track : AbstractTrack;
			var i : int;
			
			matrixOutput.identity();
			
			for(i = 0; i < _tracks.length; i++) 
			{
				track = _tracks[i];	
				track.updateToTime(time);
				
				if(track.matrixOutput) 
				{
					matrixOutput.prepend(track.matrixOutput);
				}
			}
			
			return true;
		}
		
		private function updateTimes() : void 
		{
			if(_tracks.length) 
			{
				var track : AbstractTrack;
				
				startTime = Number.MAX_VALUE;
				endTime = -startTime;
				
				for each(track in _tracks) 
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
		
		public function get tracks() : Vector.<AbstractTrack> 
		{
			return _tracks;
		}
	}
}
