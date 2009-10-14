package 
{
	import flash.display.BitmapData;
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
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
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
			
			
			var cubeChildx : Cube = new Cube(new BitmapMaterial(new BitmapData(256, 256, true, 0x6600FFFF)), 100);
			cubeChildx.x = 100;
			cube.addChild(cubeChildx);
			//cube = new Cube(new WireframeMaterial(0xFF0000), 100, "Cube");
			
			var cubeChild0 :Cube = new Cube(new WireframeMaterial(0xFF0000), 100, "red");
			cube.addChild( cubeChild0 );
			cubeChild0.x = 300;
			//cubeChild0.z = -500;
			
			var bmp2:BitmapData = new BitmapData(256, 256);
			bmp2.perlinNoise(128, 128, 4, 30239423, false, true);
			
			var cubeChild1 :Cube = new Cube(new BitmapMaterial(bmp2), 100, "blue");
			cube.addChild( cubeChild1 );
			cubeChild1.z = 300;

			
			var cubeChild2 :Cube = new Cube(new WireframeMaterial(0x0000FF), 100, "green");
			cube.addChild( cubeChild2 );
			cubeChild2.y = 200;
			cubeChild2.z = 10;
			
			cubeChild1.scaleX = 3;
			cubeChild1.scaleY = 3;
			cubeChild1.scaleZ = 0.1;
			
			scene.addChild( cube );
			
			camera2 = new Camera3D(90, 60, 300);
			cube.addChild(camera2);
			camera2.showFrustum = true;
			//cube.scaleX = 2;
			//var plane :Plane = new Plane(new WireframeMaterial(0x0000FF), 400, 400, 1, 1, "Plane0");
			//scene.addChild(plane);

			addEventListener(Event.ENTER_FRAME, render);
		}
		
		private var _r :Number = 0;
		private var _s :Number = 0;
		 
		private function render(event:Event=null):void
		{
			camera2.frustumGeometry.update(camera2);
			
			// rotation in global frame of reference : append
		//	cube.x ++;
			cube.rotationY--;
			
			//cube.getChildByName("blue").x += 0.1;
			//cube.getChildByName("blue").rotationZ--;
		//	cube.getChildByName("blue").lookAt( cube.getChildByName("red") );
			cube.getChildByName("blue").rotationZ += 0.1;
			
			cube.getChildByName("blue").transform.eulerAngles.y--;
			cube.getChildByName("green").lookAt( cube.getChildByName("red") );
			
			//cube.lookAt(cube.getChildByName("blue"));
			
			cube.getChildByName("red").transform.eulerAngles.z--;
			cube.getChildByName("red").transform.eulerAngles.y += 4;
			cube.getChildByName("red").transform.dirty = true;
		//	cube.getChildByName("red").rotateAround(_s++, new Vector3D(0, _s, _s));
		//	cube.getChildByName("red").scaleX = 2;
		//	cube.getChildByName("red").rotateAround(_s, new Vector3D(0, -_s, 0));
		//	cube.getChildByName("green").rotateAround(_r++, Vector3D.X_AXIS);
			
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
