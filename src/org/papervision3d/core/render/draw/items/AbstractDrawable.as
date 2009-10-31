package org.papervision3d.core.render.draw.items
{
	import flash.display.IGraphicsPath;
	
	import org.papervision3d.materials.shaders.IShader;
	
	public class AbstractDrawable implements IDrawable
	{
		public var shader : IShader;
		public var screenZ :Number;
		public var sortIndex : Number = 0;
		
		public function AbstractDrawable()
		{
			this.shader = null;
		}
		
		public function toViewportSpace(hw:Number, hh:Number):void{
		
		}
		
		public function get path():IGraphicsPath
		{
			return null;
		}

	}
}