import java.util.Scanner;
import java.sql.*;

public class InteractDB{

	static Scanner input = new Scanner(System.in);
	static int answer;
	static private String[] queries = new String[27];


	
	public static void main(String[] args){


		Boolean cont = true;
		setQueries();

		while(cont){

			printOptions();

			try{
				answer = input.nextInt();
			} catch (Exception e){
				answer = 0;
				input.next();
			}
			

			switch(answer){
				case 1:
					insert(askTables());
					break;
				case 2:
					delete(askTables());
					break;
				case 3:
					break;//add to later
				case 4:
					System.out.println();
					runQuery(queries[askQuery()], true);
					break;
				case 5:
					cont = false;
					break;
				default:
					System.out.println("\n--please enter a number between 1 and 5--");
					break;
			}

		}
	}

	public static void printOptions(){
		System.out.println("\nWhat would you like to do?\n");
		System.out.println("1) insert into a table");
		System.out.println("2) delete from a table");
		System.out.println("3) change status of a course");
		System.out.println("4) run a query");
		System.out.println("5) quit");
	}

	public static int askTables(){
		System.out.println("\nFrom which table?\n");
		System.out.println("1) Person");
		System.out.println("2) Position");
		System.out.println("3) Job Category");
		System.out.println("4) Course");

		int response = 0;

		Boolean validInput = false;
		while(!validInput){

			try{
				response = input.nextInt();
			} catch (Exception e){
				input.next();
			}

			if(response > 0 && response < 5){
				validInput = true;
			}else {
				System.out.println("--please enter a valid table number--");
			}
		}

		return response;
	}

	public static int askQuery(){
		System.out.println("Which query? Please enter a number between 1 and 27");
		int response = 0;

		Boolean validInput = false;
		while(!validInput){

			try{
				response = input.nextInt();
			} catch (Exception e){
				input.next();
			}

			if(response > 0 && response < 28){
				validInput = true;
			}else {
				System.out.println("--please enter a valid query number--");
			}
		}

		System.out.println();

		return response - 1;
	}

	public static Boolean runQuery(String runThis, Boolean isQuery){

/*
		String q = "SELECT DISTINCT per_name\n" +
					"FROM person, works, position, company\n" +
					"WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id\n"+
					"AND position.pos_code = works.pos_code\n"+
					"AND comp_name = 'Flashdog'";

*/
		try{
            
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");

            
            Statement stmt = con.createStatement();

            if(isQuery){
            
	            ResultSet rs = stmt.executeQuery(runThis);
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

        	} else {
        		stmt.executeUpdate(runThis);
        	}
           
            
            con.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println();
            return false;
        }
        System.out.println();
        return true;
	}

	public static void insert(int table){
		String insertStatement = "";
		switch(table){
			case 1://person
				System.out.print("\nEnter per_id: ");
				int per_id = input.nextInt();

				System.out.print("Enter per_name: ");
				String per_name = input.next();

				System.out.print("Enter street_name: ");
				String street_name = input.next();

				System.out.print("Enter street_num: ");
				int street_num = input.nextInt(); 

				System.out.print("Enter city: ");
				String city = input.next();

				System.out.print("Enter state: ");
				String state = input.next();

				System.out.print("Enter zip_code: ");
				int zip_code = input.nextInt();

				System.out.print("Enter email: ");
				String email = input.next();

				System.out.print("Enter gender (male or female): ");
				String gender = input.next();

				insertStatement = "INSERT INTO person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) VALUES (";
				insertStatement += per_id + ", '" + per_name + "', '" + street_name + "', " + street_num + ", '" + city + "', '" + state + "', " + zip_code + ", '" + email + "', '" + gender + "')";

				runQuery(insertStatement, false);
				break;
			case 2://position
				System.out.print("\nEnter per_id to be deleted: ");
			case 3://job_category

			case 4://course

			default:
				break;
		}

		//System.out.println(insertStatement);
	}

	public static void delete(int table){
		//System.out.println("delete table num: " + table);

		switch(table){
			case 1://person
				System.out.print("\nEnter per_id to be deleted: ");
				int per_id = input.nextInt();

				String deleteStatement = "DELETE FROM person WHERE per_id = " + per_id;

				runQuery(deleteStatement, false);
				
				break;
			case 2://position
				System.out.print("\nEnter  to be deleted: ");
			case 3://job_category

			case 4://course

			default:
				break;
		}
	}

	public static void setQueries(){
		queries[0] = "SELECT DISTINCT per_name\n" +
					"FROM person, works, position, company\n" +
					"WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id\n"+
					"AND position.pos_code = works.pos_code\n"+
					"AND comp_name = 'Flashdog'";
		queries[1] = "WITH salaries AS (SELECT per_id, pos_code, pay_rate\n"+
                  	  "FROM works NATURAL JOIN position\n"+
                      "WHERE end_date > SYSDATE\n"+
                  	  "AND pay_type = 'salary')\n"+
					  "SELECT per_name, pay_rate\n"+
					  "FROM person NATURAL JOIN salaries\n"+
					  "ORDER BY pay_rate DESC";
		queries[2] = "";
	}
}