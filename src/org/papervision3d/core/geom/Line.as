package org.papervision3d.core.geom
{
	import org.papervision3d.core.render.draw.items.IDrawable;
	import org.papervision3d.materials.shaders.IShader;
	
	public class Line extends Geometry
	{
		/** Start point of line. */
		public var v0 :Vertex;
		
		/** End point of line. */
		public var v1 :Vertex;
		
		/** First control point. */
		public var cv0 :Vertex;
		
		/** */
		public var shader : IShader;
		
		/** */
		public var drawable :IDrawable;
		
		/**
		 * 
		 */ 
		public function Line(shader:IShader, v0:Vertex, v1:Vertex, cv0:Vertex=null)
		{
			this.shader = shader;
			this.v0 = v0;
			this.v1 = v1;
			this.cv0 = cv0;
		}
	}
}