package 
{
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	import flash.data.SQLMode; //if you use SQLMode: CREATE UPDATE READ
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.errors.SQLError;
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
			sqlStatement.text = "SELECT username FROM GameState WHERE id=" + id;
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
			sqlStatement.text = "SELECT level, stars  FROM Game WHERE stage=" + stage;
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