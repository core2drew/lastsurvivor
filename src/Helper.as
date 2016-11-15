package  
{
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Helper 
	{
		
		public function Helper() {
			
		}
		
		//Currency Format
		public static function formatCost (v:String, decimal_places:int = 2, currency_symbol:String = "", placement:int = 0) {
			v = String(Number(v).toFixed(decimal_places));
			var result:String = new String();
			if(decimal_places == 0){
			}else{
				result = v.substr(-1-decimal_places);
				v = v.substr(0, v.length-1-decimal_places);
			}
			while( v.length > 3 ){
				result = "," + v.substr(-3) + result;
				v = v.substr(0, v.length-3);
			}
			if(v.length > 0){
				if(placement == 0){
					result = currency_symbol + " " + v + result;
				}else if(placement == 1){
					result = v + result + " " + currency_symbol;
				}else{
					result = v + result;
				}
			}
			return result;
		}
		
		/* The randomRange function */
		public static function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
	}

}