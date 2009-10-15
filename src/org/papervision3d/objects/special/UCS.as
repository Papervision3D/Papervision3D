package org.papervision3d.objects.special
{
	import org.papervision3d.core.geom.Line;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.LineGeometry;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class UCS extends DisplayObject3D
	{
		public var size :Number;
		
		public function UCS(name:String, size:Number=100)
		{
			super(name);
			this.size = size;
			this.material = new WireframeMaterial(0xff0000);
			this.renderer.geometry = new LineGeometry();
			init();
		}

		/**
		 * 
		 */
		protected function init():void
		{
			var lineGeometry :LineGeometry = this.renderer.geometry as LineGeometry;
			var matR :WireframeMaterial = new WireframeMaterial(0xff0000);
			var matG :WireframeMaterial = new WireframeMaterial(0x00ff00);
			var matB :WireframeMaterial = new WireframeMaterial(0x0000ff);
			
			var origin :Vertex = lineGeometry.addVertex( new Vertex() );
			var x :Vertex = lineGeometry.addVertex( new Vertex(size, 0, 0) );
			var y :Vertex = lineGeometry.addVertex( new Vertex(0, size, 0) );
			var z :Vertex = lineGeometry.addVertex( new Vertex(0, 0, size) );
			
			lineGeometry.addLine( new Line(matR.shader, origin, x), false );
			lineGeometry.addLine( new Line(matG.shader, origin, y), false );
			lineGeometry.addLine( new Line(matB.shader, origin, z), false );
		}
	}
}