package components {
	import mx.validators.ValidationResult;
	import mx.validators.Validator; 

	public class MatchValidator extends Validator {
		private var _matchSource:Object = null; 
		private var _matchProperty:String = null;
	    private var _noMatchError:String = "Fields did not match";

	    [Inspectable(category="General", defaultValue="Fields did not match")]
	    public function set noMatchError( argError:String):void{
		     _noMatchError = argError;
	    }
	    public function get noMatchError():String{
	         return _noMatchError;
	    }
 
	    [Inspectable(category="General", defaultValue="null")]
	    public function set matchSource( argObject:Object):void{
	         _matchSource = argObject;
	    }
	    public function get matchSource():Object{
			 return _matchSource;
	    }

	    [Inspectable(category="General", defaultValue="null")]
	    public function set matchProperty( argProperty:String):void{
			_matchProperty = argProperty;
	    }
	    public function get matchProperty():String{
			return _matchProperty;
	    }

		override protected function doValidation(value:Object):Array {
		    var results:Array = super.doValidation(value.pass);

		    var val:String = value.pass ? String(value.pass) : "";
		    if (results.length > 0 || ((value.toMatch == "") && !required)) return results;
		    else {   
				if(val != value.toMatch){ 
					results.length = 0;
					results.push( new ValidationResult(true,null,"mismatch",_noMatchError));
					return results;
				}
				else return results;
		   }
		}  

		override protected function getValueFromSource():Object {
			var value:Object = {};
			value.pass = super.getValueFromSource();
 
			if (_matchSource && _matchProperty)
				 value.toMatch = _matchSource[_matchProperty];
			else value.toMatch = null; 
			return value;
		}
//-----	  
	}
}