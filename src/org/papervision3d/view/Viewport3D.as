package org.papervision3d.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.math.Plane3D;
	
	/**
	 * 
	 */ 
	public class Viewport3D extends Sprite
	{
		
		public var cullingRectangle :Rectangle;
		public var sizeRectangle :Rectangle;
		
		private var _containerSprite :Sprite;
		private var _width :Number;
		private var _hWidth :Number;
		private var _height :Number;
		private var _hHeight :Number;
		private var _autoClipping :Boolean;
		private var _autoCulling :Boolean;
		private var _autoScaleToStage :Boolean;
		private var _interactive :Boolean;
		
		/**
		 * 
		 */ 
		public function Viewport3D(viewportWidth:Number = 640, viewportHeight:Number = 480, autoScaleToStage:Boolean = false, 
								   interactive:Boolean = false, autoClipping:Boolean = true, autoCulling:Boolean = true)
		{
			super();
			
			_interactive = interactive;
			_autoScaleToStage = autoScaleToStage;
			_autoCulling = autoCulling;
			_autoClipping = autoClipping;
			
			init();
		}

		/**
		 * 
		 */ 
		protected function init():void
		{
			this.cullingRectangle = new Rectangle();
			this.sizeRectangle = new Rectangle();
			
			_containerSprite = new Sprite();
			
			addChild(_containerSprite);
		
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);	
		}
		
		/**
		 * 
		 */ 
		protected function onAddedToStage(event:Event):void
		{
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize();
		}
		
		/**
		 * 
		 */ 
		protected function onRemovedFromStage(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE, onStageResize);	
		}
		
		/**
		 * 
		 */ 
		protected function onStageResize(event:Event=null):void
		{
			if (_autoScaleToStage)
			{
				this.viewportWidth = stage.stageWidth;
				this.viewportHeight = stage.stageHeight;
			}
		}
		
		/**
		 * 
		 */
		public function get containerSprite():Sprite
		{
			return _containerSprite;
		} 
		
		/**
		 * Width of the <code>Viewport3D</code>
		 */
		public function get viewportWidth():Number
		{
			return _width;
		}

		/**
		 * Sets the the width of the <code>Viewport3D</code>
		 * @param width        A number designating the width of the <code>Viewport3D</code>
		 */
		public function set viewportWidth(width:Number):void
		{
			_width = width;
			_hWidth = width / 2;
			_containerSprite.x = _hWidth;
			
			cullingRectangle.x = -_hWidth;
			cullingRectangle.width = width;
			
			sizeRectangle.width = width;
			if(_autoClipping)
			{
				scrollRect = sizeRectangle;
			}
		}
		
		/**
		 * Height of the <code>Viewport3D</code>
		 */
		public function get viewportHeight():Number
		{
			return _height;
		}
		
		/**
		 * Sets the the height of the <code>Viewport3D</code>
		 * @param height        A number designating the height of the <code>Viewport3D</code>
		 */
		public function set viewportHeight(height:Number):void
		{
			_height = height;
			_hHeight = height / 2;
			_containerSprite.y = _hHeight;
			
			cullingRectangle.y = -_hHeight;
			cullingRectangle.height = height;
			
			sizeRectangle.height = height;
			if(_autoClipping)
			{
				scrollRect = sizeRectangle;
			}
		}
	}
}