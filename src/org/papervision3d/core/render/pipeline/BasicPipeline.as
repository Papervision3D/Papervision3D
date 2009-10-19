package org.papervision3d.core.render.pipeline
{
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.math.utils.MathUtil;
	import org.papervision3d.core.math.utils.MatrixUtil;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.proto.Transform3D;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.lights.ILight;
	
	/**
	 * @author Tim Knip / floorplanner.com
	 */ 
	public class BasicPipeline implements IRenderPipeline
	{
		use namespace pv3d;
		
		private var _scheduledLookAt :Vector.<DisplayObject3D>;
		private var _lookAtMatrix :Matrix3D;
		private var _invWorldMatrix :Matrix3D;
		 
		/**
		 * 
		 */ 
		public function BasicPipeline()
		{
			_scheduledLookAt = new Vector.<DisplayObject3D>();
			_lookAtMatrix = new Matrix3D();
			_invWorldMatrix = new Matrix3D();
		}
		
		/**
		 * 
		 */ 
		public function execute(renderData:RenderData):void
		{
			var scene :DisplayObject3D = renderData.scene;
			var camera :Camera3D = renderData.camera;
			var rect :Rectangle = renderData.viewport.sizeRectangle;
			
			_scheduledLookAt.length = 0;
			
			transformToWorld(scene, renderData);	
			
			// handle lookAt
			if (_scheduledLookAt.length)
			{
				handleLookAt();
			}
			
			camera.update(rect);
			
			transformToView(camera, scene);
		}
		
		protected function handleLookAt():void
		{
			while (_scheduledLookAt.length)
			{
				var object :DisplayObject3D = _scheduledLookAt.pop();
				var parent :DisplayObject3D = object.parent as DisplayObject3D;
				var transform :Transform3D = object.transform;
				var eye :Vector3D = transform.position;
				var leye :Vector3D = transform.localPosition;
				var tgt :Vector3D = transform.scheduledLookAt.position;
				var up :Vector3D = transform.scheduledLookAtUp;
				
				// create the lookAt matrix
				MatrixUtil.createLookAtMatrix(eye, tgt, up, _lookAtMatrix);
				
			//	var p :Vector3D = leye.clone();
				
			//	p = _lookAtMatrix.transformVector(tgt);
				
				
				transform.worldTransform.rawData = _lookAtMatrix.rawData;
				//transform.worldTransform.prepend(_lookAtMatrix);
				transform.worldTransform.appendTranslation(-eye.x, -eye.y, -eye.z);
				//transform.worldTransform.append(_lookAtMatrix);
				
			//	_invWorldMatrix.rawData = parent.transform.m_rotation.rawData;
			//	_invWorldMatrix.invert();
				
				//_lookAtMatrix.prepend(_invWorldMatrix);
				
			//	transform.update(_lookAtMatrix);
				
			//	transform.worldTransform.rawData = transform.transform.rawData;
			//	transform.worldTransform.append(parent.transform.worldTransform);
			//		transform.worldTransform.prepend(_invWorldMatrix);
			//	transform.worldTransform.appendTranslation(-eye.x, -eye.y, eye.z);
			}
		}
		
		/**
		 * Processes all scheduled lookAt's.
		 */ 
		protected function handleLookAt2():void
		{
			while (_scheduledLookAt.length)
			{
				var object :DisplayObject3D = _scheduledLookAt.pop();
				var parent :DisplayObject3D = object.parent as DisplayObject3D;
				var transform :Transform3D = object.transform;
				var eye :Vector3D = transform.position;
				var tgt :Vector3D = transform.scheduledLookAt.position;
				var up :Vector3D = transform.scheduledLookAtUp;
				var components :Vector.<Vector3D>;
		
				// create the lookAt matrix
				MatrixUtil.createLookAtMatrix(eye, tgt, up, _lookAtMatrix);
				
				// prepend it to the world matrix
			//	object.transform.worldTransform.prepend(_lookAtMatrix);
				//eye = object.transform.localPosition;
				object.transform.worldTransform.rawData = _lookAtMatrix.rawData;
				object.transform.worldTransform.appendTranslation(eye.x, eye.y, eye.z);
				
				if (parent)
				{
					_invWorldMatrix.rawData = parent.transform.localRotation.matrix.rawData;
					_invWorldMatrix.invert();
					object.transform.worldTransform.append(_invWorldMatrix);
				}
			//	return;
				components = object.transform.worldTransform.decompose();
				var euler :Vector3D = components[1];
				
				
				object.transform.localEulerAngles.x = -euler.x * MathUtil.TO_DEGREES;
				object.transform.localEulerAngles.y = euler.y * MathUtil.TO_DEGREES;
				object.transform.localEulerAngles.z = euler.z * MathUtil.TO_DEGREES;
				
				// clear
				object.transform.scheduledLookAt = null;
			}
		}
		
		/**
		 * 
		 */ 
		protected function transformToWorld(object:DisplayObject3D, renderData:RenderData, parent:DisplayObject3D=null, processLookAt:Boolean=false):void
		{
			var child :DisplayObject3D;
			var wt :Matrix3D = object.transform.worldTransform;
			
			if (!processLookAt && object.transform.scheduledLookAt)
			{
				_scheduledLookAt.push( object );
			}
			
			object.transform.update();
			
			wt.rawData = object.transform.transform.rawData;
			
			if (parent)
			{
				wt.prepend(parent.transform.worldTransform);	
			}
			
			object.transform.position = wt.transformVector(object.transform.localPosition);
			
			if(object is ILight)
				renderData.lights.addLight((object as ILight));
				
			
			for each (child in object._children)
			{
				transformToWorld(child, renderData, object, processLookAt);
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