import java.sql.SQLException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DriverManager;

public class HiveCreateDb {
   private static String driverName = "org.apache.hadoop.hive.jdbc.HiveDriver";
   
   public static void main(String[] args) throws SQLException {
      // Register driver and create driver instance
   
      Class.forName(driverName);
      // get connection
      
      Connection con = DriverManager.getConnection("jdbc:hive2://quickstart.cloudera:10000/default", "", "");
      Statement stmt = con.createStatement();
      
      stmt.executeQuery("CREATE DATABASE Ndb");
      System.out.println("Database Ndb created successfully.");
      
      con.close();
   }
}
