package 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import net.hires.debug.Stats;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.BSP.BSPTree;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.memory.Timing;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.lights.PointLight;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
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
		public var moon :DisplayObject3D;
		public var cube :Cube;
		public var tallCube:Cube;
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
			camera.enableCulling = true;
			camera.showFrustum = false;
			camera.near = 1;
			camera.z = 800;
			camera.y = 500;

			renderer = new BasicRenderEngine();
			renderer.clipFlags = ClipFlags.NONE;			
			
			var bmp:BitmapData = new BitmapData(256, 256);
			bmp.perlinNoise(256, 256, 2, 300, true, false);


			var bmp2:BitmapData = new BitmapData(256, 256);
			bmp2.perlinNoise(256, 256, 2, 95800, true, true);

			
			
			var l:PointLight = new PointLight();
			scene.addChild(l);
			l.y = 300;
			earth = new DisplayObject3D();//new Cube(new BitmapMaterial(bmp), 50);
			
			//earth.addChild(new Plane(new BitmapMaterial(bmp, true), 300, 300));
	
			
			earth.addChild(new Plane(new ColorMaterial(0x64219A, 1, true), 660, 660));
			for(var i:int = 0;i<109;i++){
				var d:Cube = new Cube(new ColorMaterial(0xFFFFFF*Math.random()), 40);
				d.x = Math.random()*600-300;
				d.y = Math.random()*200+10;
				d.z = Math.random()*600-300;
				d.scaleY = d.y/20;
				earth.addChild(d);
			}
			//earth.addChild(new Cube(/* new BitmapMaterial(bmp2) */ new ColorMaterial(), 50)).x = 70;
			//earth.addChild(new Cube(/* new BitmapMaterial(bmp2)  */new ColorMaterial(0x9A5BFA), 50)).z = -70;
			//earth.addChild(new Cube(/* new BitmapMaterial(bmp) */ new ColorMaterial(0x224466), 50)).z = 70;
			//earth.addChild(new Cube(/* new BitmapMaterial(bmp) */ new ColorMaterial(0x28F4F5), 50)).x = -80;
			//earth.addChild(new Sphere(new BitmapMaterial((new earthMap() as Bitmap).bitmapData), 60)).x = 150; 
		/* 	var d:DisplayObject3D = new Cube(new Material(new AnimatedTexture(new TestSprite()), new BasicShader()), 60);
			d.x = -100;
			d.y = 100; 
			d.z = 40;
			d.rotationY = 60;
			d.rotationZ = 45; 
			d.renderer.drawableList = new DrawableList();
 			scene.addChild(d); 
			 */
			 
			 scene.addChild(earth);
			 
			
			/*  BSP = new BSPTree(earth);
			BSP.renderer.drawableList.sortIndex = 2;
			scene.addChild(BSP);   */
			
			//add a static object after BSP is created!
			tallCube = new Cube(/* new BitmapMaterial(bmp2) */new ColorMaterial(0xFF9A22), 50);
			tallCube.scaleY = 4;
			tallCube.x = - 100;
			tallCube.y = 60;
			tallCube.rotationX = 74;
		//	BSP.addChild(tallCube);
			
			
			moon = new Cube(/* new BitmapMaterial((new earthMap() as Bitmap).bitmapData, true) */ new ColorMaterial(0xFF66FF), 50);
			moon.y = 10;
			moon.rotationX  = 10;
		
		//	BSP.addChild(moon);
		
			//scene.addChild(moon);
			
			/* var p:Plane = new Plane(new WireframeMaterial());
			scene.addChild(p);
			p.y = -100;
			var t:Triangle = (p.renderer.geometry as TriangleGeometry).triangles[0];
			t.createNormal();
			 */
			//renderer.drawManager.drawList.sorter.sortMode = DefaultDrawSorter.INDEXSORT;
			
			camera.y = 100;
			camera.transform.update();
			var ucs :UCS = new UCS("ucs0", 100);
			//blue.addChild(ucs);
			

			addEventListener(Event.ENTER_FRAME, render);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		}
		public static var OBJRENDERER:ObjectRenderer;
		private var _r :Number = 0;
		private var _s :Number = 0;
		private var mx:Number = 0;
		private var my:Number = 0;
		private var lx : Number = 0;
		private var ly : Number = 0;
		
		private function clamp(num:Number, min:Number, max:Number):Number{
			return num <= min ? min : num >= max ? max : num;
		}
		
		private var _forward:Boolean = false;
		private var _left:Boolean = false;
		private var _right:Boolean = false;
		private var _back:Boolean = false;
		
		private function keyDown(e:KeyboardEvent):void{
			switch(String.fromCharCode(e.charCode)){
				case "w": _forward= true;break;
				case "s": _back = true;break;
				case "a":_left=true;break;
				case "d":_right=true;break;
			}
		}
		private function keyUp(e:KeyboardEvent):void{
			switch(String.fromCharCode(e.charCode)){
				case "w": _forward= false;break;
				case "s": _back = false;break;
				case "a":_left=false;break;
				case "d":_right=false;break;
			}
		}
		
		private var startTime:Number = 0;
		private var drawTime:Number = 0;
		private function render(event:Event=null):void
		{
			drawTime = getTimer()-startTime;
			//trace(getTimer()-startTime);
			
			//moon.y += 0.5;
			//moon.rotationY++;
			moon.rotationY++;
			moon.rotationZ++;
			
			//tallCube.rotationX++;
			tallCube.rotationZ+=2;
		
			moon.y = Math.sin(_s) * 50;
		
			_s += 0.05; 

			lx -= (viewport.containerSprite.mouseY-my)*0.15;
			my =  viewport.containerSprite.mouseY;
			ly -= (viewport.containerSprite.mouseX-mx)*0.15;
			mx =  viewport.containerSprite.mouseX;
			
			lx = clamp(lx, -50, 60);
			
			 
			 camera.transform._eulerAngles = new Vector3D(lx, ly, 0);

			camera.x += _left?-5:0 + _right?5:0;
			camera.z += _forward?-5:0+_back?5:0;
	
			
			/* camera.rotationX = lx;
			camera.rotationY = ly; */
			
			
			/* camera.y = viewport.containerSprite.mouseY/(viewport.viewportHeight*0.5)*290;
			camera.x = viewport.containerSprite.mouseX/(viewport.viewportWidth*0.5)*290;
			camera.z = (camera.x + camera.z)/2+100;
			
			camera.lookAt(BSP); */
			
			renderer.renderScene(scene, camera, viewport);	
			//trace(getTimer()-startTime);
		
			var stats :RenderStats = renderer.renderData.stats;
			
			tf.text = "Papervision3D - version 3.0\n" +
				"\ntotal objects: " + stats.totalObjects +
				"\nculled objects: " + stats.culledObjects +
				"\n\ntotal triangles: " + stats.totalTriangles +
				"\nculled triangles: " + stats.culledTriangles +
				"\nclipped triangles: " + stats.clippedTriangles +
				"\n\nlocal: " + earth.transform.localEulerAngles +
				"\nglobal: " + earth.transform.eulerAngles +
				"\n"+
				"\nProjection: " + Timing.projectTime +" ms"+
				"\nRender Time: " + Timing.renderTime+" ms" + 
				"\nDraw Time: " + drawTime +" ms"; 
				
				
		   startTime = getTimer();
		}
	
	}
}
