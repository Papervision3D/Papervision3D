package org.ascollada.fx
{
	import flash.errors.IllegalOperationError;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.core.DaeElement;
	import org.ascollada.core.ns.collada;
	
	public class DaeColor extends DaeElement
	{
		use namespace collada;
		
		public var r :Number;
		public var g :Number;
		public var b :Number;
		public var a :Number;
		
		/**
		 * 
		 */ 
		public function DaeColor(document:DaeDocument, element:XML=null)
		{
			super(document, element);
		}
		
		/**
		 * 
		 */ 
		public override function read(element:XML):void
		{
			super.read(element);
			
			var data :Array = readStringArray(element);
			var i :int;
			
			if(data.length >= 3)
			{
				for(i = 0; i < data.length; i++)
				{
					data[i] = data[i].replace(/,/, ".");
				}
				this.r = parseFloat(data[0]);
				this.g = parseFloat(data[1]);
				this.b = parseFloat(data[2]);
				this.a = data.length > 3 ? parseFloat(data[3]) : 1.0;
			}
			else
			{
				throw new IllegalOperationError("Invalid color: " + element);	
			}
		}
	}
}