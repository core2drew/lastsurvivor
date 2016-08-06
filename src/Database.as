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
		
		
		
		/********************************* ACHIEVEMENT **************************************/
		
		public function getAchievementList () {
			
		}
		
		/********************************* END OF ACHIEVEMENT **************************************/
		
		
		/********************************* SURVIVOR **************************************/
		
		public function getCurrentGunDamage(gunID:int) {
			//return damage
		}
		
		/********************************* END OF SURVIVOR **************************************/
		
		
		
		/********************************* SHOP **************************************/
		
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
		public function buyShopItem(price:int, userID:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE GameState SET current_coin = current_coin - @price WHERE id=@id";
			sqlStatement.parameters["@id"] = userID;
			sqlStatement.parameters["@price"] = price;
			sqlStatement.execute();
		}
		
		/********************************* END OF SHOP **************************************/
		
		
		
		/********************************* WEAPONRY **************************************/
		
		public function checkWeaponry (userID:int, weaponID:int) {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT * FROM Weaponry WHERE user_id=@userID AND weapon_id=@weaponID";
			sqlStatement.parameters["@userID"] = userID;
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result.length;
		}
		
		public function addToWeaponry (userID:int, weaponID:int, weaponName:String, bullets:int) {
			sqlStatement.clearParameters()
			sqlStatement.text = "INSERT INTO Weaponry (user_id, weapon_id, weapon_name, bullets) VALUES (@userID, @weaponID, @weaponName, @bullets)";
			sqlStatement.parameters["@userID"] = userID;
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.parameters["@weaponName"] = weaponName;
			sqlStatement.parameters["@bullets"] = bullets;
			sqlStatement.execute();
		}
		
		public function updateBulletsWeaponry (userID:int, weaponID:int, bullets:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE Weaponry SET bullets = bullets + @bullets WHERE user_id=@userID AND weapon_id=@weaponID";
			sqlStatement.parameters["@userID"] = userID;
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.parameters["@bullets"] = bullets;
			sqlStatement.execute();
		}
		
		public function getCurrentBullet (userID:int, weaponID:int):int {
			sqlStatement.clearParameters()
			sqlStatement.text = "SELECT bullets FROM Weaponry WHERE user_id=@userID AND weapon_id=@weaponID";
			sqlStatement.parameters["@userID"] = userID;
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].bullets;
		}
		
		/********************************* END OF WEAPONRY **************************************/
		
		
		
		/********************************* SOUND **************************************/
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
		/********************************* END OF SOUND **************************************/
	}
}