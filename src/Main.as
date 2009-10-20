package 
{
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
	import org.papervision3d.materials.WireframeMaterial;
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
			camera.y = 500;

			renderer = new BasicRenderEngine();
			renderer.clipFlags = ClipFlags.ALL;			
			
			var bmp:BitmapData = new BitmapData(256, 256);
			bmp.perlinNoise(256, 256, 2, 300, true, false);
			 
			sun = new Sphere(new WireframeMaterial(0xffff00), 100);
			//sun.y = 600;
			earth = new Cube(new WireframeMaterial(0x0000ff), 50, "earth");
			sun.addChild(earth);
			//sun.transform.localScale = (new Vector3D(1, 2, 1));
			earth.x = 300;
			scene.addChild( sun );
			//earth.rotationX = 45;

			moon = new  Cube(new WireframeMaterial(0xcccccc), 20, "moon");
			earth.addChild(moon);
			moon.x = 100;
			//moon.rotationX = -45;
			
			var light:PointLight = new PointLight();
			light.x = 250;
			
			scene.addChild(light);

			
			var ucs :UCS = new UCS("ucs0", 100);
			earth.addChild(ucs);

			sun.addChild(new UCS("ss", 200));
			
		//	earth.scaleZ = 2;
		//	earth.scaleX = earth.scaleY = 2;
			
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		 
		private function render(event:Event=null):void
		{
			sun.rotationY+=0.05;
			_s += 0.02;
			
		//	earth.rotationY += 2;
		//	earth.rotationY++;
			earth.transform.eulerAngles.y -= 2;
		//	earth.transform.dirty = true;
			
			moon.lookAt(sun);
			//moon.rotationY += 3;
			
		//	camera.x = Math.sin(_r) * 1000;
		//	camera.z = Math.cos(_r) * 1000;
		//	_r += Math.PI/90;
			
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
