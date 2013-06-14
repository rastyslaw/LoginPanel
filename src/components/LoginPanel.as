package components {
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import mx.validators.EmailValidator;
	
	import mx.events.ValidationResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.controls.Alert;
	import mx.validators.StringValidator;
	
	import spark.components.Button;
	import spark.components.SkinnableContainer;
	import spark.components.TextInput;
	
	import vo.VOlogin;
	import components.MatchValidator;  
	/** 
	 * ...
	 * @author waltasar
	 */  
	[SkinState("login")]
	[SkinState("register")] 
	[SkinState("lost")] 
	
	public class LoginPanel extends SkinnableContainer { 
		[SkinPart] 
		public var username:TextInput;
		
		[SkinPart] 
		public var password:TextInput; 
		 
		[SkinPart]  
		public var confirm:TextInput; 
		
		[SkinPart] 
		public var loginButton:Button;
		
		[SkinPart] 
		public var noregister:Button; 
		
		[SkinPart(required="false")] 
		public var email:TextInput;  
		
		[SkinPart(required="false")] 
		public var lost:Button;
		
		private var _maxLen:int = 12;
		private var _minLenUser:int = 3; 
		private var _minLenPas:int = 4;
		
		private var _login:String = "login"; 
		private var delegate:LibraryDelegate;
		private var service:RemoteObject; 
		private var _endpoint:String;
		private var _source:String;
		
		private var userVal:StringValidator = new StringValidator;
		private var passVal:StringValidator = new StringValidator;
		private var passMatch:MatchValidator = new MatchValidator;
		private var emailVal:EmailValidator = new EmailValidator;
			  
		private var valpas:Boolean;   
		private var valuser:Boolean;
		
		private var _icon:Class;
		
		override protected function getCurrentSkinState():String {
			return login;  
		}
		
		public function validateEmail():Boolean {
				if (email==null) return true;
				var result:ValidationResultEvent;
				emailVal.source = email; 
				emailVal.required = false;
				emailVal.property = "text"; 
				emailVal.invalidCharError = "You've got some funky characters." ;
				
				result = emailVal.validate();
				if (result.type == "invalid") {
					return false;
				}
				else return true; 
		}
		
		public function validateUser():void { 
				var result:ValidationResultEvent;
				userVal.source = username;
				userVal.required = false;
				userVal.property = "text";
				userVal.maxLength = maxLen; 
				userVal.minLength = minLenUser; 
				userVal.tooLongError = "Username must be less than " + maxLen + " characters long.";
				userVal.tooShortError = "Username must be at least " + minLenUser + " characters long." ;
				
				result = userVal.validate();
				if (result.type == "invalid") {
					valuser = false; 
				}
				else valuser = true;
		} 
		
		public function validatePass():void {
				var result:ValidationResultEvent;
				passVal.source = password; 
				passVal.property = "text";
				passVal.required = false; 
				passVal.maxLength = maxLen;  
				passVal.minLength = minLenPas;    
				passVal.tooLongError = "Password must be less than " + maxLen + " characters long.";
				passVal.tooShortError = "Password must be at least " + minLenPas + " characters long." ;
				 
				result = passVal.validate(); 
				if (result.type == "invalid") {
					valpas = false;  
				}  
				else valpas = true;
		} 
		 
		private function validateMatch():Boolean { 
			if (login != "register") return true;  
			var result:ValidationResultEvent; 
			passMatch.source = confirm; 
			passMatch.required = false; 
			passMatch.property = "text"; 
			passMatch.matchSource = password;
			passMatch.matchProperty = "text";   
			passMatch.noMatchError = "Passwords do not match";  
			
			result = passMatch.validate();
			if (result.type == "invalid") {
				return false; 
			}
			else return true;      
		}
		
		override protected function partAdded(name:String, instance:Object):void {
			super.partAdded(name, instance);
			if (instance == loginButton) {
				loginButton.addEventListener(MouseEvent.CLICK, buttonClick);
				addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
				focusManager.setFocus(loginButton); 
			} 
			else if (instance == noregister) { 
				noregister.addEventListener(MouseEvent.CLICK, noregisterClick);
			}
			else if (instance == lost) { 
				lost.addEventListener(MouseEvent.CLICK, lostClick);
			}
 		}
		 
		override protected function partRemoved(name:String, instance:Object):void {
			super.partRemoved(name, instance);
			if (instance == loginButton) {
				loginButton.removeEventListener(MouseEvent.CLICK, buttonClick);
				removeEventListener(KeyboardEvent.KEY_DOWN, keyPress); 
			}  
			else if (instance == noregister) { 
				noregister.removeEventListener(MouseEvent.CLICK, noregisterClick);
			}
			else if (instance == lost) {  
				lost.removeEventListener(MouseEvent.CLICK, lostClick);
			}
 		} 
		
		private function keyPress(event:KeyboardEvent):void {
			if (event.keyCode == 13) buttonClick();  
		}
		 
		private function buttonClick(event:MouseEvent = null):void { 
			if (_endpoint == null) {
				Alert.show("Unknown endpoint.", "Warning", 4, this, null, icon);
				return;  
			} 
			if(login == "lost" && validateEmail()) sendNow(email.text);   
			else { 
				if (!valpas || !valuser || !validateMatch()) return; 
				if (email && !validateEmail()) return; 
				var obj:VOlogin = new VOlogin();
				obj.password = password.text;     
				obj.username = username.text; 
				if (email) obj.email = email.text;
				if (login == "login") loginNow(obj);
					else registerNow(obj);  
			}
		} 
		
		private function noregisterClick(event:MouseEvent):void {
			password.text = username.text = "";
			password.errorString = username.errorString = "";
			if (login == "register") { 
				confirm.text = "";
				if(email!=null) email.text = "";  
				login = "login";  
			} 
			else if (login == "lost") {  
				email.text = "";  
				login = "login"; 
			} 
			else login = "register"; 
		} 
		 
		private function lostClick(event:MouseEvent):void {
			password.text = username.text = "";
			password.errorString = username.errorString = "";
			login = "lost";    
		}

		public function sendNow(s:String):void {
			delegate = LibraryDelegate.getInstance(_endpoint, _source);  
			service = delegate.serv; 
			var call:* = service.GetPass(s);         
			service.addEventListener("result", result_send);     
			service.addEventListener("fault", fault);  
		}
		
		public function loginNow(obj:VOlogin):void {
			delegate = LibraryDelegate.getInstance(_endpoint, _source);  
			service = delegate.serv;
			var call:* = service.loginUser(obj);       
			service.addEventListener("result", result_log);     
			service.addEventListener("fault", fault);  
		}
		
		public function registerNow(obj:VOlogin):void { 
			delegate = LibraryDelegate.getInstance(_endpoint, _source);  
			service = delegate.serv;
			var call:* = service.registrateUser(obj);       
			service.addEventListener("result", result_reg);     
			service.addEventListener("fault", fault);  
		} 
		 
		private function result_send(event:ResultEvent):void {
			service.removeEventListener("result", result_send); 
			if (!event.result) Alert.show("Wrong email.", "Warning", 4, this, null, icon);
				else Alert.show("Your password - '"+event.result+"'", "Information", 4, this, null, icon); 
		}
		 
		private function result_log(event:ResultEvent):void { 
			service.removeEventListener("result", result_log);
			if (event.result) Alert.show("Successfully login.", "Information", 4, this, null, icon);
				else Alert.show("Wrong username or password.", "Warning", 4, this, null, icon);
		}
		 
		private function result_reg(event:ResultEvent):void { 
			service.removeEventListener("result", result_reg);
			if (event.result) Alert.show("Successfully register.", "Information", 4, this, null, icon);  
				else Alert.show("Username "+ username.text +" already exists.", "Warning", 4, this, null, icon);
		} 
		
		private function fault(event:FaultEvent):void {
			Alert.show(event.fault.message, "Error", 4, this, null, icon);
		}
		  
		[Bindable][Inspectable(category="Common", enumeration="login, register, lost", defaultValue="login", type="String")]  
		public function get login():String { return _login; }  
		 
		public function set login(value:String):void {
			_login = value;  
			invalidateSkinState();
			invalidateProperties();
		}
		 
		public function get endpoint():String { return _endpoint; }
		public function set endpoint(value:String):void { _endpoint = value;  }
		
		public function get source():String { return _source; }
		public function set source(value:String):void { _source = value; }
		
		public function get maxLen():int { return _maxLen; }
		public function set maxLen(value:int):void { _maxLen = value; }
		 
		public function get minLenUser():int { return _minLenUser; }
		public function set minLenUser(value:int):void { _minLenUser = value; } 
		
		public function get minLenPas():int { return _minLenPas; }
		public function set minLenPas(value:int):void { _minLenPas = value; }

		public function get icon():Class { return _icon; }
		public function set icon(value:Class):void { _icon = value; }

//-----		
	}
}