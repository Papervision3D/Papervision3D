package org.papervision3d.core.render.clipping
{
	public class ClipFlags
	{
		public static const NONE 	:int = 0;
		public static const NEAR 	:int = 1;
		public static const FAR 	:int = 2;
		public static const LEFT 	:int = 4;
		public static const RIGHT 	:int = 8;
		public static const TOP 	:int = 16;
		public static const BOTTOM	:int = 32;
		public static const ALL		:int = 1+2+4+8+16+32;
	}
}