package org.papervision3d.core.math.utils {
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.UVCoord;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.materials.shaders.IShader;
	import org.papervision3d.objects.DisplayObject3D;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class GeomUtil {
	
		
		public static const FRONT		: uint = 0;
		public static const BACK		: uint = 1;
		public static const COINCIDING	: uint = 2;
		public static const STRADDLE	: uint = 3;
		
		/**
		 *  Determines whether a Vector3D is in front, behind, parallel or straddling a plane.
		 * 
		 * @param	point
		 * @param	plane
		 * @param	epsilon
		 * @return
		 */
		public static function classifyPoint(point:Vector3D, plane :Plane3D, epsilon:Number = 0.01 ):uint {
			var distance:Number = plane.distance(point);
			if(distance < -epsilon) 
				return BACK;
			else if(distance > epsilon) 
				return FRONT;
			else 
				return COINCIDING;	
		}
		
		/**
		 * Determines whether an Array of points is in front, behind, parallel or straddling a plane.
		 * 
		 * @param	points
		 * @param	plane
		 * @param	epsilon
		 * @return
		 */
		public static function classifyPoints(points:Array, plane:Plane3D, epsilon:Number = 0.01):uint {
			var numpos:uint = 0;
			var numneg:uint = 0;
			
			for each( var point:Vector3D in points )
			{
				var side:uint = classifyPoint(point, plane, epsilon);
				if( side == FRONT )
					numpos++;
				else if( side == BACK )
					numneg++;
			}
			
			if( numpos > 0 && numneg == 0 )
				return FRONT;
			else if( numpos == 0 && numneg > 0 )
				return BACK;
			else if( numpos > 0 && numneg > 0 )
				return STRADDLE;
			else
				return COINCIDING;
		}
		
		/**
		 * 
		 */
		public static function classifyTriangle(triangle:Triangle, plane:Plane3D, epsilon:Number=0.01):uint {
			return classifyPoints([triangle.v0, triangle.v1, triangle.v2], plane, epsilon);
		}
		
		/**
		 * 
		 */
		public static function equalVector(a:Vector3D, b:Vector3D, epsilon:Number=0.01):Boolean 
		{
			return (a.x > b.x-epsilon && a.x < b.x+epsilon && 
					a.y > b.y-epsilon && a.y < b.y+epsilon && 
					a.z > b.z-epsilon && a.z < b.z+epsilon);
		}
		
		/**
		 * 
		 */
		public static function findVertexInGeometry(geometry : VertexGeometry, vertex : Vector3D, epsilon:Number=0.000001) : Vector3D
		{
			var v : Vector3D;
			for each(v in geometry.vertices)
			{
				if(equalVector(vertex, v, epsilon))
					return v;
			}
			return null;
		}
		
		/* public static function flattenScene(scene:SceneGraph):TriangleMesh
		{
			var mesh : TriangleMesh = new TriangleMesh();
			var object : DisplayObject3D;
			updateObjectWorldTransform(scene.world);
			for each(object in scene.world.children) {
				flattenObjectGeom(mesh, object);
			}
			mesh.finalizeBuild();
			return mesh;
		} */
		
		public static function flattenObject(object : DisplayObject3D) : TriangleGeometry
		{
			var mesh : TriangleGeometry = new TriangleGeometry();
			updateObjectWorldTransform(object);
			flattenObjectGeom(mesh, object);
			//object.renderer.geometry = mesh;
			//object.renderer.updateIndices();
			return mesh;
		}
		
		private static function updateObjectWorldTransform(displayObject3D : DisplayObjectContainer3D):void {
			var child : DisplayObject3D;
			use namespace pv3d;
			
			for each(child in displayObject3D._children){
				// local
				
				//NEED TO UPDATE!!
				
				var v:Vector.<Vector3D> = new Vector.<Vector3D>();
				v.push(child.transform.localPosition, child.transform.localEulerAngles, child.transform.localScale);
				
				child.transform.local.recompose(v);
			//	child.localTransform.recompose(child._components);
					
				// world
				child.transform.worldTransform.rawData = child.transform.local.rawData;			
				child.transform.worldTransform.append(displayObject3D.transform.worldTransform);
					
				/*//Probably faster to do this by hand, this spawns new vector3d's.
				if(true){
					child.localBoundingSphere.worldOrigin = child.worldTransform.transformVector(child.localBoundingSphere.origin);
				}*/
					
				updateObjectWorldTransform(child);
			}
		}

		private static function flattenObjectGeom(target:TriangleGeometry, object:DisplayObject3D):void {
			use namespace pv3d;
			var child : DisplayObject3D;
			var geometry :TriangleGeometry = object.renderer.geometry is TriangleGeometry ?  object.renderer.geometry as TriangleGeometry : null;
			
			if(geometry) {
				
				var matrix :Matrix3D = object.transform.worldTransform;
				var dict :Dictionary = new Dictionary(true);
				var v :Vertex;
				var tri :Triangle;
				var tmp :Vector3D;
				
				for each(v in geometry.vertices) {
					tmp = matrix.transformVector(v);
					if(!dict[v]){
						dict[v] = new Vertex(tmp.x, tmp.y, tmp.z);
					}
					target.addVertex(dict[v]);
				}
				
				for each(tri in geometry.triangles) {
					var v0 :Vertex = dict[tri.v0];
					var v1 :Vertex = dict[tri.v1];
					var v2 :Vertex = dict[tri.v2];
					var newTri : Triangle = new Triangle(tri.shader, v0, v1, v2, tri.uv0, tri.uv1, tri.uv2);

					target.addTriangle(newTri);
				}
			}
			
			for each(child in object._children) {
				flattenObjectGeom(target, child);	
			}
		}
		
		/**
		 * Linear interpolation of a UVCoord.
		 * 
		 * @param	a
		 * @param	b
		 * @param	alpha
		 * @return
		 */
		public static function interpolateUV(a:UVCoord, b:UVCoord, alpha:Number):UVCoord {
			var dst:UVCoord = new UVCoord();
			dst.u = a.u + alpha * (b.u - a.u);
			dst.v = a.v + alpha * (b.v - a.v);
			return dst;
		}
		
		/**
		 * Splits a triangle by a plane.
		 * 
		 * @param	triangle
		 * @param	plane
		 * @param	epsilon
		 * 
		 * @return	An Array of triangles.
		 */
		public static function splitTriangleByPlane(triangle:Triangle, geometry:TriangleGeometry, plane:Plane3D, epsilon:Number = 0.01, weldVertices:Boolean=true, weldTreshold:Number=0.0001):Array {
			var points:Array = [triangle.v0, triangle.v1, triangle.v2];
			var uvs:Array = [triangle.uv0, triangle.uv1, triangle.uv2];
			var triA:Array = new Array();
			var triB:Array = new Array();
			var uvsA:Array = new Array();
			var uvsB:Array = new Array();
			var pA :Vector3D = points[0];
			var uvA :UVCoord = uvs[0];
			var sideA :Number = plane.distance(pA);
			
			for( var i:int = 0; i < points.length; i++ ) {
				var j:int = (i+1) % points.length;
				
				var pB :Vector3D = points[j];
				var uvB :UVCoord = uvs[j];
				var sideB :Number = plane.distance(pB);
				var d :Number = sideA / (sideA-sideB);
				var newUV :UVCoord;
				var v : Vertex;
				var existing : Vertex;
				
				if(sideB > epsilon) {
					if(sideA < -epsilon) {
						v = new Vertex(pA.x, pA.y, pA.z);
						v.x += d * (pB.x - pA.x);
						v.y += d * (pB.y - pA.y);
						v.z += d * (pB.z - pA.z);
						
						if(weldVertices) {
							existing = findVertexInGeometry(geometry, v, weldTreshold) as Vertex;
							if(existing) {
								v = existing;
							}
						}
						
						geometry.addVertex(v);
						
						triA.push(v);
						triB.push(v);
						
						newUV = interpolateUV(uvA, uvB, d);
						
						uvsA.push(newUV);
						uvsB.push(newUV);
					}
					triA.push(pB);
					uvsA.push(uvB);
				} else if(sideB < -epsilon) {
					if(sideA > epsilon) {
						v = new Vertex(pA.x, pA.y, pA.z);
						v.x += d * (pB.x - pA.x);
						v.y += d * (pB.y - pA.y);
						v.z += d * (pB.z - pA.z);
						
						if(weldVertices) {
							existing = findVertexInGeometry(geometry, v, weldTreshold) as Vertex;
							if(existing) {
								v = existing;
							}
						}
						
						geometry.addVertex(v);
						
						triA.push(v);
						triB.push(v);
						
						newUV = interpolateUV(uvA, uvB, d);
						
						uvsA.push(newUV);
						uvsB.push(newUV);
					}
					triB.push(pB);
					uvsB.push(uvB);
				} else {
					triA.push(pB);
					triB.push(pB);
					uvsA.push(uvB);
					uvsB.push(uvB);
				}
				
				sideA = sideB;
				pA = pB;
				uvA = uvB;
			}
			
			var tris:Array = new Array();
			
			tris.push(new Array(), new Array());
			
			var material : IShader = triangle.shader;
			
			var nTri : Triangle;
			if(triA.length > 2){
				nTri = new Triangle(material, triA[0], triA[1], triA[2], uvsA[0], uvsA[1], uvsA[2]);
				tris[0].push(nTri);
				geometry.addTriangle(nTri);
			}
			if(triB.length > 2){
				nTri = new Triangle(material, triB[0], triB[1], triB[2], uvsB[0], uvsB[1], uvsB[2]);

				tris[1].push(nTri);
				geometry.addTriangle(nTri);
			}
			if( triA.length > 3 ){
				nTri = new Triangle(material, triA[0], triA[2], triA[3], uvsA[0], uvsA[2], uvsA[3]);

				tris[0].push(nTri);
				geometry.addTriangle(nTri);
			}else if( triB.length > 3 ){
				nTri = new Triangle(material, triB[0], triB[2], triB[3], uvsB[0], uvsB[2], uvsB[3]);

				tris[1].push(nTri);
				geometry.addTriangle(nTri);
			}
			return tris;
		}

	}
}
