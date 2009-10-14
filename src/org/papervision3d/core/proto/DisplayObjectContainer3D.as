package org.papervision3d.core.proto
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class DisplayObjectContainer3D
	{
		use namespace pv3d;
		
		/** */
		public var name :String;
		
		/** */
		public var parent :DisplayObjectContainer3D;
		
		/** */
		public var transform :Transform3D;
		
		/** */
		public var cullingState :int;
		
		/** */
		pv3d var _children :Vector.<DisplayObject3D>;
		
		/** */
		private static var _newID :int = 0;
		
		/**
		 * 
		 */ 
		public function DisplayObjectContainer3D(name:String=null)
		{
			this.name = name || "Object" + (_newID++);
			
			this.transform = new Transform3D();
			this.cullingState = 0;
			
			_children = new Vector.<DisplayObject3D>();
		}

		/**
		 * 
		 */ 
		public function addChild(child:DisplayObject3D):DisplayObject3D
		{
			var root :DisplayObjectContainer3D = this;
			while( root.parent ) root = root.parent;
			
			if (root.findChild(child, true) )
			{
				throw new Error("This child was already added to the scene!");
			}
			
			child.parent = this;
			child.transform.parent = this.transform;
			
			_children.push(child);
			
			return child;	
		}
		
		/**
		 * Find a child.
		 * 
		 * @param	child	The child to find.
		 * @param	deep	Whether to search recursivelly
		 * 
		 * @return The found child or null on failure.
		 */ 
		public function findChild(child:DisplayObject3D, deep:Boolean=true):DisplayObject3D
		{
			var index :int = _children.indexOf(child);
			
			if (index < 0)
			{
				if (deep)
				{
					var object :DisplayObject3D;
					for each (object in _children)
					{
						var c :DisplayObject3D = object.findChild(child, true);
						if (c) return c;
					}
				}
			}
			else
			{
				return _children[index];
			}
			
			return null;
		}
		
		/**
		 * 
		 */ 
		public function getChildAt(index:uint):DisplayObject3D
		{
			if (index < _children.length)
			{
				return _children[index];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Gets a child by name.
		 * 
		 * @param	name	Name of the DisplayObject3D to find.
		 * @param	deep	Whether to perform a recursive search
		 * 
		 * @return	The found DisplayObject3D or null on failure.
		 */ 
		public function getChildByName(name:String, deep:Boolean=false):DisplayObject3D
		{
			var child :DisplayObject3D;
			
			for each (child in _children)
			{
				if (child.name == name)
				{
					return child;
				}
				
				if (deep)
				{
					var c :DisplayObject3D = child.getChildByName(name, true);
					if (c) return c;
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 */
		public function lookAt(object:DisplayObject3D, up:Vector3D=null):void
		{
			transform.lookAt(object.transform, up);
		}
		
		/**
		 * Removes a child.
		 * 
		 * @param	child	The child to remove.
		 * @param	deep	Whether to perform a recursive search.
		 * 
		 * @return	The removed child or null on failure.
		 */ 
		public function removeChild(child:DisplayObject3D, deep:Boolean=false):DisplayObject3D
		{
			var index :int = _children.indexOf(child);
			if (index < 0)
			{
				if (deep)
				{
					var object :DisplayObject3D;
					for each (object in _children)
					{
						var c :DisplayObject3D = object.removeChild(object, true);
						if (c) 
						{
							c.parent = null;
							return c;
						}
					}
				}
				return null;	
			}
			else
			{
				child = _children.splice(index, 1)[0];
				child.parent = null;
				return child;
			}
		}
		
		/**
		 * 
		 */ 
		public function removeChildAt(index:int):DisplayObject3D
		{
			if (index < _children.length)
			{
				return _children.splice(index, 1)[0];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 
		 */
		public function rotateAround(degrees:Number, axis:Vector3D, pivot:*=null):void
		{
			pivot = pivot || this.parent;
			
			var pivotPoint :Vector3D;
			
			if (pivot === this.parent)
			{
				pivotPoint = this.parent.transform.localPosition;
			}
			else if (pivot is Vector3D)
			{
				pivotPoint = pivot as Vector3D;	
			}

			if (pivotPoint)
			{
				transform.rotate(axis, false);
			}
		}
		
		/**
		 * 
		 */ 
		public function get x():Number
		{
			return transform.localPosition.x;
		}
		
		public function set x(value:Number):void
		{
			transform.localPosition.x = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get y():Number
		{
			return transform.localPosition.y;
		}
		
		public function set y(value:Number):void
		{
			transform.localPosition.y = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get z():Number
		{
			return transform.localPosition.z;
		}
		
		public function set z(value:Number):void
		{
			transform.localPosition.z = value;
			transform.dirty = true;
		}
	
		/**
		 * 
		 */ 
		public function get rotationX():Number
		{
			return transform.localEulerAngles.x;
		}
		
		public function set rotationX(value:Number):void
		{
			transform.localEulerAngles.x = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get rotationY():Number
		{
			return transform.localEulerAngles.y;
		}
		
		public function set rotationY(value:Number):void
		{
			transform.localEulerAngles.y = value
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get rotationZ():Number
		{
			return transform.localEulerAngles.z;
		}
		
		public function set rotationZ(value:Number):void
		{
			transform.localEulerAngles.z = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get scaleX():Number
		{
			return transform.localScale.x;
		}
		
		public function set scaleX(value:Number):void
		{
			transform.localScale.x = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get scaleY():Number
		{
			return transform.localScale.y;
		}
		
		public function set scaleY(value:Number):void
		{
			transform.localScale.y = value;
			transform.dirty = true;
		}
		
		/**
		 * 
		 */ 
		public function get scaleZ():Number
		{
			return transform.localScale.z;
		}
		
		public function set scaleZ(value:Number):void
		{
			transform.localScale.z = value;
			transform.dirty = true;
		}
	}
}