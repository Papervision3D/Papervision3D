package org.ascollada.core {
	import flash.errors.IllegalOperationError;	
	
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeSource extends DaeElement {
		use namespace collada;
		
		public var data : Array;
		public var dataType : String;
		public var accessor : DaeAccessor;
		public var channels : Array;
		
		/**
		 * 
		 */
		public function DaeSource(document : DaeDocument, element : XML = null) {
			super(document, element);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			this.data = null;
			this.dataType = null;
			if(this.accessor) {
				this.accessor.destroy();
				this.accessor = null;
			}
			this.channels = null;
		}

		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.dataType = "float_array";
			
			var list : XMLList = element[this.dataType];
			
			// read in the raw data
			if(list.length()) {
				this.data = readStringArray(list[0]);
			} else {
				this.dataType = "Name_array";
				list = element[this.dataType];
				if(list.length()) {
					this.data = readStringArray(list[0]);
				} else {
					this.dataType = "IDREF_array";
					list = element[this.dataType];
					if(list.length()) {
						this.data = readStringArray(list[0]);
					} else {
						this.dataType = "int_array";
						list = element[this.dataType];
						if(list.length()) {
							this.data = readStringArray(list[0]);
						} else {
							this.dataType = "bool_array";
							list = element[this.dataType];
							if(list.length()) {
								this.data = readStringArray(list[0]);
							} else {
								throw new IllegalOperationError("DaeSource : no data found!");
							}
						}
					}
				}
			}
			
			// read the accessor
			if(element..accessor[0]) {
				this.accessor = new DaeAccessor(this.document, element..accessor[0]);
			} else {
				throw new Error("[DaeSource] could not find an accessor!");
			}
			
			// interleave data
			var tmp :Array = new Array();
			for(var i:int = 0; i < this.accessor.count; i++)
			{
				var arr :Array = readValue(i);
				if(arr.length > 1)
					tmp.push(arr);
				else
					tmp.push(arr[0]);
			}
			this.data = tmp;
		}
		
		/**
		 * 
		 */ 
		private function readValue(index:int, forceType:Boolean=true):Array
		{
			var values :Array = new Array();
			var data :Array = this.data;
			var stride :int = this.accessor.stride;
			var type :String = this.dataType;
			var start :int = index * stride;
			var value :String;
			var i :int;
			
			for(i = 0; i < stride; i++)
			{
				value = data[start + i];
				if(forceType && (type == "bool_array" || type == "float_array" || type == "int_array"))
				{
					if(type == "float_array")
					{
						if(value.indexOf(",") != -1) 
						{
							value = value.replace(/,/, ".");
						}
						values.push(parseFloat(value));
					}
					else if(type == "bool_array")
					{
						values.push((value == "true" || value == "1" ? true : false));
					}
					else
					{
						values.push(parseInt(value, 10));
					}
				}
				else
				{
					values.push(value);	
				}
			}
			
			return values;
		}
	}
}
