package org.papervision3d.core.geom.BSP
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.math.utils.GeomUtil;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.manager.IDrawManager;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class BSPTree extends DisplayObject3D
	{
		use namespace pv3d;
		public var rootNode:BSPTreeNode;
		protected var _drawablePool : DrawablePool;
		
		public function BSPTree(do3d:DisplayObject3D)
		{
			super();
			_drawablePool = new DrawablePool(TriangleDrawable);

			var geom : TriangleGeometry = GeomUtil.flattenObject(do3d);
			rootNode = new BSPTreeNode(null);
			
			
			GenerateBSPTree(rootNode, geom.triangles, 0, geom);
			renderer.geometry = geom;
			renderer.updateIndices();
		}
		
		public function walkTree(camera:Camera3D, renderData:RenderData):void{
			
			_drawablePool.reset();
			renderer.renderList.length = 0;
			
			//no polys, no children
			if(rootNode.polygonSet == null && rootNode.back == null)
				return;
				
			var eye: Vector3D = camera.transform.position;
			
			traverse(rootNode, eye, renderData);
drawPolygonList(renderer.renderList, renderData.drawManager);
			
		}
		
		public function traverse(node:BSPTreeNode, eye:Vector3D, renderData:RenderData):void{
			
			if(node == null)
				return;
				
			if(node.divider == null){
				drawPolygons(node.polygonSet, renderData.drawManager);
				return;
			}
			
			var side:uint = GeomUtil.classifyPoint(eye, node.divider);
			if(side == GeomUtil.FRONT){
				traverse(node.back, eye, renderData);
				drawPolygons(node.polygonSet, renderData.drawManager);
				renderData.stats.totalTriangles += node.polygonSet;
				traverse(node.front, eye, renderData);
				
			}else {
				//fix via tim's recommend
				traverse(node.front, eye, renderData);
				drawPolygons(node.polygonSet, renderData.drawManager);
				renderData.stats.totalTriangles += node.polygonSet;
				traverse(node.back, eye, renderData);
			}  
		}
		
		
		private var v0:Vector3D = new Vector3D(), v1:Vector3D = new Vector3D(), v2:Vector3D = new Vector3D();
		private var sv0 :Vector3D = new Vector3D();
		private var sv1 :Vector3D = new Vector3D();
		private var sv2 :Vector3D = new Vector3D();
			
		private function drawPolygons(polyList:Vector.<Triangle>, drawManager:IDrawManager):void{
			
			for each(var triangle:Triangle in polyList){
					renderer.renderList.push(triangle);
			}
			return;
			{
			
				
				// get vertices in view / camera space
					v0.x = renderer.viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = renderer.viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = renderer.viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = renderer.viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = renderer.viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = renderer.viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = renderer.viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = renderer.viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = renderer.viewVertexData[ triangle.v2.vectorIndexZ ];
					
					
					// passed the near test loosely, verts may have projected to infinity
					// we do it here, cause - paranoia - even these array accesses may cost us
					sv0.x = renderer.screenVertexData[ triangle.v0.screenIndexX ];	
					sv0.y = renderer.screenVertexData[ triangle.v0.screenIndexY ];
					sv1.x = renderer.screenVertexData[ triangle.v1.screenIndexX ];	
					sv1.y = renderer.screenVertexData[ triangle.v1.screenIndexY ];
					sv2.x = renderer.screenVertexData[ triangle.v2.screenIndexX ];	
					sv2.y = renderer.screenVertexData[ triangle.v2.screenIndexY ];
					

						 if ((sv2.x - sv0.x) * (sv1.y - sv0.y) - (sv2.y - sv0.y) * (sv1.x - sv0.x) > 0)
						{
						//	stats.culledTriangles ++;
							//triangle.clipFlags = 128;
						
						//	continue;
						}
 
				
						var drawable:TriangleDrawable = _drawablePool.drawable as TriangleDrawable;
						drawable.screenZ = 0;
						
						drawable.x0 = sv0.x;
						drawable.y0 = sv0.y;
						drawable.x1 = sv1.x;
						drawable.y1 = sv1.y;
						drawable.x2 = sv2.x;
						drawable.y2 = sv2.y;
						
						drawable.uvtData = drawable.uvtData || new Vector.<Number>(9, true);
						drawable.uvtData[0] = triangle.uv0.u;
						drawable.uvtData[1] = triangle.uv0.v;
						drawable.uvtData[2] = renderer.uvtData[ triangle.v0.vectorIndexZ ];
						drawable.uvtData[3] = triangle.uv1.u;
						drawable.uvtData[4] = triangle.uv1.v;
						drawable.uvtData[5] = renderer.uvtData[ triangle.v1.vectorIndexZ ];
						drawable.uvtData[6] = triangle.uv2.u;
						drawable.uvtData[7] = triangle.uv2.v;
						drawable.uvtData[8] = renderer.uvtData[ triangle.v2.vectorIndexZ ];
						drawable.shader = triangle.shader;
						//trace(renderer.geometry.uvtData);
						drawManager.addDrawable(drawable);
						
						triangle.drawable = drawable;
				
				
			}
			
		}
		
		private function drawPolygonList(polyList:Vector.<Triangle>, drawManager:IDrawManager):void{
			
			for each(var triangle:Triangle in polyList){
			//		renderer.renderList.push(triangle);
			
			
				
				// get vertices in view / camera space
					v0.x = renderer.viewVertexData[ triangle.v0.vectorIndexX ];	
					v0.y = renderer.viewVertexData[ triangle.v0.vectorIndexY ];
					v0.z = renderer.viewVertexData[ triangle.v0.vectorIndexZ ];
					v1.x = renderer.viewVertexData[ triangle.v1.vectorIndexX ];	
					v1.y = renderer.viewVertexData[ triangle.v1.vectorIndexY ];
					v1.z = renderer.viewVertexData[ triangle.v1.vectorIndexZ ];
					v2.x = renderer.viewVertexData[ triangle.v2.vectorIndexX ];	
					v2.y = renderer.viewVertexData[ triangle.v2.vectorIndexY ];
					v2.z = renderer.viewVertexData[ triangle.v2.vectorIndexZ ];
					
					
					// passed the near test loosely, verts may have projected to infinity
					// we do it here, cause - paranoia - even these array accesses may cost us
					sv0.x = renderer.screenVertexData[ triangle.v0.screenIndexX ];	
					sv0.y = renderer.screenVertexData[ triangle.v0.screenIndexY ];
					sv1.x = renderer.screenVertexData[ triangle.v1.screenIndexX ];	
					sv1.y = renderer.screenVertexData[ triangle.v1.screenIndexY ];
					sv2.x = renderer.screenVertexData[ triangle.v2.screenIndexX ];	
					sv2.y = renderer.screenVertexData[ triangle.v2.screenIndexY ];
					

						 if ((sv2.x - sv0.x) * (sv1.y - sv0.y) - (sv2.y - sv0.y) * (sv1.x - sv0.x) > 0)
						{
						//	stats.culledTriangles ++;
							//triangle.clipFlags = 128;
						
						//	continue;
						}
 
				
						var drawable:TriangleDrawable = _drawablePool.drawable as TriangleDrawable;
						drawable.screenZ = 0;
						
						drawable.x0 = sv0.x;
						drawable.y0 = sv0.y;
						drawable.x1 = sv1.x;
						drawable.y1 = sv1.y;
						drawable.x2 = sv2.x;
						drawable.y2 = sv2.y;
						
						drawable.uvtData = drawable.uvtData || new Vector.<Number>(9, true);
						drawable.uvtData[0] = triangle.uv0.u;
						drawable.uvtData[1] = triangle.uv0.v;
						drawable.uvtData[2] = renderer.uvtData[ triangle.v0.vectorIndexZ ];
						drawable.uvtData[3] = triangle.uv1.u;
						drawable.uvtData[4] = triangle.uv1.v;
						drawable.uvtData[5] = renderer.uvtData[ triangle.v1.vectorIndexZ ];
						drawable.uvtData[6] = triangle.uv2.u;
						drawable.uvtData[7] = triangle.uv2.v;
						drawable.uvtData[8] = renderer.uvtData[ triangle.v2.vectorIndexZ ];
						drawable.shader = triangle.shader;
						//trace(renderer.geometry.uvtData);
						drawManager.addDrawable(drawable);
						
						triangle.drawable = drawable;
				
				
			}
			
		}

		private static function chooseRandomPoly(polySet:Vector.<Triangle>):Triangle{
			return polySet[int(Math.random()*polySet.length-1)];
		}
		
		//http://www.devmaster.net/articles/bsp-trees/ method - not sure how good actually is...
		protected static function chooseBestPoly(polySet : Vector.<Triangle>) : Triangle
		{

			var _splitTestPlane : Plane3D = new Plane3D();
			var bestTriangle : Triangle = polySet[0];
			var leastSplits : Number = Number.POSITIVE_INFINITY;
			var bestRelation : Number = -1;
			
			var splitCount : int = 0;
			var backCount : int = 0;
			var frontCount : int = 0;
			var bestCount : Number = Number.POSITIVE_INFINITY;
			var relation : Number = 0;
			var minRelation : Number = Number.NEGATIVE_INFINITY * -1;
			
			
				for each(var tri:Triangle in polySet){
					
					splitCount = 0;
					frontCount = 0;
					backCount = 0;
					_splitTestPlane.setThreePoints(tri.v0, tri.v1, tri.v2);
					for each(var tri2 :Triangle in polySet){
						
						if(tri == tri2){
							continue;
						}
						
						var side : uint = GeomUtil.classifyTriangle(tri2, _splitTestPlane, 0.01);
						if(side == GeomUtil.BACK)
							backCount++;
						else if(side == GeomUtil.FRONT)
							frontCount++;
						else if(side == GeomUtil.STRADDLE)
							splitCount++;
							
					} 
					
					if(frontCount<backCount)
						relation = frontCount/backCount;
					else
						relation = backCount/frontCount;

					if((relation > minRelation && splitCount < leastSplits) || (splitCount == leastSplits && relation > bestRelation)){
						bestTriangle = tri;
						leastSplits = splitCount;
						bestRelation = relation;
					}
					
				}

			return bestTriangle;
			
		}
		
		
		
		private static var staticPlane:Plane3D = new Plane3D();
		public static function GenerateBSPTree(node:BSPTreeNode, polySet:Vector.<Triangle>, depth:int, geom:TriangleGeometry):void{
			
			//trace("depth: ", depth);
			if(depth > 1800){
				trace("TOO DEEP!");
				return;
			}
			
			if(IsConvex(polySet)){
				for each(var tt:Triangle in polySet)
					node.polygonSet.push(tt);
				return;
			}
			
			var poly:Triangle = chooseBestPoly(polySet);
			var divider : Plane3D = Plane3D.fromThreePoints(poly.v0, poly.v1, poly.v2);
			
			var posSet : Vector.<Triangle> = new Vector.<Triangle>();
			var negSet : Vector.<Triangle> = new Vector.<Triangle>(); 
			
			node.divider = divider;
			node.front = new BSPTreeNode(null);
			node.back = new BSPTreeNode(null);
			
			for each(var t:Triangle in polySet){
				
				var side:uint = GeomUtil.classifyTriangle(t, divider);
				if(side == GeomUtil.FRONT){
					posSet.push(t);
				}else if(side == GeomUtil.BACK){
					negSet.push(t);
				}else if(side == GeomUtil.STRADDLE){
					
					var results:Array = GeomUtil.splitTriangleByPlane(t, geom, divider, 0.01, true, 0.25);
					//geom.removeTriangle(t);
					for each(var tF:Triangle in results[0]){
						posSet.push(tF);
					}
					for each(var tB:Triangle in results[1]){
						negSet.push(tB);
					}
				}else{
										
					node.polygonSet.push(t);
				}
				
			}
			
			
			
			GenerateBSPTree(node.front, posSet, depth+1, geom);
			GenerateBSPTree(node.back, negSet, depth+1, geom);
			
		}
		
		
		private static var _workPlane : Plane3D = new Plane3D();
		protected static function PolyInFront(t0:Triangle, t1:Triangle):Boolean{
			_workPlane.setThreePoints(t1.v0, t1.v1, t1.v2);
			return GeomUtil.classifyTriangle(t0, _workPlane) == GeomUtil.FRONT;
		}
		
		protected static function IsConvex(polySet:Vector.<Triangle>):Boolean{
			if(polySet.length == 1)
				return true;
			for each(var t0:Triangle in polySet){
				for each(var t1:Triangle in polySet){
					if(t0 != t1 && !PolyInFront(t0, t1))
						return false;
				}
			} 
			return true;
		} 

	}
}