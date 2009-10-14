package org.papervision3d.core.render.draw.items
{
	import org.papervision3d.materials.AbstractMaterial;
	
	public class AbstractDrawable implements IDrawable
	{
		public var material :AbstractMaterial;
		public var screenZ :Number;
		
		public function AbstractDrawable()
		{
			this.material = null;
		}

	}
}