package org.papervision3d.core.render.pipeline
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.proto.Transform3D;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class BasicPipeline implements IRenderPipeline
	{
		use namespace pv3d;
		
		public var camera :Camera3D;
		public var projection :Matrix3D;
		
		private var _lookAts :Vector.<DisplayObject3D>;
		private var _defaultAt :Vector3D;
		private var _defaultUp :Vector3D;
		
		public function BasicPipeline()
		{
			_lookAts = new Vector.<DisplayObject3D>();
			
			_defaultAt = new Vector3D(0, 0, -1);
			_defaultUp = new Vector3D(0, -1, 0);
		}
		
		public function execute(renderData:RenderData):void
		{
			var rect :Rectangle = renderData.viewport.sizeRectangle;
			
			camera = renderData.camera;	
			
			_lookAts.length = 0;

			transformToWorld(renderData.scene);

			if (_lookAts.length)
			{
				processLookAt();	
			}
			
			camera.update(rect);
			projection = camera.projectionMatrix;
			
			transformToView(camera, renderData.scene);
		}
		
		public function processLookAt():void
		{
			while (_lookAts.length)
			{
				var object :DisplayObject3D = _lookAts.pop();
				var targetTM :Transform3D = object.transform.scheduledLookAt;
				var sourceTM :Transform3D = object.transform;
				var wt :Matrix3D = object.transform.worldTransform;
				var pos :Vector3D = targetTM.position.subtract(object.transform.position);

				wt.identity();
				wt.pointAt(pos, _defaultAt, _defaultUp);
				wt.appendTranslation(sourceTM.position.x, sourceTM.position.y, sourceTM.position.z);
			}
		}
		
		public function transformToWorld(object:DisplayObject3D):void
		{
			var transform :Transform3D = object.transform;
			var child :DisplayObject3D;
			var wt :Matrix3D = object.transform.worldTransform;
			
			if (object.transform.scheduledLookAt)
			{
				_lookAts.push(object);
			}

			wt.rawData = object.transform.localToWorldMatrix.rawData;
			
			var tmp :Matrix3D = wt.clone();
			
			if (object.parent)
			{
				wt.append(object.parent.transform.worldTransform);
			}
			
			transform.rotateGlob(1, 0, 0, transform.eulerAngles.x, wt);
			transform.rotateGlob(0, 1, 0, transform.eulerAngles.y, wt);
			transform.rotateGlob(0, 0, 1, transform.eulerAngles.z, wt);
			
			wt.prependScale(transform.localScale.x, transform.localScale.y, transform.localScale.z);
			
			object.transform.position = wt.position;

			for each(child in object._children)
			{
				transformToWorld(child);
			}
		}
		
		/**
		 * 
		 */ 
		protected function transformToView(camera:Camera3D, object:DisplayObject3D):void
		{
			var child :DisplayObject3D;
			var wt :Matrix3D = object.transform.worldTransform;
			var vt :Matrix3D = object.transform.viewTransform;
			
			vt.rawData = wt.rawData;
			vt.append(camera.viewMatrix);
			
			if (object.renderer.geometry is VertexGeometry)
			{
				projectVertices(camera, object);
			}
			
			for each (child in object._children)
			{
				transformToView(camera, child);
			}
		}
		
		/**
		 * 
		 */ 
		protected function projectVertices(camera:Camera3D, object:DisplayObject3D):void
		{
			var vt :Matrix3D = object.transform.viewTransform;
			var st :Matrix3D = object.transform.screenTransform;
			var renderer : ObjectRenderer = object.renderer;
			// move the vertices into view / camera space
			// we'll need the vertices in this space to check whether vertices are behind the camera.
			// if we move to screen space in one go, screen vertices could move to infinity.
			vt.transformVectors(renderer.geometry.vertexData, renderer.viewVertexData);
			
			// append the projection matrix to the object's view matrix
			st.rawData = vt.rawData;
			st.append(camera.projectionMatrix);
			
			// move the vertices to screen space.
			// AKA: the perspective divide
			// NOTE: some vertices may have moved to infinity, we need to check while processing triangles.
			//       IF so we need to check whether we need to clip the triangles or disgard them.
			Utils3D.projectVectors(st, renderer.geometry.vertexData, renderer.screenVertexData, renderer.uvtData);
		}
	}
}