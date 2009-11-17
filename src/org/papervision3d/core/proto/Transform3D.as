package org.papervision3d.core.proto
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.ns.pv3d;
	
	/**
	 * Transform3D.
	 * <p></p>
	 * 
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class Transform3D
	{
		use namespace pv3d;
		
		/** */
		public static var DEFAULT_LOOKAT_UP :Vector3D = new Vector3D(0, -1, 0);
		
		/** */
		public var worldTransform :Matrix3D;
		
		/** */
		public var viewTransform :Matrix3D;
		
		/** */
		public var screenTransform :Matrix3D;
		
		pv3d var scheduledLookAt :Transform3D;
		
		private var _matrix :Matrix3D;
		private var _components :Vector.<Vector3D>;
		private var _dirty :Boolean;
		
		/**
		 * Constructor.
		 */ 
		public function Transform3D()
		{
			_components = new Vector.<Vector3D>(3, true);
			_components[0] = new Vector3D();
			_components[1] = new Vector3D();
			_components[2] = new Vector3D(1, 1, 1);
			
			_matrix = new Matrix3D();
			_matrix.recompose(_components);
			
			this.worldTransform = new Matrix3D();
			this.viewTransform = new Matrix3D();
			this.screenTransform = new Matrix3D();
		}
		
		/**
		 * 
		 */ 
		public function update():void
		{
			if (_dirty)
			{
				_dirty = false;
				_matrix.recompose(_components);
			}	
		}
		
		/**
		 * 
		 */
		public function get dirty():Boolean
		{
			return _dirty;
		} 
		
		public function set dirty(value:Boolean):void
		{
			_dirty = value;
		}
		
		/**
		 * 
		 */
		public function get matrix():Matrix3D
		{
			return _matrix;
		} 
		
		public function set matrix(value:Matrix3D):void
		{
			_components = value.decompose();
			_matrix.recompose(_components);	
		}
		
		/**
		 * 
		 */
		public function get rotation():Vector3D
		{
			return _components[1];
		} 
		
		public function set rotation(value:Vector3D):void
		{
			_components[1] = value;
			_dirty = true;
		}
		
		/**
		 * 
		 */
		public function get scale():Vector3D
		{
			return _components[2];
		} 
		
		public function set scale(value:Vector3D):void
		{
			_components[2] = value;
			_dirty = true;
		}
		
		/**
		 * 
		 */
		public function get translation():Vector3D
		{
			return _components[0];
		} 
		
		public function set translation(value:Vector3D):void
		{
			_components[0] = value;
			_dirty = true;
		}
	}
}