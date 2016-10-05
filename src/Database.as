package 
{
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	import flash.data.SQLMode; //if you use SQLMode: CREATE UPDATE READ
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.net.Responder;
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
		
		/************************* USER ******************************/
		
		public function checkUserUser():Boolean {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT new_user FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return Boolean(result[0].new_user);
		}
		
		public function setNewUser(username:String) {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE GameState SET username = @username, new_user = 1";
			sqlStatement.parameters["@username"] = username;
			sqlStatement.execute();
		}
		
		public function getSelectedUser() {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT username FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].username;
		}
		
		public function getCurrentStage () {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT current_stage FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_stage;
		}
		
		public function getCurrentLevel () {
			
		}
		
		public function getCoins ():int {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT current_coin FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_coin;
		}
		
		public function getMaxStar ():int{
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT max_star FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].max_star;
		}
		
		public function getStars ():int {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT current_star FROM GameState";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0].current_star;
		}
		
		public function resetGame():void {
			//Reset User Info
		}
		/************************* END USER *************************/
		
		
		/************************ GAME *******************************/
		
		public function getZombieList () {
			//Available Zombie for Current Level/Current Stage
		}
		
		/************************ END GAME *******************************/
		
		
		/************************ MAP ******************************/
		
		
		public function getLevelStars (stage:int) {
			//Display the current stars of level on selected stage
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT level, stars  FROM Game WHERE stage=@stage";
			sqlStatement.parameters["@stage"] = stage;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result;
		}

		/*********************** END OF MAP ************************/
		
		/********************************* ACHIEVEMENT **************************************/
		
		public function getAchievementList () {
			
		}
		
		/********************************* END OF ACHIEVEMENT **************************************/
		
		
		/********************************* SURVIVOR **************************************/
		
		public function getCurrentGunDamage(gunID:int) {
			//return damage
		}
		
		/********************************* END OF SURVIVOR ************************************/
		
		
		/*****************************************************************************************/
		/********************************* WEAPON SHOP AND UPGRADE SHOP **************************/
		/*****************************************************************************************/
		
		public function getShopItems(category:String, currentPage:int) {
			sqlStatement.clearParameters();
			
			if (category == "Weaponry") {
				sqlStatement.text = "SELECT * FROM WeaponShop WHERE page=@page";
			}
			else if (category == "Character") {
				sqlStatement.text = "SELECT * FROM UpgradeShop WHERE page=@page";
			}
			
			sqlStatement.parameters["@page"] = currentPage;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result;
		}
		
		public function getShopItemsCount(category:String):int {
			sqlStatement.clearParameters();
			if (category == "Weaponry") {
				sqlStatement.text = "SELECT * FROM WeaponShop";
				sqlStatement.execute();
				result = sqlStatement.getResult().data;
			}
			else if (category == "Character") {
				sqlStatement.text = "SELECT * FROM UpgradeShop";
				sqlStatement.execute();
				result = sqlStatement.getResult().data;
			}
			
			return result.length;
		}
		
		//Buy Item Update the current coin
		public function buyShopItem(price:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE GameState SET current_coin = current_coin - @price";
			sqlStatement.parameters["@price"] = price;
			sqlStatement.execute();
		}
		
		/********************************* END OF WEAPON SHOP AND UPGRADE SHOP **************************************/
		
		/*****************************************************************************************/
		/********************************* CHARACTER STATUS **************************************/
		/*****************************************************************************************/
		
		public function getCurrentCharacterStatus () {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT * FROM Character";
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			return result[0];//select only the first row
		}
		
		public function upgradeCharacterStatus(column:String, stats:int) {
			sqlStatement.clearParameters();
			switch (column) 
			{
				case "health":
					sqlStatement.text = "UPDATE Character SET health = @value";
					sqlStatement.parameters["@value"] = stats;
				break;
				case "armor":
					sqlStatement.text = "UPDATE Character SET armor = @value";
					sqlStatement.parameters["@value"] = stats;
				break;
				case "gun_slot":
					sqlStatement.text = "UPDATE Character SET gun_slot = @value";
					sqlStatement.parameters["@value"] = stats;
				break;
				default:
			}
			sqlStatement.execute();
		}
		
		public function updateUpgradeShopLevel(id:int, level:int) {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE UpgradeShop SET level = @level WHERE id = @id";
			sqlStatement.parameters["@id"] = id;
			sqlStatement.parameters["@level"] = level;
			sqlStatement.execute();
		}
		/********************************* END OF CHARACTER STATUS *******************************/
		
		
		/********************************* WEAPONRY **************************************/
		
		public function checkWeaponry (weaponID:int) {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT * FROM Weaponry WHERE  weapon_id=@weaponID";
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			if (result) {
				return result.length;
			}
			else {
				return 0;
			}
		}
		
		public function addToWeaponry (weaponID:int, weaponName:String, bullets:int) {
			sqlStatement.clearParameters();
			sqlStatement.text = "INSERT INTO Weaponry (weapon_id, weapon_name, bullets) VALUES (@weaponID, @weaponName, @bullets)";
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.parameters["@weaponName"] = weaponName;
			sqlStatement.parameters["@bullets"] = bullets;
			sqlStatement.execute();
		}
		
		public function updateBulletsWeaponry (weaponID:int, bullets:int):void {
			sqlStatement.clearParameters();
			sqlStatement.text = "UPDATE Weaponry SET bullets = bullets + @bullets WHERE weapon_id=@weaponID";
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.parameters["@bullets"] = bullets;
			sqlStatement.execute();
		}
		
		public function getCurrentBullet (weaponID:int) {
			sqlStatement.clearParameters();
			sqlStatement.text = "SELECT bullets FROM Weaponry WHERE weapon_id=@weaponID";
			sqlStatement.parameters["@weaponID"] = weaponID;
			sqlStatement.execute();
			result = sqlStatement.getResult().data;
			if (result) {
				return result[0].bullets;
			}
			else {
				return 0;
			}
		}
		
		/********************************* END OF WEAPONRY **************************************/
		
		
		
		/********************************* SETTINGS **************************************/
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
		/********************************* END OF SETTINGS **************************************/
	}
}