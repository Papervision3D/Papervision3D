package org.papervision3d.core.geom
{
	import org.papervision3d.core.render.draw.items.IDrawable;
	import org.papervision3d.materials.AbstractMaterial;
	
	public class Line
	{
		/** Start point of line. */
		public var v0 :Vertex;
		
		/** End point of line. */
		public var v1 :Vertex;
		
		/** First control point. */
		public var cv0 :Vertex;
		
		/** */
		public var material :AbstractMaterial;
		
		/** */
		public var drawable :IDrawable;
		
		/**
		 * 
		 */ 
		public function Line(material:AbstractMaterial, v0:Vertex, v1:Vertex, cv0:Vertex=null)
		{
			this.material = material;
			this.v0 = v0;
			this.v1 = v1;
			this.cv0 = cv0;
		}
	}
}