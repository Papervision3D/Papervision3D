package org.papervision3d.materials.shaders
{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IGraphicsData;
	
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.AbstractDrawable;
	import org.papervision3d.materials.AbstractMaterial;
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.objects.DisplayObject3D;

	public class AbstractShader implements IShader
	{
		protected var _texture : Texture;
		protected var _baseBitmap : BitmapData;
		protected var _outputBitmap : BitmapData;
		protected var _material : AbstractMaterial;
		protected var _drawProperties:IGraphicsData;
		protected var _clear : IGraphicsData;
		protected var _usesUV : Boolean = true;
		protected var _dirty : Boolean = false;
		protected var _drawVector : Vector.<IGraphicsData> = new Vector.<IGraphicsData>(3, true);
		
		protected var _doubleSided : Boolean = false;	
		
		public function AbstractShader()
		{
		}
		
		public function render(drawable:AbstractDrawable):Vector.<IGraphicsData>{
			_drawVector[0] = drawProperties;
			_drawVector[1] = drawable.path;
			_drawVector[2] = _clear;
			return _drawVector;
			
		}

		public function process(renderData:RenderData, object:DisplayObject3D):void
		{
		}
		
		public function set clear(value:IGraphicsData):void{
			_clear = value;
		}
		
		public function get clear():IGraphicsData{
			return _clear;
		}
		
		public function set doubleSided(value:Boolean):void{
			_doubleSided = value;
		}
		
		public function get doubleSided():Boolean{
			return _doubleSided;
		}
		
		
		public function set drawProperties(value:IGraphicsData):void{
			_drawProperties = value;
			_drawVector[0] = _drawProperties;
			
		}
		
		public function get drawProperties():IGraphicsData{
			return _drawProperties;
		}
		
		public function set texture(value:Texture):void{
			_texture = value;
		}
		
		public function get texture():Texture{
			return _texture;
		}
		
		public function set bitmap(bitmapData:BitmapData):void
		{
			_baseBitmap = bitmapData.clone();
			_outputBitmap = bitmapData.clone();
		}
		
		public function get usesUV():Boolean{
			return _usesUV;
		}
		
		public function set material(value:AbstractMaterial) : void{
			
			_material = value;
			
			
		}
		
		public function get bitmap():BitmapData
		{
			return _outputBitmap;
		}
		
	}
}