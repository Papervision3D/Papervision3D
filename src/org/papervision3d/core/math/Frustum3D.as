package org.papervision3d.core.math
{
	import flash.geom.Matrix3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.math.utils.MathUtil;
	
	/**
	 * Frustum3D.
	 * 
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class Frustum3D
	{
		public static const WORLD_PLANES :uint = 0;
		public static const VIEW_PLANES :uint = 1;
		public static const SCREEN_PLANES :uint = 2;
		
		public static const NEAR :uint = 0;
		public static const FAR :uint = 1;
		public static const LEFT :uint = 2;
		public static const RIGHT :uint = 3;
		public static const TOP :uint = 4;
		public static const BOTTOM :uint = 5;
		
		public var camera :Camera3D;
		public var screenClippingPlanes :Vector.<Plane3D>;
		public var viewClippingPlanes :Vector.<Plane3D>;
		public var worldClippingPlanes :Vector.<Plane3D>;
		
		public var worldBoundingSphere :BoundingSphere3D;
		
		/**
		 * Constructor.
		 */ 
		public function Frustum3D(camera:Camera3D=null)
		{
			this.camera = camera;
			this.worldBoundingSphere = new BoundingSphere3D();
			initPlanes();
		}
		
		/**
		 * 
		 */ 
		protected function initPlanes():void 
		{
			var i :int;
			
			this.screenClippingPlanes = new Vector.<Plane3D>(6, true);
			this.viewClippingPlanes = new Vector.<Plane3D>(6, true);
			this.worldClippingPlanes = new Vector.<Plane3D>(6, true);
			
			for (i = 0; i < 6;  i++)
			{
				this.screenClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
				this.viewClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
				this.worldClippingPlanes[i] = Plane3D.fromCoefficients(0, 0, 1, 0);
			}	
			
			this.screenClippingPlanes[ NEAR ].setCoefficients(0, 0, -1, 1);
			this.screenClippingPlanes[ FAR ].setCoefficients(0, 0, 1, 1);
			this.screenClippingPlanes[ LEFT ].setCoefficients(1, 0, 0, 1);
			this.screenClippingPlanes[ RIGHT ].setCoefficients(-1, 0, 0, 1);
			this.screenClippingPlanes[ TOP ].setCoefficients(0, -1, 0, 1);
			this.screenClippingPlanes[ BOTTOM ].setCoefficients(0, 1, 0, 1);
		}
		
		/**
		 * 
		 */ 
		public function calcFrustumVertices(camera:Camera3D):void
		{
			var vertices :Vector.<Vertex> = new Vector.<Vertex>(10, true);
			var fov :Number = camera.fov;
			var near :Number = camera.near;
			var far :Number = camera.far;
			var ratio :Number = camera.aspectRatio;
			
			// compute width and height of the near and far section
			var angle : Number = MathUtil.TO_RADIANS * fov * 0.5;
			var tang :Number = Math.tan(angle);
			var nh :Number = near * tang;
			var nw :Number = nh * ratio;
			var fh :Number = far * tang;
			var fw :Number = fh * ratio;
			
			var nc :Vertex = new Vertex(0, 0, -near);
			var fc :Vertex = new Vertex(0, 0, -far);
			
			var ntl :Vertex = new Vertex(-nw * 0.5,  nh * 0.5, -near);
			var nbl :Vertex = new Vertex(-nw * 0.5, -nh * 0.5, -near);
			var nbr :Vertex = new Vertex( nw * 0.5, -nh * 0.5, -near);
			var ntr :Vertex = new Vertex( nw * 0.5,  nh * 0.5, -near);
			
			var ftl :Vertex = new Vertex(-fw * 0.5,  fh * 0.5, -far);
			var fbl :Vertex = new Vertex(-fw * 0.5, -fh * 0.5, -far);
			var fbr :Vertex = new Vertex( fw * 0.5, -fh * 0.5, -far);
			var ftr :Vertex = new Vertex( fw * 0.5,  fh * 0.5, -far);
		}
		
		/**
		 * Extract frustum planes.
		 * 
		 * @param matrix		The matrix to extract the planes from (P for eye-space, M*P for world-space).
		 * @param which			Which planes to extract. Valid values are VIEW_PLANES, WORLD_PLANES or SCREEN_PLANES.
		 * @param normalize		Whether to normalize the planes. Default is true.
		 * @param flipNormals	Whether to flip the plane normals.
		 * 
		 * @see	#VIEW_PLANES
		 * @see	#WORLD_PLANES
		 * @see #SCREEN_PLANES
		 */
		public function extractPlanes(matrix:Matrix3D, which:int, normalize:Boolean=true, flipNormals:Boolean=false) : void 
		{	
			var m :Vector.<Number> = matrix.rawData;
			var planes :Vector.<Plane3D>;
			var i :int;
			
			switch( which )
			{
				case SCREEN_PLANES:
					return;
				case WORLD_PLANES:
					planes = this.worldClippingPlanes;
					break;
				case VIEW_PLANES:
				default:
					planes = this.viewClippingPlanes;
					break;
			}
			
			planes[TOP].setCoefficients(
				-m[1] + m[3],
				-m[5] + m[7],
				-m[9] + m[11],
				-m[13] + m[15]
			);
			
			planes[BOTTOM].setCoefficients(
				m[1] + m[3],
				m[5] + m[7],
				m[9] + m[11],
			 	m[13] + m[15]
			);
			
			planes[LEFT].setCoefficients(
				m[0] + m[3],
				m[4] + m[7],
				m[8] + m[11],
				m[12] + m[15]
			);
			
			planes[RIGHT].setCoefficients(
				-m[0] + m[3],
				-m[4] + m[7],
				-m[8] + m[11],
				-m[12] + m[15]
			);
			
			planes[NEAR].setCoefficients(
				m[2] + m[3],
				m[6] + m[7],
				m[10] + m[11],
				m[14] + m[15]
			);
			
			planes[FAR].setCoefficients(
				-m[2] + m[3],
				-m[6] + m[7],
				-m[10] + m[11],
				-m[14] + m[15]
			);
			
			if(normalize) 
			{
				for (i = 0; i < 6; i++)
				{
					planes[i].normalize();
				}
			}
			
			if(flipNormals) 
			{
				for (i = 0; i < 6; i++)
				{
					planes[i].normal.negate();
				}
			}
		}
	}
}