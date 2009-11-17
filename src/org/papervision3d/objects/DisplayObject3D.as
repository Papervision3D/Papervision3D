package org.papervision3d.objects
{
	import org.papervision3d.core.controller.AbstractController;
	import org.papervision3d.core.controller.AnimationController;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.core.render.object.ObjectRenderer;
	import org.papervision3d.materials.AbstractMaterial;
	
	/**
	 * 
	 */ 
	public class DisplayObject3D extends DisplayObjectContainer3D
	{
		/**
		 * 
		 */
		public var material:AbstractMaterial;
		
		/**
		 * 
		 */
		public var renderer:ObjectRenderer;
		
		/**
		 * 
		 */
		public var controllers :Vector.<AbstractController>;
		
		/**
		 * 
		 */
		public var animation :AnimationController;
		
		/**
		 * 
		 */
		public var skin :Boolean;
		  
		/**
		 * 
		 */  
		public function DisplayObject3D(name:String=null)
		{
			super(name);
			
			this.renderer = new ObjectRenderer(this);
			this.controllers = new Vector.<AbstractController>();
		}
	}
}