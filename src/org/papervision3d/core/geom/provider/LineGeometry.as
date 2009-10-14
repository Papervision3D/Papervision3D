package org.papervision3d.core.geom.provider
{
	import org.papervision3d.core.geom.Line;
	
	/**
	 * 
	 */ 
	public class LineGeometry extends VertexGeometry
	{
		public var lines :Vector.<Line>;
		 
		/**
		 * 
		 */ 
		public function LineGeometry(name:String=null)
		{
			super(name);
			this.lines = new Vector.<Line>();
		}
		
		/**
		 * 
		 */ 
		public function addLine(line:Line, addVertices:Boolean=true):Line
		{
			var index :int = lines.indexOf(line);
			
			if (index < 0)
			{
				if (addVertices)
				{
					line.v0 = addVertex(line.v0);
					line.v1 = addVertex(line.v1);
					if (line.cv0)
					{
						line.cv0 = addVertex(line.cv0);
					}
				}
				lines.push(line);
				return line;	
			}
			else
			{
				return lines[index];	
			}
		}
	}
}