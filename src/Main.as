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
	import org.papervision3d.materials.Material;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.shaders.light.FlatShader;
	import org.papervision3d.materials.textures.Texture2D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.lights.PointLight;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.special.UCS;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;

	[SWF (backgroundColor="#000000")]
	
	public class Main extends Sprite
	{
		use namespace pv3d;
		
		public var container :Sprite;
		public var vertexGeometry :VertexGeometry;
		public var camera :Camera3D;
		public var pipeline :BasicPipeline;
		public var viewport :Viewport3D;
		public var scene :DisplayObject3D;
		public var renderData :RenderData;
		public var renderer :BasicRenderEngine;
		public var tf :TextField;
		public var loader:Loader;
		public var camera2 :Camera3D;
		
		public var sun :Sphere;
		public var earth :Cube;
		public var moon :Cube;
		
		[Embed(source="testAssets/earthmap1k.jpg")]
		public var earthMap:Class;
		
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
			
			sun = new Sphere(new Material(new Texture2D((new earthMap() as Bitmap).bitmapData), new FlatShader()), 100, 4, 5);
			sun.rotationX = -45;
			//addChild(new earthMap()).alpha = 0.25;
			//addChild((sun.material.shader as FlatShader).getOutputBitmap()).alpha = 0.25;
			//sun.y = 600;
			earth = new Cube(new WireframeMaterial(0x0000ff), 50);
			//sun.addChild(earth);
			//sun.transform.localScale = (new Vector3D(1, 2, 1));
			earth.x = 300;
			scene.addChild( sun );
			earth.rotationX = 45;

			moon = new  Cube(new WireframeMaterial(0xcccccc), 20);
			earth.addChild(moon);
			moon.x = 100;
			moon.rotationX = -45;
			
			var light:PointLight = new PointLight(0xFFFFFF, 0x333333);
			light.x = 250;
			
			scene.addChild(light);
			
			
			camera.y = 0;
			
			var ucs :UCS = new UCS("ucs0", 100);
			earth.addChild(ucs);

			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		 
		private function render(event:Event=null):void
		{
			sun.rotationY++;
			_s += 0.02;
			
			earth.transform.localEulerAngles.y+=8;
			earth.transform.dirty = true;
			
			moon.rotationY += 3;
			camera.lookAt(sun);

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
