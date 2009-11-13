package org.papervision3d.core.geom
{
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	public class TriangleMesh extends DisplayObject3D
	{
		public var triangleGeometry :TriangleGeometry;
		
		public function TriangleMesh(material:AbstractMaterial=null, name:String=null)
		{
			super(name);
			
			this.material = material;
			this.renderer.geometry = this.triangleGeometry = new TriangleGeometry();
		}	
	}
}