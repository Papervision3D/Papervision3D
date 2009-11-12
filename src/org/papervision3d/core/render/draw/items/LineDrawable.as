package org.papervision3d.core.render.draw.items
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.IGraphicsData;
	
	public class LineDrawable extends AbstractDrawable
	{
		public var x0 :Number;
		public var y0 :Number;
		public var x1 :Number;
		public var y1 :Number;
		
		private var _path :GraphicsPath;
		
		public function LineDrawable()
		{
			super();
			
			_path = new GraphicsPath();
			_path.commands = new Vector.<int>();
			_path.data = new Vector.<Number>();
			
			_path.commands.push( GraphicsPathCommand.MOVE_TO );
			_path.commands.push( GraphicsPathCommand.LINE_TO );
			_path.data.push(0, 0, 0, 0);
		}
		
		public override function toViewportSpace(hw:Number, hh:Number):void{
			x0 *= hw;	
			y0 *= hh;
			x1 *= hw;
			y1 *= hh;
		}
		
		public override function get path():IGraphicsData
		{
			_path.data[0] = x0;
			_path.data[1] = y0;
			_path.data[2] = x1;
			_path.data[3] = y1;
			return _path;
		}
	}
}