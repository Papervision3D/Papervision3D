package org.ascollada.core {
	import flash.display.Bitmap;	
	import flash.display.Loader;
	import flash.display.LoaderInfo;	
	import flash.events.Event;	
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;	
	import flash.utils.Dictionary;
	import flash.utils.Timer;	
	
	import org.ascollada.fx.*;	
	import org.ascollada.core.ns.collada;

	/**
	 * @author Tim Knip / floorplanner.com
	 */
	public class DaeDocument extends DaeElement {
		use namespace collada;
		
		/** */
		public static var DEFAULT_PARSE_SPEED : uint = 1;
		
		/** */
		public var COLLADA : XML;
		
		/** */
		public var scene : DaeNode;

		/** */
		public var animations : Dictionary;
		
		/** */
		public var animationClips : Dictionary;
		
		/** */
		public var animatables : Dictionary;
		
		/** */
		public var controllers : Dictionary;
		
		/** */
		public var images : Dictionary;
		
		/** */
		public var sources : Dictionary;
		
		/** */
		public var geometries : Dictionary;
		
		/** */
		public var materials : Dictionary;
		
		/** */
		public var effects : Dictionary;
		
		private var _elementQueue : Vector.<XML>;
		private var _imageQueue : Vector.<DaeImage>;
		private var _loadingImage : DaeImage;
		private var _fileSearchPaths : Vector.<String>;
		private var _searchPathIndex : int;
		private var _parseSpeed : int;
		
		/**
		 * Constructor.
		 */
		public function DaeDocument(parseSpeed : int=-1) {
			super(this, null);
			
			_fileSearchPaths = Vector.<String>([
				"testData",
				".",
				"..",
				"images",
				"image",
				"textures",
				"texture",
				"assets"
			]);
			
			_parseSpeed = parseSpeed > 0 ? parseSpeed : DEFAULT_PARSE_SPEED;
		}

		/**
		 * 
		 */
		public function addFileSearchPath(path : String) : void {
			path = path.split("\\").join("/");
			if(path.charAt(path.length-1) == "/") {
				path = path.substr(0, path.length-1);
			}
			_fileSearchPaths.unshift(path);
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			
			var element : DaeElement;
			
			if(this.images) {
				for each(element in this.images) {
					element.destroy();
					element = null;
				}
				this.images = null;
			}
			
			if(this.sources) {
				for each(element in this.sources) {
					element.destroy();
					element = null;
				}
				this.sources = null;
			}
			
			if(this.materials) {
				for each(element in this.materials) {
					element.destroy();
					element = null;
				}
				this.materials = null;
			}
			
			if(this.effects) {
				for each(element in this.effects) {
					element.destroy();
					element = null;
				}
				this.effects = null;
			}
			
			if(this.geometries) {
				for each(element in this.geometries) {
					element.destroy();
					element = null;
				}
				this.geometries = null;
			}
			
			if(this.scene) {
				this.scene.destroy();
				this.scene = null;
			}
			
			this.animatables = null;
			
			this.COLLADA = null;
		}

		/**
		 * 
		 */
		public function getNodeByID(id : String, parent : DaeNode = null) : DaeNode {
			var child : DaeNode;
			
			parent = parent || this.scene;
			
			if(parent.id == id) {
				return parent;
			}
			
			for each(child in parent.nodes) {
				var node : DaeNode = getNodeByID(id, child);
				if(node) {
					return node;	
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 */
		public function getNodeByName(name : String, parent : DaeNode = null) : DaeNode {
			var child : DaeNode;
			
			parent = parent || this.scene;
			
			if(parent.name == name) {
				return parent;
			}
			
			for each(child in parent.nodes) {
				var node : DaeNode = getNodeByName(name, child);
				if(node) {
					return node;	
				}
			}
			
			return null;
		}

		/**
		 * 
		 */
		public function getNodeBySID(sid : String, parent : DaeNode = null) : DaeNode {
			var child : DaeNode;
			
			parent = parent || this.scene;
			
			if(parent.sid == sid) {
				return parent;
			}
			
			for each(child in parent.nodes) {
				var node : DaeNode = getNodeBySID(sid, child);
				if(node) {
					return node;	
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 */
		override public function read(element : XML) : void {
			super.read(element);
			
			this.COLLADA = element;
			
			readLibraryImages();
		}
		
		/**
		 * 
		 */
		private function readAnimation(animation : DaeAnimation) : void {
			var child : DaeAnimation;
			var channel : DaeChannel;
			
			if(animation.channels) {
				for each(channel in animation.channels) {
					readAnimationChannel(channel);
				}
			}
			
			if(animation.animations) {
				for each(child in animation.animations) {
					readAnimation(child);
				}
			}
		}
		
		/**
		 * 
		 */
		private function readAnimationChannel(channel : DaeChannel) : void {
			
			var target : String = channel.targetID;
			var node : DaeNode = getNodeByID(target);
			
			if(node) {
				node.channels = node.channels || new Array();
				node.channels.push(channel);
			} else {
				var source : DaeSource = this.sources[target];
				if(source) {
					source.channels = source.channels || new Array();
					source.channels.push(channel);
				} else {
					trace("[DaeDocument#readAnimationChannel] : could not find target for animation channel! " + target + " " + source);
				}
			}
		}

		/**
		 * 
		 */
		private function readLibraryAnimations() : void {
			var list : XMLList = this.COLLADA..library_animations.animation;
			var element : XML;
			var animation : DaeAnimation;
			
			this.animatables = new Dictionary(true);
			this.animations = new Dictionary(true);
			
			for each(element in list) {
				animation= new DaeAnimation(this, element);
				this.animations[animation.id] = animation;
				readAnimation(animation);
			}
		}
		
		/**
		 * 
		 */
		private function readLibraryAnimationClips() : void {
			var list : XMLList = this.COLLADA..library_animation_clips.animation_clip;
			var element : XML;
			var clip : DaeAnimationClip;
			
			this.animationClips = new Dictionary(true);
			
			for each(element in list) {
				clip = new DaeAnimationClip(this, element);
				this.animationClips[clip.id] = clip;
				trace(clip.id + " " + clip.instances.length);
			}
		}
		
		/**
		 * 
		 */
		private function readLibraryControllers() : void {
			var list : XMLList = this.COLLADA..library_controllers.controller;
			var element : XML;
			
			this.controllers = new Dictionary(true);
			for each(element in list) {
				var controller : DaeController = new DaeController(this, element);
				this.controllers[controller.id] = controller;
			}
		}
		
		/**
		 * 
		 */
		private function readLibraryEffects() : void {
			var list : XMLList = this.COLLADA..library_effects.effect;
			var element : XML;
			
			this.effects = new Dictionary(true);
			for each(element in list) {
				var effect : DaeEffect = new DaeEffect(this, element);
				this.effects[effect.id] = effect;
			}
		}
		
		/**
		 * 
		 */
		private function readLibraryGeometries() : void {
			var list : XMLList = this.COLLADA..library_geometries.geometry;
			var element : XML;
			
			this.geometries = new Dictionary(true);
			for each(element in list) {
				var geometry : DaeGeometry = new DaeGeometry(this, element);
				this.geometries[geometry.id] = geometry;
			}
		}
		
		/**
		 * 
		 */
		private function readLibraryImages() : void {
			var list : XMLList = this.COLLADA..library_images.image;
			var element : XML;
			
			this.images = new Dictionary(true);
			
			_imageQueue = new Vector.<DaeImage>();
			
			for each(element in list) {
				var image : DaeImage = new DaeImage(this, element);
				
				this.images[ image.id ] = image;
				
				_imageQueue.push(image);
			}
			
			readNextImage();
		}
		
		/**
		 * 
		 */
		private function readLibraryMaterials() : void {
			var list : XMLList = this.COLLADA..library_materials.material;
			var element : XML;
			
			this.materials = new Dictionary(true);
			for each(element in list) {
				var material : DaeMaterial = new DaeMaterial(this, element);
				this.materials[material.id] = material;
			}
		}
		
		private function readImage(image : DaeImage) : void {
			var url : String = image.init_from;
			var loader : Loader = new Loader();
				
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);

			if(_searchPathIndex >= 0) {
				url = url.split("\\").join("/");
				var parts : Array = url.split("/");
				url = parts.pop() as String;
				url = _fileSearchPaths[_searchPathIndex] + "/" + url;
			}
			
			loader.load(new URLRequest(url));
		}

		/**
		 * 
		 */
		private function readNextImage(event : Event=null) : void {
			if(_imageQueue.length) {
				_loadingImage = _imageQueue.pop();
				_searchPathIndex = -1;
				readImage(_loadingImage);
			} else {
				readSources();
			}
		}
		
		/**
		 * 
		 */
		private function readNextSource(event : TimerEvent) : void {
			var timer : Timer = event.target as Timer;
			
			if(_elementQueue.length) {
				var element : XML = _elementQueue.pop();
				var source : DaeSource = new DaeSource(this, element);
				
				this.sources[ source.id ] = source;
				//trace(source.id + " " + this.sources[ source.id ] );
				timer.start();
			} else {
				
				readLibraryMaterials();
				readLibraryEffects();
				readLibraryControllers();
				readLibraryGeometries();
				readScene();
				
				readLibraryAnimations();
				readLibraryAnimationClips();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * 
		 */
		private function readScene() : void {
			var list : XMLList = this.COLLADA["scene"];
			
			if(list.length()) {
				var s : DaeScene = new DaeScene(this, list[0]);
				
				list = this.COLLADA..visual_scene.(@id == s.url);
				if(list.length()) {
					this.scene = new DaeNode(this, list[0]);
				}
			} else {
				trace("Could not find any scene!");
			}
		}

		/**
		 * 
		 */
		private function readSources() : void {
			this.sources = new Dictionary(true);
			
			_elementQueue = new Vector.<XML>();	
			
			// parse all <source> elements which have an @id attribute
			var list :XMLList = this.COLLADA..source.(hasOwnProperty("@id"));
			for each(var element:XML in list) {
				_elementQueue.push(element);
			}
			
			var timer : Timer = new Timer(10, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, readNextSource);
			timer.start();
		}
		
		private function onImageLoadComplete(event : Event) : void {
			var loaderInfo : LoaderInfo = event.target as LoaderInfo;
			if(loaderInfo.content is Bitmap) {
				var bitmap : Bitmap = loaderInfo.content as Bitmap;
				
				_loadingImage.bitmapData = bitmap.bitmapData;
			}
			readNextImage();
		}
		
		private function onImageLoadError(event : IOErrorEvent) : void {
			_searchPathIndex++;
			if(_searchPathIndex < _fileSearchPaths.length) {
				readImage(_loadingImage);
			} else {
				readNextImage();
			}
		}
		
		public function set parseSpeed(value : uint) : void {
			_parseSpeed = value;
		}
		
		public function get parseSpeed() : uint {
			return _parseSpeed;
		}
	}
}
