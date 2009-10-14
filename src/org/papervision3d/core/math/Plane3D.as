package org.papervision3d.core.math 
{
	import flash.geom.Matrix3D;	
	import flash.geom.Vector3D;																						

	public class Plane3D 
	{	
		/** */
		public var normal : Vector3D;
		
		/** */
		public var d : Number;
		
		private static var _dummy0 : Vector3D = new Vector3D();
		private static var _dummy1 : Vector3D = new Vector3D();
		
		/**
		 * Constructor.
		 * 
		 * @param normal
		 * @param ptOnPlane
		 */
		public function Plane3D( normal:Vector3D=null, ptOnPlane:Vector3D=null ):void 
		{
			if(normal && ptOnPlane) 
			{
				this.normal = normal;
				this.normal.normalize();
				this.d = -this.normal.dotProduct(ptOnPlane);
			} 
			else 
			{
				this.normal = new Vector3D();
				this.d = 0;	
			}
		}

		/**
		 * Clone.
		 */
		public function clone():Plane3D 
		{
			var plane :Plane3D = new Plane3D();
			plane.normal = this.normal.clone();
			plane.d = this.d;
			return plane;
		}
		
		/**
		 * Distance of point to plane.
		 * 
		 * @param	v
		 * @return
		 */
		public function distance(pt:Vector3D):Number 
		{
			return pt.dotProduct(normal) + d;
		}
		
		/**
		 * Normalize this plane.
		 */
		public function normalize():void 
		{
			var mag :Number = normal.length;
			if(mag != 0 && mag != 1) 
			{
				mag = 1 / mag;
				this.normal.x *= mag;
				this.normal.y *= mag;
				this.normal.z *= mag;
				this.d *= mag;
			}
		}
		
		/**
		 * Sets the plane by coefficients. 
		 * 
		 * @param a
		 * @param b
		 * @param c
		 * @param d
		 */
		public function setCoefficients(a:Number, b:Number, c:Number, d:Number):void 
		{
			this.normal.x = a;
			this.normal.y = b;
			this.normal.z = c;
			this.d = d;	
		}

		/**
		 * Sets the plane by a normal and a point on the plane.
		 *  
		 *  @param normal
		 *  @param point
		 */
		public function setNormalAndPoint(normal:Vector3D, point:Vector3D):void 
		{
			this.normal = normal;
			this.d = -this.normal.dotProduct(point);
		}

		/**
		 * Sets the plane by three points.
		 * 
		 * @param p0
		 * @param p1
		 * @param p2
		 */
		public function setThreePoints(p0:Vector3D, p1:Vector3D, p2:Vector3D):void 
		{

			this.normal = p1.subtract(p0);
			this.normal = this.normal.crossProduct(p2.subtract(p0));
			this.normal.normalize();
			this.d = -this.normal.dotProduct(p0);
		}
		
		/**
		 * Transforms this plane by a matrix. @see http://mormegil.wz.cz/prog/3dref/D3DXmath.htm
		 * 
		 * @param matrix	The matrix to transform this plane with.
		 * @param plane		Optional plane to be used as return value.
		 * 
		 * @return	The transformed plane.
		 */
		public function transform(matrix : Matrix3D, plane:Plane3D=null):Plane3D 
		{
			var m :Vector.<Number> = matrix.rawData;
			var u :Vector3D = this.normal;
			var ux :Number = u.x;
			var uy :Number = u.y;
			var uz :Number = u.z;
			var dx :Number = -d*ux;
			var dy :Number = -d*uy;
			var dz :Number = -d*uz;

			// inlined Matrix3D.transformVector to prevent new Vector3D's being created
			// w = 1
			_dummy0.x = dx * m[0] + dy * m[4] + dz * m[8] + m[12];
            _dummy0.y = dx * m[1] + dy * m[5] + dz * m[9] + m[13];
            _dummy0.z = dx * m[2] + dy * m[6] + dz * m[10] + m[14];
			_dummy0.w = dx * m[3] + dy * m[7] + dz * m[11] + m[15];
			
			// w = 0
			_dummy1.x = ux * m[0] + uy * m[4] + uz * m[8];
            _dummy1.y = ux * m[1] + uy * m[5] + uz * m[9];
            _dummy1.z = ux * m[2] + uy * m[6] + uz * m[10];
			_dummy1.w = 0;
			
			var vn :Number = 1 / _dummy1.length;
			
			plane = plane || new Plane3D();
			plane.normal.x = vn * _dummy1.x;
			plane.normal.y = vn * _dummy1.y;
			plane.normal.z = vn * _dummy1.z;
			plane.d = -vn * _dummy1.dotProduct(_dummy0);

			return plane;
		}

		public function destroy():void
		{
			normal = null;
		}

		/**
		 * toString.
		 */
		public function toString():String 
		{
			return "[Plane3D normal: " + normal + " d: " + d + "]";
		}
		
		public static function fromCoefficients(a:Number, b:Number, c:Number, d:Number):Plane3D 
		{
			var plane :Plane3D = new Plane3D();
			plane.setCoefficients(a, b, c, d);
			plane.normalize();
			return plane;
		}
		
		public static function fromNormalAndPoint(normal:Vector3D, point:Vector3D):Plane3D 
		{
			var plane :Plane3D = new Plane3D();
			normal.normalize();
			plane.setNormalAndPoint(normal, point);
			return plane;
		}
		
		public static function fromThreePoints(a:Vector3D, b:Vector3D, c:Vector3D):Plane3D 
		{
			var plane :Plane3D = new Plane3D();
			plane.setThreePoints(a, b, c);
			return plane;
		}
	}
}