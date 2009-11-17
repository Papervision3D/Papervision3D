package 
{
	import org.papervision3d.objects.parsers.DAE;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import net.hires.debug.Stats;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.memory.Timing;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.clipping.ClipFlags;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.data.RenderStats;
	import org.papervision3d.core.render.pipeline.BasicPipeline;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;

	[SWF (backgroundColor="#000000")]
	
	public class Main extends Sprite
	{
		use namespace pv3d;
		
		public var camera :Camera3D;
		public var viewport :Viewport3D;
		public var scene :DisplayObject3D;
		public var renderer :BasicRenderEngine;
		public var dae :DAE;
		public var tf :TextField;
		
		[Embed (source="testAssets/monster.dae", mimeType="application/octet-stream")]
		public var CowModel:Class;
		
		[Embed (source="testAssets/Cow.png")]
		public var CowTexture:Class;
		
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

			renderer = new BasicRenderEngine();
			renderer.clipFlags = ClipFlags.NONE;			
	
			dae = new DAE();
			dae.addFileSearchPath("testAssets");
			dae.load(new CowModel());
			
			scene.addChild(dae);
			
			dae.scaleX = dae.scaleY = dae.scaleZ = 0.5;
			dae.rotationX = -90;
			camera.lookAt(dae);
			
			addEventListener(Event.ENTER_FRAME, render);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		}
		
		private var startTime:Number = 0;
		private var drawTime:Number = 0;
		private function render(event:Event=null):void
		{
			drawTime = getTimer() - startTime;
			
			renderer.renderScene(scene, camera, viewport);	

			if (dae)
			{
				dae.rotationY++;
			}
			
			var stats :RenderStats = renderer.renderData.stats;
			
			tf.text = "Papervision3D - version 3.0\n" +
				"\ntotal objects: " + stats.totalObjects +
				"\nculled objects: " + stats.culledObjects +
				"\n\ntotal triangles: " + stats.totalTriangles +
				"\nculled triangles: " + stats.culledTriangles +
				"\nclipped triangles: " + stats.clippedTriangles +
				"\n"+
				"\nProjection: " + Timing.projectTime +" ms"+
				"\nRender Time: " + Timing.renderTime+" ms" + 
				"\nDraw Time: " + drawTime +" ms"; 
				
			startTime = getTimer();
		}
	}
}
