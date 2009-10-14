package org.papervision3d.core.math
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class Quaternion 
	{
		private var _matrix:Matrix3D;
		
		public static const EPSILON:Number = 0.000001;
		public static const DEGTORAD:Number = (Math.PI/180.0);
		public static const RADTODEG:Number = (180.0/Math.PI);
		
		/** */
		public var x:Number;
		
		/** */
		public var y:Number;
		
		/** */
		public var z:Number;
		
		/** */
		public var w:Number;
		
		/**
		 * constructor.
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	w
		 * @return
		 */
		public function Quaternion( x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 1 )
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
			
			_matrix = new Matrix3D();
		}
		
		/**
		 * Clone.
		 * 
		 */
		public function clone():Quaternion
		{
			return new Quaternion(this.x, this.y, this.z, this.w);
		}
		
		/**
		 * Multiply.
		 * 
		 * @param	a
		 * @param	b
		 */
		public function calculateMultiply( a:Quaternion, b:Quaternion ):void
		{
			this.x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y;
			this.y = a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x;
			this.z = a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w;
			this.w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z;
		}
		
		/**
		 * Creates a Quaternion from a axis and a angle.
		 * 
		 * @param	x 	X-axis
		 * @param	y 	Y-axis
		 * @param	z 	Z-axis
		 * @param	angle	angle in radians.
		 * 
		 * @return
		 */
		public function setFromAxisAngle( x:Number, y:Number, z:Number, angle:Number ):void
		{
			var sin:Number = Math.sin( angle / 2 );
			var cos:Number = Math.cos( angle / 2 );
			this.x = x * sin;
			this.y = y * sin;
			this.z = z * sin;
			this.w = cos;
			this.normalize();
		}
		
		/**
		 * Sets this Quaternion from Euler angles.
		 * 
		 * @param	ax	X-angle in radians.
		 * @param	ay	Y-angle in radians.
		 * @param	az	Z-angle in radians.
		 */ 
		public function setFromEuler(ax:Number, ay:Number, az:Number, useDegrees:Boolean=false):void
		{
			if( useDegrees )
			{
				ax *= DEGTORAD;
				ay *= DEGTORAD;
				az *= DEGTORAD;
			}
			
			var fSinPitch       :Number = Math.sin( ax * 0.5 );
			var fCosPitch       :Number = Math.cos( ax * 0.5 );
			var fSinYaw         :Number = Math.sin( ay * 0.5 );
			var fCosYaw         :Number = Math.cos( ay * 0.5 );
			var fSinRoll        :Number = Math.sin( az * 0.5 );
			var fCosRoll        :Number = Math.cos( az * 0.5 );
			var fCosPitchCosYaw :Number = fCosPitch * fCosYaw;
			var fSinPitchSinYaw :Number = fSinPitch * fSinYaw;

			this.x = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw;
			this.y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
			this.z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
			this.w = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw;
		}
		
		public function setFromMatrix(matrix:Matrix3D):void
		{
			var quat:Quaternion = this;
			
			var v :Vector.<Number> = matrix.rawData; 
			var s:Number;
			var q:Array = new Array(4);
			var i:int, j:int, k:int;
			
			var tr :Number = v[0] + v[5] + v[10];
			
			// check the diagonal
			if (tr > 0.0) 
			{
				s = Math.sqrt(tr + 1.0);
				quat.w = s / 2.0;
				s = 0.5 / s;
				
				quat.x = (v[9] - v[6]) * s;
				quat.y = (v[2] - v[8]) * s;
				quat.z = (v[4] - v[1]) * s;
			} 
			else 
			{		
				// diagonal is negative
				var nxt:Array = [1, 2, 0];

				var m:Array = [
					[v[0], v[1], v[2], v[3]],
					[v[4], v[5], v[6], v[7]],
					[v[8], v[9], v[10], v[11]] 
				];
				
				i = 0;

				if (m[1][1] > m[0][0]) i = 1;
				if (m[2][2] > m[i][i]) i = 2;

				j = nxt[i];
				k = nxt[j];
				s = Math.sqrt((m[i][i] - (m[j][j] + m[k][k])) + 1.0);

				q[i] = s * 0.5;

				if (s != 0.0) s = 0.5 / s;

				q[3] = (m[k][j] - m[j][k]) * s;
				q[j] = (m[j][i] + m[i][j]) * s;
				q[k] = (m[k][i] + m[i][k]) * s;

				quat.x = q[0];
				quat.y = q[1];
				quat.z = q[2];
				quat.w = q[3];
			}
		}
		
		/**
		 * Modulo.
		 * 
		 * @param	a
		 * @return
		 */
		public function get modulo():Number
		{
			return Math.sqrt(x*x + y*y + z*z + w*w);
		}
		
		/**
		 * Conjugate.
		 * 
		 * @param	a
		 * @return
		 */
		public static function conjugate( a:Quaternion ):Quaternion
		{
			var q:Quaternion = new Quaternion();
			q.x = -a.x;
			q.y = -a.y;
			q.z = -a.z;
			q.w = a.w;
			return q;
		}
		
		/**
		 * Creates a Quaternion from a axis and a angle.
		 * 
		 * @param	x 	X-axis
		 * @param	y 	Y-axis
		 * @param	z 	Z-axis
		 * @param	angle	angle in radians.
		 * 
		 * @return
		 */
		public static function createFromAxisAngle( x:Number, y:Number, z:Number, angle:Number ):Quaternion
		{
			var q:Quaternion = new Quaternion();

			q.setFromAxisAngle(x, y, z, angle);
			
			return q;
		}
		
		/**
		 * Creates a Quaternion from Euler angles.
		 * 
		 * @param	ax	X-angle in radians.
		 * @param	ay	Y-angle in radians.
		 * @param	az	Z-angle in radians.
		 * 
		 * @return
		 */
		public static function createFromEuler( ax:Number, ay:Number, az:Number, useDegrees:Boolean = false ):Quaternion
		{
			if( useDegrees )
			{
				ax *= DEGTORAD;
				ay *= DEGTORAD;
				az *= DEGTORAD;
			}
			
			var fSinPitch       :Number = Math.sin( ax * 0.5 );
			var fCosPitch       :Number = Math.cos( ax * 0.5 );
			var fSinYaw         :Number = Math.sin( ay * 0.5 );
			var fCosYaw         :Number = Math.cos( ay * 0.5 );
			var fSinRoll        :Number = Math.sin( az * 0.5 );
			var fCosRoll        :Number = Math.cos( az * 0.5 );
			var fCosPitchCosYaw :Number = fCosPitch * fCosYaw;
			var fSinPitchSinYaw :Number = fSinPitch * fSinYaw;

			var q:Quaternion = new Quaternion();

			q.x = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw;
			q.y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
			q.z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
			q.w = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw;

			return q;
		}
				
		/**
		 * Creates a Quaternion from a matrix.
		 * 
		 * @param	matrix	a matrix. @see org.papervision3d.core.Matrix3D
		 * 
		 * @return	the created Quaternion
		 */
		public static function createFromMatrix( matrix:Matrix3D ):Quaternion
		{
			var quat:Quaternion = new Quaternion();
			
			quat.setFromMatrix(matrix);
			
			return quat;
		}
		
		/**
		 * Creates a Quaternion from a orthonormal matrix.
		 * 
		 * @param	m	a orthonormal matrix. @see org.papervision3d.core.Matrix3D
		 * 
		 * @return  the created Quaternion
		 */
		public static function createFromOrthoMatrix( m:Matrix3D ):Quaternion
		{
			var q:Quaternion = new Quaternion();
/*
			q.w = Math.sqrt( Math.max(0, 1 + m.n11 + m.n22 + m.n33) ) / 2;
			q.x = Math.sqrt( Math.max(0, 1 + m.n11 - m.n22 - m.n33) ) / 2;
			q.y = Math.sqrt( Math.max(0, 1 - m.n11 + m.n22 - m.n33) ) / 2;
			q.z = Math.sqrt( Math.max(0, 1 - m.n11 - m.n22 + m.n33) ) / 2;
			
			// recover signs
			q.x = m.n32 - m.n23 < 0 ? (q.x < 0 ? q.x : -q.x) : (q.x < 0 ? -q.x : q.x);
			q.y = m.n13 - m.n31 < 0 ? (q.y < 0 ? q.y : -q.y) : (q.y < 0 ? -q.y : q.y);
			q.z = m.n21 - m.n12 < 0 ? (q.z < 0 ? q.z : -q.z) : (q.z < 0 ? -q.z : q.z);
*/
			return q;
		}
		
		/**
		 * Dot product.
		 * 
		 * @param	a
		 * @param	b
		 * 
		 * @return
		 */
		public static function dot( a:Quaternion, b:Quaternion ):Number
		{
			return (a.x * b.x) + (a.y * b.y) + (a.z * b.z) + (a.w * b.w);
		}
		
		/**
		 * Multiply.
		 * 
		 * @param	a
		 * @param	b
		 * @return
		 */
		public static function multiply( a:Quaternion, b:Quaternion ):Quaternion
		{
			var c:Quaternion = new Quaternion();
			c.x = a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y;
			c.y = a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x;
			c.z = a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w;
			c.w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z;
			return c;
		}
		
		/**
		 * Multiply by another Quaternion.
		 * 
		 * @param	b	The Quaternion to multiply by.
		 */
		public function mult( b:Quaternion ):void
		{
			var aw:Number = this.w,
				ax:Number = this.x,
				ay:Number = this.y,
				az:Number = this.z;
				
			x = aw*b.x + ax*b.w + ay*b.z - az*b.y;
			y = aw*b.y - ax*b.z + ay*b.w + az*b.x;
			z = aw*b.z + ax*b.y - ay*b.x + az*b.w;
			w = aw*b.w - ax*b.x - ay*b.y - az*b.z;
		}
		
		public function toString():String{
			return "Quaternion: x:"+this.x+" y:"+this.y+" z:"+this.z+" w:"+this.w;
		}
		
		/**
		 * Normalize.
		 * 
		 * @param	a
		 * 
		 * @return
		 */
		public function normalize():void
		{
			var len:Number = this.modulo;
			
			if( Math.abs(len) < EPSILON )
			{
				x = y = z = 0.0;
				w = 1.0;
			}
			else
			{
				var m:Number = 1 / len;
				x *= m;
				y *= m;
				z *= m;
				w *= m;
			}
		}

		/**
		 * SLERP (Spherical Linear intERPolation). @author Trevor Burton
		 * 
		 * @param	qa		start quaternion
		 * @param	qb		end quaternion
		 * @param	alpha	a value between 0 and 1
		 * 
		 * @return the interpolated quaternion.
		 */	
		public static function slerp( qa:Quaternion, qb:Quaternion, alpha:Number ):Quaternion
		{
			var angle:Number = qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;
 
	         if (angle < 0.0)
	         {
	                 qa.x *= -1.0;
	                 qa.y *= -1.0;
	                 qa.z *= -1.0;
	                 qa.w *= -1.0;
	                 angle *= -1.0;
	         }
	 
	         var scale:Number;
	         var invscale:Number;
	 
	         if ((angle + 1.0) > EPSILON) // Take the shortest path
	         {
	                 if ((1.0 - angle) >= EPSILON)  // spherical interpolation
	                 {
	                         var theta:Number = Math.acos(angle);
	                         var invsintheta:Number = 1.0 / Math.sin(theta);
	                         scale = Math.sin(theta * (1.0-alpha)) * invsintheta;
	                         invscale = Math.sin(theta * alpha) * invsintheta;
	                 }
	                 else // linear interploation
	                 {
	                         scale = 1.0 - alpha;
	                         invscale = alpha;
	                 }
	         }
	         else // long way to go...
	         {
				 qb.y = -qa.y;
				 qb.x = qa.x;
				 qb.w = -qa.w;
				 qb.z = qa.z;

                 scale = Math.sin(Math.PI * (0.5 - alpha));
                 invscale = Math.sin(Math.PI * alpha);
	         }
	 
			return new Quaternion(  scale * qa.x + invscale * qb.x, 
									scale * qa.y + invscale * qb.y,
									scale * qa.z + invscale * qb.z,
									scale * qa.w + invscale * qb.w );
		}
		
		public function toEuler():Vector3D
		{
			var euler	:Vector3D = new Vector3D();
			var q1		:Quaternion = this;
			
			var test :Number = q1.x*q1.y + q1.z*q1.w;
			if (test > 0.499) { // singularity at north pole
				euler.x = 2 * Math.atan2(q1.x,q1.w);
				euler.y = Math.PI/2;
				euler.z = 0;
				return euler;
			}
			if (test < -0.499) { // singularity at south pole
				euler.x = -2 * Math.atan2(q1.x,q1.w);
				euler.y = - Math.PI/2;
				euler.z = 0;
				return euler;
			}
		    
		    var sqx	:Number = q1.x*q1.x;
		    var sqy	:Number = q1.y*q1.y;
		    var sqz	:Number = q1.z*q1.z;
		    
		    euler.x = Math.atan2(2*q1.y*q1.w-2*q1.x*q1.z , 1 - 2*sqy - 2*sqz);
			euler.y = Math.asin(2*test);
			euler.z = Math.atan2(2*q1.x*q1.w-2*q1.y*q1.z , 1 - 2*sqx - 2*sqz);
			
			return euler;
		}
		
		/**
		 * Gets the matrix representation of this Quaternion.
		 * 
		 * @return matrix. @see org.papervision3d.core.Matrix3D
		 */
		public function get matrix():Matrix3D
		{
			var xx:Number = x * x;
			var xy:Number = x * y;
			var xz:Number = x * z;
			var xw:Number = x * w;
			var yy:Number = y * y;
			var yz:Number = y * z;
			var yw:Number = y * w;
			var zz:Number = z * z;
			var zw:Number = z * w;
			
			var v :Vector.<Number> = _matrix.rawData;
			 
			v[0] = 1 - 2 * ( yy + zz );
			v[1] =     2 * ( xy - zw );
			v[2] =     2 * ( xz + yw );
			
			v[4] =     2 * ( xy + zw );
			v[5] = 1 - 2 * ( xx + zz );
			v[6] =     2 * ( yz - xw );
			
			v[8] =     2 * ( xz - yw );
			v[9] =     2 * ( yz + xw );
			v[10] = 1 - 2 * ( xx + yy );
			
			_matrix.rawData = v;
			
			return _matrix;
		}
		
		public static function sub(a:Quaternion, b:Quaternion):Quaternion
		{
			return new Quaternion(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);	
		}
		
		public static function add(a:Quaternion, b:Quaternion):Quaternion
		{
			return new Quaternion(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);	
		}
	}
}