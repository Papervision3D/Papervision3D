package org.papervision3d.core.math.utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class MatrixUtil
	{
		private static var _f :Vector3D = new Vector3D();
		private static var _s :Vector3D = new Vector3D();
		private static var _u :Vector3D = new Vector3D();
		
		/**
		 * @author Tim Knip / floorplanner.com
		 */ 
		public static function createLookAtMatrix(eye:Vector3D, target:Vector3D, up:Vector3D, resultMatrix:Matrix3D=null):Matrix3D
		{
			resultMatrix = resultMatrix || new Matrix3D();
			
			_f.x = target.x - eye.x;
			_f.y = target.y - eye.y;
			_f.z = target.z - eye.z;
			_f.normalize();
			
			// f x up
			_s.x = (up.y * _f.z) - (up.z * _f.y);
			_s.y = (up.z * _f.x) - (up.x * _f.z);
			_s.z = (up.x * _f.y) - (up.y * _f.x);
			_s.normalize();
			
			// f x s
			_u.x = (_s.y * _f.z) - (_s.z * _f.y);
			_u.y = (_s.z * _f.x) - (_s.x * _f.z);
			_u.z = (_s.x * _f.y) - (_s.y * _f.x);
			_u.normalize();
			
			resultMatrix.rawData = Vector.<Number>([
				_s.x, _s.y, _s.z, 0,
				_u.x, _u.y, _u.z, 0,
				-_f.x, -_f.y, -_f.z, 0,
				0, 0, 0, 1
			]);
			
			return resultMatrix;
		}
		
		/**
		 * Creates a projection matrix.
		 * 
		 * @param fovY
		 * @param aspectRatio
		 * @param near
		 * @param far
		 */
		public static function createProjectionMatrix(fovy:Number, aspect:Number, zNear:Number, zFar:Number):Matrix3D 
		{
			var sine :Number, cotangent :Number, deltaZ :Number;
    		var radians :Number = (fovy / 2) * (Math.PI / 180);
			
		    deltaZ = zFar - zNear;
		    sine = Math.sin(radians);
		    if ((deltaZ == 0) || (sine == 0) || (aspect == 0)) 
		    {
				return null;
		    }
		    cotangent = Math.cos(radians) / sine;
		    
			var v:Vector.<Number> = Vector.<Number>([
				cotangent / aspect, 0, 0, 0,
				0, cotangent, 0, 0,
				0, 0, -(zFar + zNear) / deltaZ, -1,
				0, 0, -(2 * zFar * zNear) / deltaZ, 0
			]);
			return new Matrix3D(v);
		}
		
		/**
		 * 
		 */ 
		public static function createOrthoMatrix(left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number) : Matrix3D {
			var tx :Number = (right + left) / (right - left);
			var ty :Number = (top + bottom) / (top - bottom);
			var tz :Number = (zFar+zNear) / (zFar-zNear);
			var v:Vector.<Number> = Vector.<Number>([
				2 / (right - left), 0, 0, 0,
				0, 2 / (top - bottom), 0, 0,
				0, 0, -2 / (zFar-zNear), 0,
				tx, ty, tz, 1
			]);
			return new Matrix3D(v);
		}

		public static function __gluMakeIdentityd(m : Vector.<Number>) :void {
			m[0+4*0] = 1; m[0+4*1] = 0; m[0+4*2] = 0; m[0+4*3] = 0;
		    m[1+4*0] = 0; m[1+4*1] = 1; m[1+4*2] = 0; m[1+4*3] = 0;
		    m[2+4*0] = 0; m[2+4*1] = 0; m[2+4*2] = 1; m[2+4*3] = 0;
		    m[3+4*0] = 0; m[3+4*1] = 0; m[3+4*2] = 0; m[3+4*3] = 1;
		}
		
		public static function __gluMultMatricesd(a:Vector.<Number>, b:Vector.<Number>, r:Vector.<Number>):void {
			var i :int, j :int;
		    for (i = 0; i < 4; i++) {
				for (j = 0; j < 4; j++) {
				    r[int(i*4+j)] = 
					a[int(i*4+0)]*b[int(0*4+j)] +
					a[int(i*4+1)]*b[int(1*4+j)] +
					a[int(i*4+2)]*b[int(2*4+j)] +
					a[int(i*4+3)]*b[int(3*4+j)];
				}
		    }
		}
		
		public static function __gluMultMatrixVecd(matrix : Vector.<Number>, a : Vector.<Number> , out : Vector.<Number>) : void {
    		var i :int;
		    for (i=0; i<4; i++) {
				out[i] = 
				    a[0] * matrix[int(0*4+i)] +
				    a[1] * matrix[int(1*4+i)] +
				    a[2] * matrix[int(2*4+i)] +
				    a[3] * matrix[int(3*4+i)];
		    }
		}
		
		public static function __gluInvertMatrixd(src : Vector.<Number>, inverse : Vector.<Number>):Boolean {
			var i :int, j :int, k :int, swap :int;
		    var t :Number;
		   	var temp :Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(4);

		    for (i=0; i<4; i++) {
		    	temp[i] = new Vector.<Number>(4, true);
				for (j=0; j<4; j++) {
				    temp[i][j] = src[i*4+j];
				}
		    }
		    __gluMakeIdentityd(inverse);
		
		    for (i = 0; i < 4; i++) {
				/*
				** Look for largest element in column
				*/
				swap = i;
				for (j = i + 1; j < 4; j++) {
				    if (Math.abs(temp[j][i]) > Math.abs(temp[i][i])) {
						swap = j;
				    }
				}
			
				if (swap != i) {
				    /*
				    ** Swap rows.
				    */
				    for (k = 0; k < 4; k++) {
						t = temp[i][k];
						temp[i][k] = temp[swap][k];
						temp[swap][k] = t;
				
						t = inverse[i*4+k];
						inverse[i*4+k] = inverse[swap*4+k];
						inverse[swap*4+k] = t;
				    }
				}
			
				if (temp[i][i] == 0) {
				    /*
				    ** No non-zero pivot.  The matrix is singular, which shouldn't
				    ** happen.  This means the user gave us a bad matrix.
				    */
				    return false;
				}
			
				t = temp[i][i];
				for (k = 0; k < 4; k++) {
				    temp[i][k] /= t;
				    inverse[i*4+k] /= t;
				}
				for (j = 0; j < 4; j++) {
				    if (j != i) {
						t = temp[j][i];
						for (k = 0; k < 4; k++) {
						    temp[j][k] -= temp[i][k]*t;
						    inverse[j*4+k] -= inverse[i*4+k]*t;
						}
				    }
				}
		    }
		    return true;			
		}
	}
}