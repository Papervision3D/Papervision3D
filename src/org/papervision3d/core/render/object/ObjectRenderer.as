package org.papervision3d.core.render.object
{
	import __AS3__.vec.Vector;
	
	import org.papervision3d.core.geom.Geometry;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class ObjectRenderer
	{
		public var geometry : VertexGeometry;
		public var viewVertexData :Vector.<Number>;
		public var screenVertexData :Vector.<Number>;
		public var uvtData : Vector.<Number>;
		protected var object : DisplayObject3D;
		public var renderList : Vector.<Geometry>;
		
			
		public function ObjectRenderer(obj:DisplayObject3D)
		{
			this.object = obj;
			renderList = new Vector.<Geometry>();	
			viewVertexData = new Vector.<Number>();
			screenVertexData = new Vector.<Number>();
			uvtData = new Vector.<Number>();
		}
		
		public function updateIndices():void{
			//trace(geometry, "in updateIndices");
			viewVertexData.length = geometry.viewVertexLength;
			screenVertexData.length = geometry.screenVertexLength;
			uvtData.length = geometry.viewVertexLength;
			
		}


	}
}