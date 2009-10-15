package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.hires.debug.Stats;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.Material;
	import org.papervision3d.materials.shaders.ColorShader;
	import org.papervision3d.materials.textures.Texture;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;

	[SWF (backgroundColor="#000000")]
	
	public class Main extends Sprite
	{
		use namespace pv3d;
		
		public var container :Sprite;
		public var vertexGeometry :VertexGeometry;
		public var cube :Cube;
		public var camera :Camera3D;
		public var pipeline :BasicPipeline;
		public var viewport :Viewport3D;
		public var scene :DisplayObject3D;
		public var renderData :RenderData;
		public var renderer :BasicRenderEngine;
		public var tf :TextField;
		public var loader:Loader;
		public var camera2 :Camera3D;
		
		public function Main()
		{
			init();
		}
		
		private function init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			
			// Thanks doob!
			addChild(new Stats());

			tf = new TextField();
			addChild(tf);
			tf.x = 1;
			tf.y = 110;
			tf.width = 300;
			tf.height = 200;
			tf.defaultTextFormat = new TextFormat("Arial", 10, 0xff0000);
			tf.selectable = false;
			tf.multiline = true;
			tf.text = "Papervision3D - version 3.0";
			
			viewport = new Viewport3D(0, 0, true);
			addChild(viewport);
			
			scene = new DisplayObject3D("Scene");
			
			camera = new Camera3D(50, 400, 2300, "Camera01");
			
			scene.addChild( camera );
			camera.enableCulling = false
			camera.showFrustum = false;
			camera.z = 800;

			renderer = new BasicRenderEngine();
			renderer.clipFlags = ClipFlags.ALL;			
			
			var bmp:BitmapData = new BitmapData(256, 256);
			bmp.perlinNoise(256, 256, 2, 300, true, false);
			
			cube = new Cube(new BitmapMaterial(bmp), 100, "Cube");
			
			
			//cubeChildx = new Sphere(new BitmapMaterial(new BitmapData(256, 256, true, 0x6600FFFF)), 50);
			cubeChildx = new Sphere(new Material(new Texture(0xff00ff, 0.4), new ColorShader()));
			cubeChildx.x = cubeChildx.y = 100;
			cubeChildx.rotationX = 80;
			cube.addChild(cubeChildx);
				
			
			scene.addChild( cube );
			
			loader = new Loader();
			loader.load(new URLRequest("http://zupko.info/lab/geolocate/earthmap1k.jpg"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			
			addEventListener(Event.ENTER_FRAME, render);
		}
		private var cubeChildx : DisplayObject3D;
		
		
		private function loaderCompleteHandler(e:Event):void{
			var s:Sphere = new Sphere(new BitmapMaterial((loader.content as Bitmap).bitmapData), 50, 80, 80);
			scene.addChild(s);
			s.y = 120;
			//cubeChildx.lookAt(s);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		 
		private function render(event:Event=null):void
		{
		
			_s += 0.02;
			
			camera.x = Math.sin(_r) * 550;
			camera.y = viewport.containerSprite.mouseY*0.25+200;
			camera.z = Math.cos(_r) * 550;
			_r = viewport.containerSprite.mouseX * 0.005;//Math.PI / 180 * 0.25;
			_r = _r > Math.PI * 2 ? 0 : _r;
			
			
			camera.lookAt(cube);
			//camera.lookAt( cube.getChildByName("blue") );
			//trace(cube.getChildByName("red").transform.position);
			
			renderer.renderScene(scene, camera, viewport);	
			
			var stats :RenderStats = renderer.renderData.stats;
			
			tf.text = "Papervision3D - version 3.0\n" +
				"\ntotal objects: " + stats.totalObjects +
				"\nculled objects: " + stats.culledObjects +
				"\n\ntotal triangles: " + stats.totalTriangles +
				"\nculled triangles: " + stats.culledTriangles +
				"\nclipped triangles: " + stats.clippedTriangles;
			
		}
	}
}
