package org.papervision3d.core.geom
{
	import flash.geom.Vector3D;
	
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.draw.items.IDrawable;
	import org.papervision3d.materials.AbstractMaterial;
	
	public class Triangle
	{
		use namespace pv3d;
		
		/** */
		public var v0 :Vertex;
		
		/** */
		public var v1 :Vertex;
		
		/** */
		public var v2 :Vertex;
		
		/** */
		public var normal :Vector3D;
		
		/** */
		public var uv0 :UVCoord;
		
		/** */
		public var uv1 :UVCoord;
		
		/** */
		public var uv2 :UVCoord;
		
		/** */
		public var visible :Boolean;
		
		/** */
		public var material : AbstractMaterial;
		
		/** */
		pv3d var clipFlags :int;
		
		/** */
		pv3d var drawable :IDrawable;
		
		/**
		 * Constructor
		 * 
		 * @param
		 * @param
		 * @param
		 */ 
		public function Triangle(material:AbstractMaterial, v0:Vertex, v1:Vertex, v2:Vertex, uv0:UVCoord=null, uv1:UVCoord=null, uv2:UVCoord=null)
		{
			this.material = material;
			this.v0 = v0;
			this.v1 = v1;
			this.v2 = v2;
			this.uv0 = uv0 || new UVCoord();
			this.uv1 = uv1 || new UVCoord();
			this.uv2 = uv2 || new UVCoord();
			this.visible = true;
		}
	}
}