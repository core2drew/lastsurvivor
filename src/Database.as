package 
{
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	import flash.data.SQLMode; //if you use SQLMode: CREATE UPDATE READ
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import Game;
	/**
	 * ...
	 * @author Drew Calupe
	 */
	public class Database {
		
		private var dbFile:File = File.applicationDirectory.resolvePath("database.DB")
		private var sqlConn:SQLConnection = new SQLConnection();
		private var sqlStatement:SQLStatement = new SQLStatement();
		private var result:Array;
		
		public function Database () {
			sqlConn.open(dbFile);
			sqlStatement.sqlConnection = sqlConn;
		}
		
		public function getSelectedUser(id:int) {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT username FROM GameState WHERE id=@id";
			sqlStatement.parameters["@id"] = id;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].username;
		}
		
		public function getCurrentStage () {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT current_stage FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_stage;
		}
		
		public function getCurrentLevel () {
			
		}
		
		public function getLevelStars (stage:int) {
			//Display the current stars of level on selected stage
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT level, stars  FROM Game WHERE stage=@stage";
			sqlStatement.parameters["@stage"] = stage;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result;
		}
		
		public function getSelectedUserName() {
			
		}
		
		public function getCurrentAvatar () {
		
		}
		
		public function getCoins ():int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT current_coin FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_coin;
		}
		
		public function getMaxStar ():int{
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT max_star FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].max_star;
		}
		
		public function getStars ():int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT current_star FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_star;
		}
		
		public function getZombieList () {
			//Available Zombie for Current Level/Current Stage
		}
		
		public function getAchievementList () {
			
		}
		
		//Survivor
		public function getCurrentGunDamage(gunID:int) {
			//return damage
		}
		
		//Shop
		public function getShopItems(category:String, currentPage:int) {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT * FROM Shop WHERE category=@category AND page=@page";
			sqlStatement.parameters["@category"] = category;
			sqlStatement.parameters["@page"] = currentPage;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result;
		}
		
		public function getShopItemsCount(category:String):int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT * FROM Shop WHERE category=@category";
			sqlStatement.parameters["@category"] = category;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result.length;
		}
		
		//Buy Item Update the current coin
		public function buyShopItem(price:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE GameState SET current_coin = current_coin - @price WHERE id=@id";
			sqlStatement.parameters["@id"] = Game.UserID;
			sqlStatement.parameters["@price"] = price;
			sqlStatement.execute();
		}
		
		//Sound
		public function getBGSound ():int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT bg_sound FROM Settings";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].bg_sound;
		}
		
		public function updateBGSound (status:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE Settings SET bg_sound=@status";
			sqlStatement.parameters["@status"] = status;
			sqlStatement.execute();
		}
		
		public function getSFX ():int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT sfx FROM Settings";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].sfx;
		}
		
		public function updateSFX (status:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE Settings SET sfx=@status";
			sqlStatement.parameters["@status"] = status;
			sqlStatement.execute();
		}
		
	}
}