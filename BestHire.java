import java.util.Scanner;
import java.sql.*;

public class BestHire{

	static Scanner input = new Scanner(System.in);
	static int pos_code;
	static String q1;
	static String q2;

	public static void main(String[] args){

		setQueries();


		System.out.println("Enter pos_code: ");
        pos_code = input.nextInt();


        System.out.println("\nQualified people: \n");
        runQuery(q1);

        System.out.println();

        System.out.println("People who miss the least number of skills: \n");
        runQuery(q2);


	}

	public static void runQuery(String query){
		try{
            
            Class.forName("oracle.jdbc.driver.OracleDriver");
                  
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");
                  
            Statement stmt = con.createStatement();

			PreparedStatement pStatement = con.prepareStatement(query);		
			pStatement.setInt(1, pos_code);

			ResultSet rs = pStatement.executeQuery();

      	    ResultSetMetaData rsmd = rs.getMetaData();
      	    int cols = rsmd.getColumnCount();

      	    for (int i = 1; i <= cols; i++) {
      	        System.out.print(String.format("%-30s", rsmd.getColumnName(i)));
      	    }

      	    System.out.println();
      	    
      	    while (rs.next()) {
      	        for (int i = 1; i <= cols; i++) {
      	            String colValue = rs.getString(i);
      	            System.out.print(String.format("%-30s", colValue));
      	        }
      	        System.out.println();
      	    
      	    }

			con.close();

		} catch (Exception e) {
            System.out.println(e);
        }
	}

	static void setQueries(){
		q1 = "WITH needed_skills AS (SELECT ks_code\n" +
			                       "FROM requires\n" +
			                       "WHERE pos_code = ?)\n" +
			"SELECT per_name, email\n" +
			"FROM person P\n" +
			"WHERE NOT EXISTS ((SELECT ks_code\n" +
			                   "FROM needed_skills)\n" +
			                   "MINUS\n" +
			                  "(SELECT ks_code\n" +
			                   "FROM has_skill T\n" +
			                   "WHERE T.per_id = P.per_id))";
        q2 = "WITH needed_skills AS (SELECT ks_code\n" +
			                       "FROM requires\n" +
			                       "WHERE pos_code = ?),\n" +
			      "missing_skills AS ((SELECT per_id, ks_code\n" +
			       "                   FROM person, needed_skills)\n" +
			        "                  MINUS\n" +
			         "                (SELECT per_id, ks_code\n" +
			          "                FROM has_skill NATURAL JOIN needed_skills)),\n" +
			      "count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing\n" +
			       "                 FROM missing_skills\n" +
			        "                GROUP BY per_id),\n" +
			      "min_missing AS (SELECT MIN(num_missing) AS min_num\n" +
			       "               FROM count_missing)\n" +
			"SELECT per_id, num_missing\n" +
			"FROM count_missing, min_missing\n" +
			"WHERE num_missing = min_num";
	}
}