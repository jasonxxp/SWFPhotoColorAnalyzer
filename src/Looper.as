package  {
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	分段执行长循环, 避免运行超时
	
	例子:
	_looper = new Looper(w, h, 200, 10);
	_looper.addEventListener(Looper.EVT_STEP, function(evt:Event):void{
		...
		
		for (i=lStart.x; i<lEnd.x; i+=1){ //精度
			for (j=lStart.y; j<lEnd.y; j+=1){
				...
			}
		}
	});
	_looper.addEventListener(Looper.EVT_END, function(evt:Event):void{
		trace('ok, total:', _looper.total);
		
		...
	});
	_looper.run();
	*/
	public class Looper extends EventDispatcher {
		
		static public const EVT_STEP:String = 'step';
		static public const EVT_END:String = 'end';
		static public const EVT_BREAK:String = 'break';
		//static public const EVT_LOOP:String = 'loop';
		
		private var _w:uint;
		private var _h:uint;
		private var _step:uint;
		private var _to:uint;
		private var _toRef:uint;
		private var _flagX:uint;
		private var _flagY:uint;
		private var _count:Number;
		private var _start:Point;
		private var _end:Point;
		private var _enable:Boolean;

		public function Looper(width:uint, height:uint, step:uint = 50, timeout:uint = 200) {
			
			_reset();
			_w = width;
			_h = height;
			_step = step;
			_to = timeout;
		}
	
		public function run():void
		{
			_enable = true;
			_reset();
			_loop();
		}
		
		public function stop():void
		{
			_enable = false;
			clearTimeout(_toRef);
		}
		
		public function get loopStart():Point
		{
			return _start;
		}
		
		public function get loopEnd():Point
		{
			return _end;
		}
		
		public function get loaded():Number
		{
			return _count;
		}
		
		public function get total():Number
		{
			return _w*_h;
		}
		
		public function get progress():Number
		{
			return this.loaded/this.total;
		}
		
		private function _reset():void
		{
			_count = 0;
			_flagX = 0;
			_flagY = 0;
			_start = new Point;
			_end = new Point;
		}
		
		private function _loop():void
		{
			if (!_enable){
				_reset();
				clearTimeout(_toRef);
				this.dispatchEvent(new Event(EVT_BREAK));
				return;
			}
			
			var sX:Number = _flagX * _step;
			var eX:Number = (_flagX+1) * _step;
			
			var sY:Number = _flagY * _step;
			var eY:Number = (_flagY+1) * _step;
			
			if ( (_flagX+1)*_step >= _w && (_flagY+1)*_step >= _h ){
				if (eX >= _w) {
					eX = _w;
				}
				if (eY >= _h) {
					eY = _h;
				}
				
				_do(sX, sY, eX, eY, true);
				//setTimeout(_do, _to, sX, sY, eX, eY, true);
			}else{
				_flagY++;
				
				if (eX >= _w) {
					eX = _w;
				}
				if (eY >= _h) {
					eY = _h;
					_flagX++;
					_flagY = 0;
				}
			
				_do(sX, sY, eX, eY, false);
				//setTimeout(_do, _to, sX, sY, eX, eY, false);
			}
		}
		
		private function _do(sX:Number, sY:Number, eX:Number, eY:Number, isEnd:Boolean):void
		{
			//trace(sX, sY, eX, eY);
			_start.x = sX;
			_start.y = sY;
			_end.x = eX;
			_end.y = eY;
			
			this.dispatchEvent(new Event(EVT_STEP));
			
			//for (var i:Number = sX;i<eX;i++)
//				for (var j:Number = sY;j<eY;j++){
//					_count++;
//					this.dispatchEvent(new Event(EVT_LOOP));
//				}
			_count += (eX-sX) * (eY-sY);
					
			if (isEnd)
			{
				this.dispatchEvent(new Event(EVT_END));
				
			}else{
				//_loop();
				_toRef = setTimeout(_loop, _to);
			}
		}


	}	
}
