package org.papervision3d.materials.shaders
{
	import flash.display.BitmapData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.textures.Texture;
	
	public interface IShader
	{
		function process(renderData:RenderData):void;
		function set texture(value:Texture):void
		function set bitmap(bitmapData:BitmapData):void;
		function get bitmap():BitmapData;
		function set material(value:AbstractMaterial) : void;
	}
}