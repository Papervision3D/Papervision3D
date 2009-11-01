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
	import org.papervision3d.core.geom.BSP.BSPTree;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.draw.list.DrawableList;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.Material;
	import org.papervision3d.materials.shaders.BasicShader;
	import org.papervision3d.materials.shaders.NormalShader;
	import org.papervision3d.materials.textures.AnimatedTexture;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.lights.PointLight;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
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
		
		public var sun :DisplayObject3D;
		public var earth :DisplayObject3D;
		public var moon :Cube;
		public var cube :Cube;
		public var BSP:BSPTree;
		
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
			
			viewport = new Viewport3D(800, 600, true);
			addChild(viewport);
			
			scene = new DisplayObject3D("Scene");
			
			camera = new Camera3D(50, 400, 2300, "Camera01");
			
			scene.addChild( camera );
			camera.enableCulling = false
			camera.showFrustum = false;
			camera.near = 1;
			camera.z = 800;
			camera.y = 500;

			renderer = new BasicRenderEngine();
			//renderer.clipFlags = ClipFlags.NEAR;			
			
			var bmp:BitmapData = new BitmapData(256, 256);
			bmp.perlinNoise(256, 256, 2, 300, true, false);


			var bmp2:BitmapData = new BitmapData(256, 256);
			bmp2.perlinNoise(256, 256, 2, 95800, true, true);

			
			
			var l:PointLight = new PointLight();
			scene.addChild(l);
			l.y = 300;
			earth = new DisplayObject3D();//new Cube(new BitmapMaterial(bmp), 50);
			
			earth.addChild(new Plane(new BitmapMaterial(bmp, true), 300, 300));
			earth.addChild(new Cube(new BitmapMaterial(bmp2), 50)).x = 70;
			earth.addChild(new Cube(new BitmapMaterial(bmp2), 50)).z = -70;
			earth.addChild(new Cube(new BitmapMaterial(bmp), 50)).z = 70;
			//earth.addChild(new Sphere(new BitmapMaterial((new earthMap() as Bitmap).bitmapData), 60)).x = 150; 
			var d:DisplayObject3D = new Cube(new Material(new AnimatedTexture(new TestSprite()), new BasicShader()), 60);
			d.x = -100;
			d.y = 10; 
			d.z = 40;
			d.rotationY = 60;
			d.rotationZ = 45; 

			var addon:Plane = new Plane(new BitmapMaterial(bmp, true), 300, 300);
			addon.x = 20;
			addon.y = 10;
	
			
			BSP = new BSPTree(earth);
			BSP.renderer.drawableList.sortIndex = 2;
			scene.addChild(BSP);
			
		//	BSP.addStaticChild(d);
			
			
			var blue : Sphere = new Sphere(new Material(new AnimatedTexture(new TestSprite()), new NormalShader()), 30, 3, 4);
			sun = blue;
			//scene.addChild(blue);
			blue.y = 130;
			blue.renderer.drawableList = new DrawableList(null, null, 1);
			blue.x = 100;
			
			
			moon = new Cube(new BitmapMaterial((new earthMap() as Bitmap).bitmapData, true), 50);
			moon.y = 10;
			moon.rotationX  = 10;
		
			BSP.addChild(moon);
			OBJRENDERER = BSP.renderer;
			//scene.addChild(moon);
			
			/* var p:Plane = new Plane(new WireframeMaterial());
			scene.addChild(p);
			p.y = -100;
			var t:Triangle = (p.renderer.geometry as TriangleGeometry).triangles[0];
			t.createNormal();
			 */
			//renderer.drawManager.drawList.sorter.sortMode = DefaultDrawSorter.INDEXSORT;
			
			camera.y = 100;
			
			var ucs :UCS = new UCS("ucs0", 100);
			//blue.addChild(ucs);
			

			addEventListener(Event.ENTER_FRAME, render);
			//stage.addEventListener(MouseEvent.CLICK, stageClick);
		}
		public static var OBJRENDERER:ObjectRenderer;
		private var _r :Number = 0;
		private var _s :Number = 0;
		
		private var hasMoon :Boolean = true;
		private function stageClick(e:Event):void{
			if(hasMoon){
				BSP.removeChild(moon);
				scene.addChild(moon);
			}
			else{
				scene.removeChild(moon);
				BSP.addChild(moon);
			}
				hasMoon = !hasMoon;
		} 
		
		private function render(event:Event=null):void
		{
			//moon.y += 0.5;
			//moon.rotationY++;
			moon.rotationY++;
			moon.rotationZ++;
			moon.y = Math.sin(_s) * 50;
		
			_s += 0.03;

			camera.y = viewport.containerSprite.mouseY/(viewport.viewportHeight*0.5)*290;
			camera.x = viewport.containerSprite.mouseX/(viewport.viewportWidth*0.5)*290;
			camera.z = (camera.x + camera.z)/2+100;
			
			camera.lookAt(BSP);

			renderer.renderScene(scene, camera, viewport);	
			
			var stats :RenderStats = renderer.renderData.stats;
			
			tf.text = "Papervision3D - version 3.0\n" +
				"\ntotal objects: " + stats.totalObjects +
				"\nculled objects: " + stats.culledObjects +
				"\n\ntotal triangles: " + stats.totalTriangles +
				"\nculled triangles: " + stats.culledTriangles +
				"\nclipped triangles: " + stats.clippedTriangles +
				"\n\nlocal: " + earth.transform.localEulerAngles +
				"\nglobal: " + earth.transform.eulerAngles;
		}
	
	}
}
