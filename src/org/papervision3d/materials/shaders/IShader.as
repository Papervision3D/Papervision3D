package org.papervision3d.materials.shaders
{
	import flash.display.BitmapData;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.objects.DisplayObject3D;
	
	public interface IShader
	{
		function process(renderData:RenderData, object:DisplayObject3D):void;
		function set texture(value:Texture):void
		function set bitmap(bitmapData:BitmapData):void;
		function get bitmap():BitmapData;
		function set material(value:AbstractMaterial) : void;
		function set drawProperties(value:IGraphicsData):void
		function get drawProperties():IGraphicsData;
		function set clear(value:IGraphicsData):void
		function get clear():IGraphicsData;
		function get usesUV():Boolean;
	}
}