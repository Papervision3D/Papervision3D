package org.papervision3d.core.render.draw.items
{
	import org.papervision3d.materials.shaders.IShader;
	
	public class AbstractDrawable implements IDrawable
	{
		public var shader : IShader;
		public var screenZ :Number;
		
		public function AbstractDrawable()
		{
			this.shader = null;
		}

	}
}