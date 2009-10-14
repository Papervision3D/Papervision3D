package org.papervision3d.objects.primitives
{
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.UVCoord;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	public class Plane extends DisplayObject3D
	{
		public function Plane(material:AbstractMaterial, width:Number=100, height:Number=100, segX:Number=1, segY:Number=1, name:String=null)
		{
			super(name);
			
			
			this.material = material;
			this.renderer.geometry = new TriangleGeometry();
			
			create(width, height, segX, segY);
		}
		
		protected function create(width:Number, height:Number, segX:Number=1, segY:Number=1):void
		{
			var sizeX : Number = width / 2;
			var sizeZ : Number = height / 2;
			var stepX :Number = width / segX;
			var stepZ :Number = height / segY;
			var curX :Number = -sizeX;
			var curZ :Number = sizeZ;
			var curU :Number = 0;
			var curV :Number = 0;
			
			var i :int, j :int;
			
			for (i = 0; i < segX; i++)
			{
				curX = -sizeX + (i * stepX);
				for (j = 0; j < segY; j++)
				{
					curZ = sizeZ - (j * stepZ);
					
					var v0 :Vertex = new Vertex(curX, 0, curZ);
					var v1 :Vertex = new Vertex(curX + stepX, 0, curZ);
					var v2 :Vertex = new Vertex(curX + stepX, 0, curZ - stepZ);
					var v3 :Vertex = new Vertex(curX, 0, curZ - stepZ);
					
					var uv0 :UVCoord = new UVCoord(0, 1);
					var uv1 :UVCoord = new UVCoord(0, 0);
					var uv2 :UVCoord = new UVCoord(1, 0);
					var uv3 :UVCoord = new UVCoord(1, 1);
					
					TriangleGeometry(renderer.geometry).addTriangle( new Triangle(material, v0, v1, v2, uv0, uv1, uv2) );
					TriangleGeometry(renderer.geometry).addTriangle( new Triangle(material, v0, v2, v3, uv0, uv2, uv3) );
				}
			}
			
			TriangleGeometry(renderer.geometry).mergeVertices();
			renderer.updateIndices();
		} 
	}
}