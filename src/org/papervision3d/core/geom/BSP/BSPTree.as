package org.papervision3d.core.geom.BSP
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.Triangle;
	import org.papervision3d.core.geom.Vertex;
	import org.papervision3d.core.geom.provider.TriangleGeometry;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.math.utils.GeomUtil;
	import org.papervision3d.core.memory.pool.DrawablePool;
	import org.papervision3d.core.memory.pool.TrianglePool;
	import org.papervision3d.core.ns.pv3d;
	import org.papervision3d.core.render.data.RenderData;
	import org.papervision3d.core.render.draw.items.TriangleDrawable;
	import org.papervision3d.core.render.draw.manager.IDrawManager;
	import org.papervision3d.core.render.object.BSPChildRenderer;
	import org.papervision3d.core.render.object.BSPRenderer;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * 
	 * @author: andy zupko / zupko.info
	 * 
	 **/
	
	public class BSPTree extends DisplayObject3D
	{
		use namespace pv3d;
		public var rootNode:BSPTreeNode;
		protected var _drawablePool : DrawablePool;
		public var dynamicRenderer:BSPRenderer;
		
		private var staticTriCount:int = 0;
		private var staticViewVertexCount:int = 0;
		private var staticScreenVertexCount:int = 0;
		private var staticVertexCount:int = 0;
		
		public function BSPTree(do3d:DisplayObject3D)
		{
			super();
			
			_drawablePool = new DrawablePool(TriangleDrawable);

			var geom : TriangleGeometry = GeomUtil.flattenObject(do3d);
			rootNode = new BSPTreeNode(false);

			GenerateBSPTree(rootNode, geom.triangles, 0, geom);
			renderer.geometry = geom;
			renderer.updateIndices();
			updateStaticCounts();
			dynamicRenderer = new BSPRenderer(this);
		}
		
		protected function resetToStatic():void{
		/* 	
			nodeCount = 0;
			countNodes(rootNode);
			trace("NODE COUNT: "+nodeCount);
		 */
			(renderer.geometry as TriangleGeometry).triangles.length = staticTriCount;
			
			renderer.geometry.vertices.length = staticVertexCount;
			renderer.geometry.vertexData.length = staticViewVertexCount;
			renderer.geometry.viewVertexLength = staticViewVertexCount;
			renderer.geometry.screenVertexLength = staticScreenVertexCount;
			renderer.updateIndices();
			
			
			clearDynamicNodes(rootNode);

		}
		private static var nodeCount : int = 0;
		public function countNodes(node:BSPTreeNode):void{
			if(node == null)
				return;
			nodeCount++;
			countNodes(node.front);
			countNodes(node.back);
		}
		protected function clearDynamicNodes(node:BSPTreeNode):void{
			
			node.dynamicPolySet.length = 0;
			
			if(node.front){
				if(node.front.isDynamic){
					node.front = null;
					node.back = null;
					node.divider = null;
					
					return;
				}
				clearDynamicNodes(node.front);
				clearDynamicNodes(node.back);
			}else{
				node.divider = null;
			}
			
		}
		
		protected function updateStaticCounts():void{
			staticTriCount = (renderer.geometry as TriangleGeometry).triangles.length;
			staticScreenVertexCount = renderer.geometry.screenVertexLength;
			staticViewVertexCount = renderer.geometry.viewVertexLength;
			staticVertexCount = renderer.geometry.vertices.length;
			
		}
		
		
		
		
		private var v0:Vector3D = new Vector3D(), v1:Vector3D = new Vector3D(), v2:Vector3D = new Vector3D();
		private var sv0 :Vector3D = new Vector3D();
		private var sv1 :Vector3D = new Vector3D();
		private var sv2 :Vector3D = new Vector3D();
			
		private function addPolygons(polyList:Vector.<Triangle>, dynamicPolyList:Vector.<Triangle>, drawManager:IDrawManager):void{
			
			for each(var triangle:Triangle in polyList){
					renderer.renderList.push(triangle);
			}
			
			for each(var triangle2:Triangle in dynamicPolyList){
					renderer.renderList.push(triangle2);
			}
						
		}
		
		protected var dynamicChildren:Dictionary = new Dictionary(true);
		private var triPool:TrianglePool = Triangle.pool;
		public function pushChildrenOntoTree():void{
			//trace("pushed", renderer.geometry.vertices.length, renderer.viewVertexData.length, renderer.geometry.viewVertexLength, renderer.screenVertexData.length);
			triPool.reset();
			Vertex.pool.reset();
			resetToStatic();
			for each(var c:DisplayObject3D in dynamicChildren){
				c.transform.worldTransform.transformVectors(c.renderer.geometry.vertexData, c.renderer.worldVertexData);
				var tris:Vector.<Triangle> = getObjectTriangles(c.renderer);
				 for each(var t:Triangle in tris)
					(renderer.geometry as TriangleGeometry).addTriangle(t); 
				trickle(rootNode, tris /* (c.renderer.geometry as TriangleGeometry).triangles */, 0, renderer.geometry as TriangleGeometry, true);
				
			}
	
			renderer.updateIndices();
		
		}

		
		private var tris:Vector.<Triangle> = new Vector.<Triangle>();
		private function getObjectTriangles(objectRenderer:ObjectRenderer):Vector.<Triangle>{
			tris.length = 0;
			
				for each(var t:Triangle in (objectRenderer.geometry as TriangleGeometry).triangles){
					var tmp:Triangle = triPool.triangle;
					tmp.shader = t.shader;
					tmp.v0.x = objectRenderer.worldVertexData[t.v0.vectorIndexX];
					tmp.v0.y = objectRenderer.worldVertexData[t.v0.vectorIndexY];
					tmp.v0.z = objectRenderer.worldVertexData[t.v0.vectorIndexZ];
					tmp.v1.x = objectRenderer.worldVertexData[t.v1.vectorIndexX];
					tmp.v1.y = objectRenderer.worldVertexData[t.v1.vectorIndexY];
					tmp.v1.z = objectRenderer.worldVertexData[t.v1.vectorIndexZ];
					tmp.v2.x = objectRenderer.worldVertexData[t.v2.vectorIndexX];
					tmp.v2.y = objectRenderer.worldVertexData[t.v2.vectorIndexY];
					tmp.v2.z = objectRenderer.worldVertexData[t.v2.vectorIndexZ]; 

					tmp.uv0 = t.uv0;
					tmp.uv1 = t.uv1;
					tmp.uv2 = t.uv2;			

					tris.push(tmp);
				}
			return tris;
		}
		
		public override function addChild(do3d:DisplayObject3D):DisplayObject3D{
			
			super.addChild(do3d);
			dynamicChildren[do3d] = do3d;
			do3d.renderer = new BSPChildRenderer(do3d);

			return do3d;
		}

		public override function removeChild(child:DisplayObject3D, deep:Boolean=false):DisplayObject3D{
			super.removeChild(child, deep);
			delete dynamicChildren[child];
			return child;
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
						
						var side : uint = GeomUtil.classifyTriangle(tri2, _splitTestPlane, 0.03125);
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
		
		
		//http://www.exaflop.org/docs/naifgfx/naifbsp.html
		protected static function chooseBestValuePoly(polySet : Vector.<Triangle>) : Triangle
		{

			var _splitTestPlane : Plane3D = new Plane3D();
			var bestTriangle : Triangle = polySet[0];
			var leastSplits : Number = Number.POSITIVE_INFINITY;
			var bestRelation : Number = -1;
			
			var splitCount : int = 0;
			var backCount : int = 0;
			var frontCount : int = 0;
			var bestValue : Number = 0;
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
						
						var side : uint = GeomUtil.classifyTriangle(tri2, _splitTestPlane, 0.03125);
						if(side == GeomUtil.BACK)
							backCount++;
						else if(side == GeomUtil.FRONT)
							frontCount++;
						else if(side == GeomUtil.STRADDLE)
							splitCount++;
							
					} 
					
					var value : Number = Math.abs( frontCount - backCount ) + (splitCount * 2 );
					if(value > bestValue){
						bestValue = value;
						bestTriangle = tri;
					}
						
					
				}

			return bestTriangle;
			
		}
		
		/*
		
		BUILD THE INITIAL TREE
		
		*/		
		
		private  var staticPlane:Plane3D = new Plane3D();
		public function GenerateBSPTree(node:BSPTreeNode, polySet:Vector.<Triangle>, depth:int, geom:TriangleGeometry, dynamicNode:Boolean = false):void{

			if(depth > 1800){
				trace("TOO DEEP!");
				return;
			}
			
			if(IsConvex(polySet, dynamicNode)){
				for each(var tt:Triangle in polySet)
					dynamicNode? node.dynamicPolySet.push(tt) : node.polygonSet.push(tt);
				return;
			}
			
			
			var poly:Triangle = dynamicNode ? chooseBestValuePoly(polySet) : chooseBestValuePoly(polySet);
			var divider:Plane3D = Plane3D.fromThreePoints(poly.v0, poly.v1, poly.v2);
			
			
			var posSet:Vector.<Triangle> = new Vector.<Triangle>();
			var negSet:Vector.<Triangle> = new Vector.<Triangle>();
			
			node.divider = divider;
			node.front = new BSPTreeNode(dynamicNode);
			node.back = new BSPTreeNode(dynamicNode);
			
			for each(var t:Triangle in polySet){
				
				var side:uint = GeomUtil.classifyTriangle(t, divider);
				if(side == GeomUtil.FRONT){
					posSet.push(t);
				}else if(side == GeomUtil.BACK){
					negSet.push(t);
				}else if(side == GeomUtil.STRADDLE){
					
					var results:Array = GeomUtil.splitTriangleByPlane(t, geom, divider, 0.03125, !dynamicNode, 0.25, dynamicNode);
					//geom.removeTriangle(t);
					for each(var tF:Triangle in results[0]){
						posSet.push(tF);
					}
					for each(var tB:Triangle in results[1]){
						negSet.push(tB);
					}
				}else{
										
					dynamicNode? node.dynamicPolySet.push(t) : node.polygonSet.push(t);
				}
				
			}
			
			
			
			GenerateBSPTree(node.front, posSet, depth+1, geom);
			GenerateBSPTree(node.back, negSet, depth+1, geom);
			
		}
		
	
		
		/**
		 * 
		 *  pushObjectOntoTree & Trickle
		 * 	- add a new static object to the tree
		 * 
		 * */
		 
		 
		
		public function addStaticChild(do3d:DisplayObject3D):void{
			var cont:DisplayObject3D = new DisplayObject3D();
			cont.addChild(do3d);
			var geom : TriangleGeometry = GeomUtil.flattenObject(cont);
			
			trickle(rootNode, geom.triangles, 0, renderer.geometry as TriangleGeometry);
			renderer.updateIndices();
			updateStaticCounts();
			
		}
		

		
		protected function trickle(node:BSPTreeNode, polySet:Vector.<Triangle>, depth:int, geom:TriangleGeometry, dynamicNode:Boolean = false):void{
			
			if(polySet.length == 0)
				return;
			
			var generate:Boolean = false;

			//at a leaf, start building on it
			if(node.divider == null || node.front == null){

				GenerateBSPTree(node, polySet, depth+1, geom, dynamicNode);
				return;
			}

			
			var divider : Plane3D = node.divider;
			
			var posSet : Vector.<Triangle> = new Vector.<Triangle>();
			var negSet : Vector.<Triangle> = new Vector.<Triangle>(); 
			
			for each(var t:Triangle in polySet){
				
				var side:uint = GeomUtil.classifyTriangle(t, divider);
				if(side == GeomUtil.FRONT){
					posSet.push(t);
				}else if(side == GeomUtil.BACK){
					negSet.push(t);
				}else if(side == GeomUtil.STRADDLE){
					
					var results:Array = GeomUtil.splitTriangleByPlane(t, geom, divider, 0.03125, !dynamicNode, 0.25, dynamicNode);
					//geom.removeTriangle(t);
					for each(var tF:Triangle in results[0]){
						posSet.push(tF);
					}
					for each(var tB:Triangle in results[1]){
						negSet.push(tB);
					}
				}else{
					
					dynamicNode? node.dynamicPolySet.push(t) : node.polygonSet.push(t);
				}
				
			}
			if(!generate){
				trickle(node.front, posSet, depth+1, geom, dynamicNode);
				trickle(node.back, negSet, depth+1, geom, dynamicNode);
			}else{
				node.front = new BSPTreeNode(dynamicNode);
				node.back = new BSPTreeNode(dynamicNode);
				GenerateBSPTree(node.front, posSet, depth+1, geom, dynamicNode);
				GenerateBSPTree(node.back, negSet, depth+1, geom, dynamicNode);
			}
		}
		
		
		private  var _workPlane : Plane3D = new Plane3D();
		protected  function PolyInFront(t0:Triangle, t1:Triangle):Boolean{
			_workPlane.setThreePoints(t1.v0, t1.v1, t1.v2);
			return GeomUtil.classifyTriangle(t0, _workPlane) == GeomUtil.FRONT;
		}
		
		protected function IsConvex(polySet:Vector.<Triangle>, dynamicNode:Boolean = false):Boolean{
			
			if(polySet.length == 1)
				return true;
			
			//for dynamic nodes, lets not compare all of them, only goto single leafs
			if(dynamicNode)
				return false;
				
			for each(var t0:Triangle in polySet){
				for each(var t1:Triangle in polySet){
					if(t0 != t1 && !PolyInFront(t0, t1))
						return false;
				}
			} 
			return true;
		} 
		
		public function walkTree(camera:Camera3D, renderData:RenderData):void{
			
			_drawablePool.reset();
			renderer.renderList.length = 0;
			
			//no polys, no children
			if(rootNode.polygonSet == null && rootNode.dynamicPolySet == null && rootNode.back == null)
				return;
				
			var eye: Vector3D = camera.transform.position;
			
			traverse(rootNode, eye, renderData);
			
			
			
		}
		
		public function traverse(node:BSPTreeNode, eye:Vector3D, renderData:RenderData):void{
			
			if(node == null)
				return;
				
			if(node.divider == null){
				addPolygons(node.polygonSet, node.dynamicPolySet, renderData.drawManager);
				return;
			}
			
			var side:uint = GeomUtil.classifyPoint(eye, node.divider);
			if(side == GeomUtil.FRONT){
				traverse(node.back, eye, renderData);
				addPolygons(node.polygonSet, node.dynamicPolySet, renderData.drawManager);
				renderData.stats.totalTriangles += node.polygonSet;
				traverse(node.front, eye, renderData);
				
			}else {
				//fix via tim's recommend
				traverse(node.front, eye, renderData);
				addPolygons(node.polygonSet, node.dynamicPolySet, renderData.drawManager);
				renderData.stats.totalTriangles += node.polygonSet;
				traverse(node.back, eye, renderData);
			}  
		}

	}
}