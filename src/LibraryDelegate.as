package  {
	import mx.rpc.remoting.RemoteObject;
	
	public class LibraryDelegate { 
		
		private var service:RemoteObject;
		private static var instance:LibraryDelegate; 
		 
		public function LibraryDelegate(endpoint:String, source:String) {
			service = new RemoteObject(); 
	    	service.endpoint = endpoint;     
	    	service.destination = "zend";
	    	service.makeObjectsBindable = true;  
	    	service.showBusyCursor = true;   
	    	service.source = source;  
		} 
		
		public function get serv():RemoteObject { 
			return service; 
		}
		
		public static function getInstance(endpoint:String, source:String):LibraryDelegate { 
			if (instance == null) {
				LibraryDelegate.instance = new LibraryDelegate(endpoint, source); 
			}
			return LibraryDelegate.instance;
		}
//-----
	}
}