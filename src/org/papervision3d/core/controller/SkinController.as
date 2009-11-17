package org.papervision3d.core.controller
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import org.ascollada.core.DaeBlendWeight;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.VertexGeometry;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class SkinController extends AbstractController
	{
		use namespace pv3d;
		
		/**
		 * 
		 */
		public var input :AbstractController;
		
		/**
		 * 
		 */
		public var poseMatrix : Matrix3D;
		
		/**
		 * 
		 */
		public var bindShapeMatrix : Matrix3D;
		
		/**
		 * 
		 */		
		public var joints : Vector.<DisplayObject3D>;

		/**
		 * 
		 */
		public var inverseBindMatrices : Vector.<Matrix3D>;

		/** 
		 * 
		 */
		public var vertexWeights : Vector.<Vector.<DaeBlendWeight>>;
		
		/**
		 * 
		 */
		private var _geometry :VertexGeometry;
		
		/**
		 * 
		 */ 
		private var _cached :VertexGeometry;
		
		/**
		 * 
		 */
		private var _matrix :Matrix3D;
		 
		/**
		 * Constructor.
		 */ 
		public function SkinController(	geometry :VertexGeometry=null, 
								 	 	bindShapeMatrix :Matrix3D = null,
									 	joints : Vector.<DisplayObject3D> = null,
									 	inverseBindMatrices : Vector.<Matrix3D> = null,
									 	vertexWeights : Vector.<Vector.<DaeBlendWeight>> = null)
		{
			super();
			this.geometry = geometry;
			this.bindShapeMatrix = bindShapeMatrix || new Matrix3D();
			this.joints = joints || new Vector.<DisplayObject3D>();
			this.inverseBindMatrices = inverseBindMatrices || new Vector.<Matrix3D>();
			this.vertexWeights = vertexWeights || new Vector.<Vector.<DaeBlendWeight>>();
			
			_matrix = new Matrix3D();
		}
		
		/**
		 * 
		 */
		public function addJoint(joint:DisplayObject3D, inverseBindMatrix:Matrix3D, blendWeights:Vector.<DaeBlendWeight>):void 
		{
			this.joints.push(joint);
			this.inverseBindMatrices.push(inverseBindMatrix);
			this.vertexWeights.push(blendWeights);
		}
		
		/**
		 * 
		 */
		override public function update():void
		{
			//trace(joints.length + " " + _geometry.vertices);
			
			if(!joints.length || !geometry.vertices || !geometry.vertices.length) 
			{
				return;
			}
			
			if((!_cached && !input) || inverseBindMatrices.length != joints.length || vertexWeights.length != joints.length) 
			{
				return;
			}
			
			// reset all vertices to zero
			var original : Vector.<Vertex> = _geometry.vertices;
			var vertex : Vertex;			
			for each(vertex in original) 
			{
				_geometry.vertexData[ int(vertex.vectorIndexX) ] = 0;
				_geometry.vertexData[ int(vertex.vectorIndexY) ] = 0;
				_geometry.vertexData[ int(vertex.vectorIndexZ) ] = 0;
			}
			
			if(input) 
			{
				// this modifier uses another modifier as input...
				//this.geometry = input.geometry;
			}
			
			var cloned : Vector.<Vertex> = _cached.vertices;
			var i : int;
			for(i = 0; i < joints.length; ++i) 
			{
				skin(joints[i], vertexWeights[i], inverseBindMatrices[i], cloned, original);
			}
		} 
		
		/**
		 * 
		 */
		protected function skin(joint : DisplayObject3D, weights : Vector.<DaeBlendWeight>, inverseBindMatrix : Matrix3D,
								original : Vector.<Vertex>, skinned : Vector.<Vertex>) : void {

			var o : Vertex, s : Vertex;
			var pos : Vector3D = new Vector3D();
			var weight : Number, index : int;
			var w : DaeBlendWeight;
			var i:int;
			
			_matrix.rawData = joint.transform.worldTransform.rawData;
			_matrix.prepend(inverseBindMatrix);
			
			for( i = 0; i < weights.length; i++ ) 
			{
				w = weights[i];
				weight = w.weight;
				index = w.vertexIndex;
				
				if(weight <= 0.0001 || weight >= 1.0001) continue;

				o = original[ index ];	
				s = skinned[ index ];
				
				pos.x = o.x;
				pos.y = o.y;
				pos.z = o.z;
				
				// transform
				pos = _matrix.transformVector(pos);
			
				//update the vertex
				_geometry.vertexData[ int(s.vectorIndexX) ] += (pos.x * weight);
				_geometry.vertexData[ int(s.vectorIndexY) ] += (pos.y * weight);
				_geometry.vertexData[ int(s.vectorIndexZ) ] += (pos.z * weight);
			}		
		}
		
		/**
		 * 
		 */ 
		public function get geometry():VertexGeometry
		{
			return _geometry;
		}
		
		public function set geometry(value:VertexGeometry):void
		{
			var vertex : Vertex;
			var needVerts :Boolean = false;
			var i : int;
			
			if (!value)
			{
				return;
			}
			
			_geometry = value;
			if(_cached && _cached.vertices.length == _geometry.vertices.length) 
			{
				// prevent creating a clone!
			} 
			else 
			{
				_cached = new VertexGeometry();
				needVerts = true;
			}
			
			for(i = 0; i < _geometry.vertices.length; i++) 
			{
				vertex = _geometry.vertices[i];
				
				var pos : Vector3D = new Vector3D(vertex.x, vertex.y, vertex.z);
				
				pos = this.bindShapeMatrix.transformVector(pos);
				
				if (needVerts)
				{	
					_cached.addVertex(new Vertex(pos.x, pos.y, pos.z));
				}
				else
				{
					_cached.vertices[i].x = pos.x;
					_cached.vertices[i].y = pos.y;
					_cached.vertices[i].z = pos.z;	
				}
			}
		}
	}
}
