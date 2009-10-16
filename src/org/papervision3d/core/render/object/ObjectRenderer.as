package org.papervision3d.core.render.object
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.provider.VertexGeometry;
	
	public class ObjectRenderer
	{
		public var geometry : VertexGeometry;
		public var viewVertexData :Vector.<Number>;
		public var screenVertexData :Vector.<Number>;
		public var uvtData : Vector.<Number>;
			
		public function ObjectRenderer()
		{
			viewVertexData = new Vector.<Number>();
			screenVertexData = new Vector.<Number>();
			uvtData = new Vector.<Number>();
		}
		
		public function updateIndices():void{
			
			viewVertexData.length = geometry.viewVertexLength;
			screenVertexData.length = geometry.screenVertexLength;
			uvtData.length = geometry.viewVertexLength;
			
		}

	}
}