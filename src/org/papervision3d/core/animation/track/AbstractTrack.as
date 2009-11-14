package org.papervision3d.core.animation.track 
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	
	import org.papervision3d.core.animation.clip.AnimationClip;
	import org.papervision3d.core.animation.keyframe.Keyframe3D;
	import org.papervision3d.core.memory.IDestroyable;
	import org.papervision3d.events.AnimationEvent;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class AbstractTrack extends EventDispatcher implements IDestroyable 
	{
		/** The track keyframes */
		public var keyFrames :Vector.<Keyframe3D>;
		
		/** */
		public var matrixOutput : Matrix3D;
		
		/** */
		public var floatOutput : Vector.<Number>;
		
		/** Clips */
		public var animationClips :Vector.<AnimationClip>;
		
		/** Start time in seconds. */
		public var startTime :Number;
		
		/** End time in seconds. */
		public var endTime :Number;
		
		/** The current keyframe. */
		public var current :Keyframe3D;
		
		/** A value between 0 and 1 indicating the relative position between keyframes. */
		public var alpha :Number;
		
		/** The current animation clip, if any. */
		public var currentClip :AnimationClip;
		
		private var _clipByName :Object;
		
		private var _fireEvents :Boolean;
		
		private var _nextFrameEvent :AnimationEvent;

		/**
		 * Constructor.
		 */
		public function AbstractTrack() 
		{
			super();
			init();
		}

		/**
		 * 
		 */
		protected function init() : void 
		{
			keyFrames = new Vector.<Keyframe3D>();
			animationClips = new Vector.<AnimationClip>();
			_clipByName = new Object();
			_fireEvents = true;
			_nextFrameEvent = new AnimationEvent(AnimationEvent.NEXT_FRAME);
			removeAllKeyframes();			
		}
		
		/**
		 * Add an animation clip.
		 * 
		 * @param clip
		 * 
		 * @return	The added clip
		 */
		public function addAnimationClip(clip : AnimationClip):AnimationClip 
		{
			if(animationClips.indexOf(clip) == -1) 
			{
				animationClips.push(clip);
				_clipByName[clip.name] = clip;
			}
			return null;
		}
		

		/**
		 * Adds a keyframe to this track.
		 * 
		 * @param keyframe
		 * 
		 * @return The added keyframe or null on failure.
		 */
		public function addKeyframe(keyframe:Keyframe3D):Keyframe3D 
		{
			if(keyFrames.indexOf(keyframe) == -1) 
			{
				if(keyFrames.length) 
				{
					if(keyframe.time <= keyFrames[keyFrames.length-1].time) 
					{
						throw new IllegalOperationError("Keyframes must be added in time order!");
					}
				}
				keyFrames.push(keyframe);
				updateTrack();
				return keyframe;
			}
			return null;
		}
		
		/**
		 * 
		 */
		public function destroy():void 
		{
			if(keyFrames) 
			{
				removeAllKeyframes();
			}
			keyFrames = null;
			current = null;
		}
		
		/**
		 * Gets an array with all defined animation clip names.
		 * 
		 * @return Array of clip names.
		 */
		public function getAnimationClipNames():Array 
		{
			var names :Array = new Array();
			var clip : AnimationClip;
			for each(clip in animationClips) 
			{
				names.push(clip.name);
			}
			return names;	
		}
		
		/**
		 * Removes an animation clip.
		 * 
		 * @param clip
		 * 
		 * @return The removed clip.
		 */
		public function removeAnimationClip(clip : AnimationClip) : AnimationClip 
		{
			var pos : int = animationClips.indexOf(clip);
			if(pos >= 0) 
			{
				animationClips.splice(pos, 1);
				_clipByName[clip.name] = null;
				return clip;
			}
			return null;
		}
		
		/**
		 * Removes a keyframe from this track.
		 * 
		 * @param keyframe
		 * 
		 * @return The added keyframe or null on failure.
		 */
		public function removeKeyframe(keyframe:Keyframe3D):Keyframe3D 
		{
			var pos :int = keyFrames.indexOf(keyframe);
			if(pos >= 0) 
			{
				keyFrames.splice(pos, 1);
				updateTrack();
				return keyframe;
			}
			return null;
		}
		
		/**
		 * Removes all keyframes from this track.
		 */
		public function removeAllKeyframes():void 
		{
			while(keyFrames.length) 
			{
				keyFrames.pop().destroy();
			}
			updateTrack();
		}
		
		/**
		 * Sets the current animation clip.
		 * 
		 * @param clipName	The clip's name or null to clear playing of animation clip.
		 * 
		 * @return	Boolean indicating success
		 */
		public function setAnimationClip(clipName:String) : Boolean 
		{
			var clip : AnimationClip = _clipByName[clipName];
			if(clip) 
			{
				currentClip = clip;
				return true;
			} 
			else 
			{
				currentClip = null;
				return false;
			}
		}

		/**
		 * Updates this frame by time.
		 * 
		 * @param time	Time in seconds.
		 */
		public function updateToTime(time:Number):Boolean 
		{
			if(!keyFrames || !keyFrames.length) 
			{
				current = null;
				return false;
			}
			
			var sf :int = currentClip ? currentClip.start : 0;
			var ef :int = currentClip ? currentClip.end : keyFrames.length - 1;
			var st :Number = currentClip ? keyFrames[sf].time : startTime;
			var et :Number = currentClip ? keyFrames[ef].time : endTime;
			var prev : Keyframe3D;
			var needInterpolate :Boolean = true;
			
			alpha = 0;
			prev = current = current || keyFrames[sf];
			
			if(time < st) 
			{
				current = keyFrames[sf];
				needInterpolate = false;
			} 
			else if(time > et) 
			{
				current = keyFrames[ef];
				needInterpolate = false;
			} 
			else if(time < current.time)
			{
				while(current && time < current.time) 
				{
					current = current.prev;
				}
				current = current || keyFrames[sf];
				if(current.time < keyFrames[sf].time) current = keyFrames[sf];
			} 
			else 
			{
				while(current.next && time > current.next.time) 
				{
					current = current.next;
				}
				current = current || keyFrames[ef];
				if(current.time > keyFrames[ef].time) current = keyFrames[ef];
			}
			
			if(needInterpolate) 
			{
				var duration :Number = current.next ? current.next.time - current.time : endTime - current.time;
				alpha = (time - current.time) / duration;
			}
			
			if(_fireEvents && prev !== current) 
			{
				_nextFrameEvent.keyframe = current;
				dispatchEvent(_nextFrameEvent);
			}
			
			return true;
		}

		/**
		 * Updates keyframe pointers and this track's start- and endTime.
		 */
		private function updateTrack():void 
		{
			if(keyFrames.length) 
			{
				var kf :Keyframe3D;
				var i :int;

				startTime = Number.MAX_VALUE;
				endTime = -startTime;

				for(i = 0; i < keyFrames.length; i++) 
				{
					kf = keyFrames[i];
					
					kf.first = keyFrames[0];
					kf.last = keyFrames[keyFrames.length-1];
					kf.next = i + 1 < keyFrames.length ? keyFrames[i + 1] : null;
					kf.prev = i > 0 ? keyFrames[i - 1] : null;
					kf.index = i;
					
					startTime = Math.min(startTime, kf.time);
					endTime = Math.max(endTime, kf.time);
				}
			} 
			else 
			{
				startTime = endTime = alpha = 0;
			}
		}
		
		/**
		 * Duration of this track.
		 */	
		public function get duration():Number 
		{
			return endTime - startTime;
		}
		
		/**
		 * End time of current animation clip or track's #endTime if no clip is active.
		 * 
		 * @return End time in seconds.
		 */
		public function get clipEndTime():Number 
		{
			return (currentClip ? this.keyFrames[currentClip.end].time : endTime);
		}
		
		/**
		 * Start time of current animation clip or track's #startTime if no clip is active.
		 * 
		 * @return Start time in seconds.
		 */
		public function get clipStartTime():Number 
		{
			return (currentClip ? this.keyFrames[currentClip.start].time : startTime);
		}
	}
}
