import java.util.Scanner;
import java.sql.*;

public class JobHunting{

	static Scanner input = new Scanner(System.in);
	static int per_id;
	static String q1;
	static String q2;

	public static void main(String[] args){

		setQueries();


		System.out.println("Enter your per_id: ");
        per_id = input.nextInt();


        System.out.println("You are qualified for these job categories: ");
        runQuery(q1);


        System.out.println("This is the highest paying position you qualify for: ");
        runQuery(q2);


	}

	public static void runQuery(String query){
		try{
            
            Class.forName("oracle.jdbc.driver.OracleDriver");
                  
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");
                  
            Statement stmt = con.createStatement();

			PreparedStatement pStatement = con.prepareStatement(query);		
			pStatement.setInt(1, per_id);

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
		q1 = "WITH person_cc AS (SELECT cc_code\n"+
                   "FROM has_skill NATURAL JOIN knowledge_skill\n" +
                   "WHERE has_skill.per_id = ?)\n" +
			"SELECT JC.cate_code, JC.cate_title\n" +
			"FROM job_category JC\n" +
			"WHERE NOT EXISTS ((SELECT cc_code\n" +
                   "FROM core_skill CS\n" +
                   "WHERE JC.cate_code = CS.cate_code)\n" +
                   "MINUS\n" +
                  "(SELECT cc_code\n" +
                   "FROM person_cc))\n";
        q2 = "WITH per_skills AS (SELECT ks_code\n"+
			                    "FROM has_skill\n"+
			                    "WHERE per_id = ?),\n"+
			     "qualified_for AS (SELECT DISTINCT pos_code\n"+
			                       "FROM position R\n"+
			                       "WHERE NOT EXISTS ((SELECT ks_code\n"+
			                        "                  FROM requires P\n"+
			                         "                 WHERE P.pos_code = R.pos_code)\n"+
			                          "                MINUS\n"+
			                           "               (SELECT ks_code\n"+
			                            "              FROM per_skills))\n"+
			                      "),\n"+
			     "max_salary AS (SELECT MAX(pay_rate) AS max_sal\n"+
			      "              FROM qualified_for NATURAL JOIN position\n"+
			       "             WHERE pay_type = 'salary')\n"+
			"SELECT position.pos_code, position.pay_rate\n"+
			"FROM qualified_for, position, max_salary\n"+
			"WHERE qualified_for.pos_code = position.pos_code\n"+
			"AND position.pay_rate = max_salary.max_sal";
	}
}