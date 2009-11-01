package org.papervision3d.materials.shaders.light
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.materials.textures.Texture2D;
	
	public class AbstractLightShader extends BasicShader
	{
		protected var _overlayTexture:BitmapData;
		protected var _overlayBitmap : Bitmap;
		protected var _drawContext : Sprite;
		protected var _drawContainer : Sprite;
		protected var _lightMap : BitmapData;
		
		public function AbstractLightShader()
		{
			super();
			_overlayBitmap = new Bitmap();
			_drawContext = new Sprite();
			_drawContainer = new Sprite();
			
			_drawContainer.addChild(_drawContext);
			_drawContext.blendMode = "multiply";
		}

		public override function set texture(value:Texture):void{
			super.texture = value;
			_outputBitmap = _baseBitmap.clone();
			if(_texture is Texture2D){
				var t2d:Texture2D = _texture as Texture2D;
				_overlayTexture = new BitmapData(t2d.bitmap.width, t2d.bitmap.height, false, 0);
				_overlayBitmap.bitmapData = _overlayTexture;
				_drawContainer.addChildAt(new Bitmap(_baseBitmap),0);
			}
			
		}
		
		public function get drawContext():Sprite{
			return _drawContext;
		}
		
		public function get drawContainer():Sprite{
			return _drawContainer;
		}
		
		protected var uvMatrices:Dictionary = new Dictionary(false);
		private var hasTexture : Boolean = false;
		private var bmp : BitmapData;
		public function getUVMatrixForTriangle(triangle:Triangle, perturb:Boolean = false):Matrix
		{
			var mat:Matrix;
			if(!(mat = uvMatrices[triangle])){
				mat = new Matrix();
				
				hasTexture = (triangle.shader.texture is Texture2D);
				
					if(hasTexture){
						bmp = (triangle.shader.texture as Texture2D).bitmap;
						var txWidth:Number = bmp.width;
						var txHeight:Number = bmp.height;
						var x0:Number = triangle.uv0.u * txWidth;
						var y0:Number = (1-triangle.uv0.v) * txHeight;
						var x1:Number = triangle.uv1.u * txWidth;
						var y1:Number = (1-triangle.uv1.v) * txHeight;
						var x2:Number = triangle.uv2.u * txWidth;
						var y2:Number = (1-triangle.uv2.v) * txHeight;
						mat.tx = x0;
						mat.ty = y0;
						mat.a = (x1 - x0);
						mat.b = (y1 - y0);
						mat.c = (x2 - x0);
						mat.d = (y2 - y0);
						uvMatrices[triangle] = mat;	
					}
	
			}
			return mat;
		}

	}
}