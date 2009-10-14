package org.papervision3d.objects.primitives
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Line;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.math.utils.MathUtil;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 */ 
	public class Frustum extends DisplayObject3D
	{
		public var nc  :Vertex;
		public var fc  :Vertex;
		public var ntl :Vertex;
		public var nbl :Vertex;
		public var nbr :Vertex;
		public var ntr :Vertex;
		public var ftl :Vertex;
		public var fbl :Vertex;
		public var fbr :Vertex;
		public var ftr :Vertex;
		
		/**
		 * 
		 */ 
		public function Frustum(material:AbstractMaterial, name:String=null)
		{
			super(name);
			
			this.material = material;	
			this.renderer.geometry = new LineGeometry();
			
			init();
		}
		
		/**
		 * 
		 */
		protected function init():void
		{
			var geometry :VertexGeometry = renderer.geometry;
			 
			var lineGeometry :LineGeometry = LineGeometry(renderer.geometry);
			
			nc = geometry.addVertex(new Vertex());
			fc = geometry.addVertex(new Vertex());
			
			ntl = geometry.addVertex(new Vertex());
			nbl = geometry.addVertex(new Vertex());
			nbr = geometry.addVertex(new Vertex());
			ntr = geometry.addVertex(new Vertex());
			
			ftl = geometry.addVertex(new Vertex());
			fbl = geometry.addVertex(new Vertex());
			fbr = geometry.addVertex(new Vertex());
			ftr = geometry.addVertex(new Vertex());
			
			lineGeometry.addLine( new Line(material, ntl, nbl), false );
			lineGeometry.addLine( new Line(material, nbl, nbr), false );
			lineGeometry.addLine( new Line(material, nbr, ntr), false );
			lineGeometry.addLine( new Line(material, ntr, ntl), false );
			
			lineGeometry.addLine( new Line(material, ftl, fbl), false );
			lineGeometry.addLine( new Line(material, fbl, fbr), false );
			lineGeometry.addLine( new Line(material, fbr, ftr), false );
			lineGeometry.addLine( new Line(material, ftr, ftl), false );
			
			lineGeometry.addLine( new Line(material, ntl, ftl), false );
			lineGeometry.addLine( new Line(material, nbl, fbl), false );
			lineGeometry.addLine( new Line(material, nbr, fbr), false );
			lineGeometry.addLine( new Line(material, ntr, ftr), false );
		} 
		
		/**
		 * 
		 */ 
		public function update(camera:Camera3D):void
		{
			var geometry :VertexGeometry = renderer.geometry;
			var fov :Number = camera.fov;
			var near :Number = camera.near;
			var far :Number = camera.far;
			var ratio :Number = 1.33; //camera.aspectRatio;
			
			// compute width and height of the near and far section
			var angle : Number = MathUtil.TO_RADIANS * fov * 0.5;
			var tang :Number = Math.tan(angle);
			var nh :Number = near * tang;
			var nw :Number = nh * ratio;
			var fh :Number = far * tang;
			var fw :Number = fh * ratio;
			
			nc.x = 0;
			nc.y = 0;
			nc.z = -near;
			
			fc.x = 0;
			fc.y = 0;
			fc.z = -far;
			
			ntl.x = -nw * 0.5;
			ntl.y = nh * 0.5;
			ntl.z = -near;
			
			nbl.x = -nw * 0.5;
			nbl.y = -nh * 0.5;
			nbl.z = -near;
			
			nbr.x = nw * 0.5;
			nbr.y = -nh * 0.5;
			nbr.z = -near;
			
			ntr.x = nw * 0.5;
			ntr.y = nh * 0.5;
			ntr.z = -near;
			
			ftl.x = -fw * 0.5;
			ftl.y = fh * 0.5;
			ftl.z = -far;
			
			fbl.x = -fw * 0.5;
			fbl.y = -fh * 0.5;
			fbl.z = -far;
			
			fbr.x = fw * 0.5;
			fbr.y = -fh * 0.5;
			fbr.z = -far;
			
			ftr.x = fw * 0.5;
			ftr.y = fh * 0.5;
			ftr.z = -far;
			
			geometry.updateIndices();
		}
	}
}