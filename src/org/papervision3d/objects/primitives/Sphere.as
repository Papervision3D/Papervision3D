package org.papervision3d.objects.primitives
{
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.UVCoord;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	public class Sphere extends DisplayObject3D
	{
		private var triGeometry:TriangleGeometry;
		private var segmentsH : int = 6;
		private var segmentsW : int = 8;
		
		
		public function Sphere(material:AbstractMaterial, radius:Number=100, segementsW:int=6, segmentsH:int=8)
		{
			super(name);
			this.segmentsH = segmentsH;
			this.segmentsW = segmentsW;
			this.material = material;
			renderer.geometry = triGeometry = new TriangleGeometry();
			buildSphere(radius);
		}
		
		private var grid:Array;
		private function buildSphere( fRadius:Number ):void
		{
			
		
			var i:Number, j:Number, k:Number;
			var iHor:Number = this.segmentsW;
			var iVer:Number = this.segmentsH;
			var aVtc:Array = new Array();
			for (j=0;j<(iVer+1);j++) { // vertical
				var fRad1:Number = Number(j/iVer);
				var fZ:Number = fRadius*Math.cos(fRad1*Math.PI);
				var fRds:Number = -fRadius*Math.sin(fRad1*Math.PI);
				var aRow:Array = new Array();
				var oVtx:Vertex;
				
				for (i=0;i<iHor;i++) { 
					var fRad2:Number = Number(2*i/iHor);
					var fX:Number = fRds*Math.sin(fRad2*Math.PI);
					var fY:Number = fRds*Math.cos(fRad2*Math.PI);
					
						oVtx = new Vertex(fY,fZ,fX);
						renderer.geometry.addVertex(oVtx);
					
					aRow.push(oVtx);
				}
				aVtc.push(aRow);
			}
			var iVerNum:int = aVtc.length;
			var totalTris:int = 0;
			for (j=0;j<iVerNum;j++) {
				var iHorNum:int = aVtc[j].length;
				if (j>0) { // &&i>=0
					for (i=0;i<iHorNum;i++) {
						// select vertices
						var bEnd:Boolean = i==(iHorNum-1);
						var aP1:Vertex = aVtc[j][bEnd?0:i+1];
						var aP2:Vertex = aVtc[j][(bEnd?iHorNum-1:i)];
						var aP3:Vertex = aVtc[j-1][(bEnd?iHorNum-1:i)];
						var aP4:Vertex = aVtc[j-1][bEnd?0:i+1];
	
						var fJ0:Number = j		/ (iVerNum-1);
						var fJ1:Number = (j-1)	/ (iVerNum-1);
						var fI0:Number = 1-((i+1)	/ iHorNum);
						var fI1:Number = 1-(i		/ iHorNum);
						var aP4uv:UVCoord = new UVCoord(fI0,fJ1);
						var aP1uv:UVCoord = new UVCoord(fI0,fJ0);
						var aP2uv:UVCoord = new UVCoord(fI1,fJ0);
						var aP3uv:UVCoord = new UVCoord(fI1,fJ1);
						
						if (j<(aVtc.length)){	triGeometry.addTriangle(new Triangle(material.shader, aP1, aP2, aP3, aP1uv, aP2uv, aP3uv)); totalTris++;}
						
						if (j>0)				{ triGeometry.addTriangle(new Triangle(material.shader, aP1, aP3, aP4, aP1uv, aP3uv, aP4uv)); totalTris++;}
	
					}
				}
			}
			
			
			renderer.updateIndices();
			trace("HAS ", triGeometry.triangles.length, totalTris, " triangles");
		}
		
	}
}