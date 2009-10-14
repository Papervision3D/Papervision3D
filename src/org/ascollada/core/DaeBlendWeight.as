package org.ascollada.core {

	public class DaeBlendWeight {
		public var vertexIndex :int;
		public var joint :String;
		public var weight :Number;
		
		public function DaeBlendWeight(vertex:int=-1, joint:String=null, weight:Number=0.0) {
			this.vertexIndex = vertex;
			this.joint = joint;
			this.weight = weight;
		}
	}
}
