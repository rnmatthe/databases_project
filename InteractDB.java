import java.util.Scanner;
import java.sql.*;

public class InteractDB{

	static Scanner input = new Scanner(System.in);
	static int answer;


	
	public static void main(String[] args){


		Boolean cont = true;

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
					runQuery();
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

		return response;
	}

	public static Boolean runQuery(){


		String q = "SELECT DISTINCT per_name\n" +
					"FROM person, works, position, company\n" +
					"WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id\n"+
					"AND position.pos_code = works.pos_code\n"+
					"AND comp_name = 'Flashdog'";


		try{
            // step 1 load the driver class
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // step 2 create the connection object
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");

            // step 3 create the statement object
            Statement stmt = con.createStatement();
            // step 4 execute query
            ResultSet rs = stmt.executeQuery(q);
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

            //String insert = "insert into has_skill(per_id, ks_code) values(20, 301)";
            //stmt.executeUpdate(insert);
           
            // step 5 close the connection object
            con.close();
        } catch (Exception e) {
            System.out.println(e);
            System.out.println();
            return false;
        }
        System.out.println();
        return true;
	}

	public static Boolean insert(int table){
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
				insertStatement += per_id + ", " + per_name + ", " + street_name + ", " + street_num + ", ";
				break;
			case 2://position
				System.out.print("\nEnter per_id to be deleted: ");
			case 3://job_category

			case 4://course

			default:
				break;
		}

		System.out.println(insertStatement);
		return false;
	}

	public static Boolean delete(int table){
		System.out.println("delete table num: " + table);
		return false;
	}
}