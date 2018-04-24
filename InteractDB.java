import java.util.Scanner;
import java.sql.*;

public class InteractDB{

	static Scanner input = new Scanner(System.in);
	static int answer;
	static private String[] queries = new String[33];
      static private final String delete = "delete";
      static private final String insert = "insert";
      static private final String query = "query";
      static private final String changeStatus = "change status";


	
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
					//insert(askTables());
                              runQuery(null, askTables(), insert);
					break;
				case 2:
					//delete(askTables());
                              runQuery(null, askTables(), delete);
					break;
				case 3:
                              runQuery(null, -1, changeStatus);
					break;//add to later
				case 4:
                              int queryToRun = askQuery();
                            
                              if (queryToRun == 6)
                              {
                                    runQuery(queries[6], -1, query);
                                    runQuery(queries[27], -1, query);
                              }
                              else if (queryToRun == 22)
                              {
                                    runQuery(queries[22], -1, query);
                                    runQuery(queries[28], -1, query);
                              }
                              else if (queryToRun == 23)
                              {
                                    runQuery(queries[23], -1, query);
                                    runQuery(queries[29], -1, query);
                              }
                              else if (queryToRun == 24)
                              {
                                    runQuery(queries[24], -1, query);
                                    runQuery(queries[30], -1, query);
                                    runQuery(queries[31], -1, query);
                                    runQuery(queries[32], -1, query);
                              }
                              else 
					      runQuery(queries[queryToRun], -1, query);
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

	public static Boolean runQuery(String runThis, int tableNum, String operation){

		try{
            
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");

            
            Statement stmt = con.createStatement();

            if(operation == query){

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
                  
                  if(operation == insert){
                        if(tableNum == 1){//person
                              PreparedStatement pStatement = con.prepareStatement("INSERT INTO person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) VALUES (?,?,?,?,?,?,?,?,?)");
                              System.out.println("Enter per_id: ");
                              pStatement.setInt(1, input.nextInt());
                              System.out.println("Enter per_name: ");
                              pStatement.setString(2, input.next());
                              System.out.println("Enter street_name: ");
                              pStatement.setString(3, input.next());
                              System.out.println("Enter street_num: ");
                              pStatement.setInt(4, input.nextInt());
                              System.out.println("Enter city: ");
                              pStatement.setString(5, input.next());
                              System.out.println("Enter state: ");
                              pStatement.setString(6, input.next());
                              System.out.println("Enter zip_code: ");
                              pStatement.setInt(7, input.nextInt());
                              System.out.println("Enter email: ");
                              pStatement.setString(8, input.next());
                              System.out.println("Enter gender: ");
                              pStatement.setString(9, input.next());
                              pStatement.executeUpdate();
                        } else if(tableNum == 2){//position
                              PreparedStatement pStatement = con.prepareStatement("insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values (?,?,?,?,?,?)");
                              System.out.println("Enter pos_code: ");
                              pStatement.setInt(1, input.nextInt());
                              System.out.println("Enter emp_mode (full-time or part-time): ");
                              pStatement.setString(2, input.next());
                              System.out.println("Enter pay_rate: ");
                              pStatement.setInt(3, input.nextInt());
                              System.out.println("Enter pay_type (salary or hourly): ");
                              pStatement.setString(4, input.next());
                              System.out.println("Enter comp_id: ");
                              pStatement.setInt(5, input.nextInt());
                              System.out.println("Enter cate_code: ");
                              pStatement.setInt(6, input.nextInt());
                              pStatement.executeUpdate();
                        } else if(tableNum == 3){//job_category
                              PreparedStatement pStatement = con.prepareStatement("insert into job_category(cate_code, cate_title, cate_description, pay_range_high, pay_range_low, parent_cate) values (?,?,?,?,?,?)");
                              System.out.println("Enter cate_code: ");
                              pStatement.setInt(1, input.nextInt());
                              System.out.println("Enter cate_title: ");
                              pStatement.setString(2, input.next());
                              System.out.println("Enter cate_description: ");
                              pStatement.setString(3, input.next());
                              System.out.println("Enter pay_range_high: ");
                              pStatement.setInt(4, input.nextInt());
                              System.out.println("Enter pay_range_low: ");
                              pStatement.setInt(5, input.nextInt());
                              System.out.println("Enter parent_cate: ");
                              pStatement.setInt(6, input.nextInt());
                              pStatement.executeUpdate();
                        } else {//course
                              PreparedStatement pStatement = con.prepareStatement("insert into course(c_code, title, description, status, retail_price) values (?,?,?,?,?)");
                              System.out.println("Enter c_code (expired or active): ");
                              pStatement.setInt(1, input.nextInt());
                              System.out.println("Enter title: ");
                              pStatement.setString(2, input.next());
                              System.out.println("Enter description: ");
                              pStatement.setString(3, input.next());
                              System.out.println("Enter status: ");
                              pStatement.setString(4, input.next());
                              System.out.println("Enter retail_price: ");
                              pStatement.setInt(5, input.nextInt());
                              pStatement.executeUpdate();
                        }
                  } else if (operation == delete){
                        if(tableNum == 1){//person
                              PreparedStatement pStatement = con.prepareStatement("delete from person where per_id = ?");
                              System.out.println("Enter per_id: ");
                              pStatement.setInt(1, input.nextInt());
                              pStatement.executeUpdate();
                        } else if(tableNum == 2){//position
                              PreparedStatement pStatement = con.prepareStatement("delete from position where pos_code = ?");
                              System.out.println("Enter pos_code: ");
                              pStatement.setInt(1, input.nextInt());
                              pStatement.executeUpdate();
                        } else if(tableNum == 3){//job_category
                              PreparedStatement pStatement = con.prepareStatement("delete from job_category where cate_code = ?");
                              System.out.println("Enter cate_code: ");
                              pStatement.setInt(1, input.nextInt());
                              pStatement.executeUpdate();
                        } else {//course
                              PreparedStatement pStatement = con.prepareStatement("delete from course where c_code = ?");
                              System.out.println("Enter c_code: ");
                              pStatement.setInt(1, input.nextInt());
                              pStatement.executeUpdate();
                        }
                  } else if (operation == changeStatus){
                        PreparedStatement pStatement = con.prepareStatement("update course set status = ? where c_code = ?");
                        System.out.println("Enter c_code");
                        pStatement.setInt(2, input.nextInt());
                        System.out.println("Enter updated status (expired or active): ");
                        pStatement.setString(1, input.next());
                        pStatement.executeUpdate();
                  }
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

	public static void setQueries(){
		queries[0] = "SELECT DISTINCT per_name\n" +
                         "FROM person, works, position, company\n" +
                         "WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id\n" +
                         "AND position.pos_code = works.pos_code\n" +
                         "AND comp_name = 'Flashdog'";
            queries[1] = "WITH salaries AS (SELECT per_id, pos_code, pay_rate\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE\n" +
                         "AND pay_type = 'salary')\n" +
                         "SELECT per_name, pay_rate\n" +
                         "FROM person NATURAL JOIN salaries\n" +
                         "ORDER BY pay_rate DESC"; 
            queries[2] = "SELECT comp_id, SUM( CASE\n" +
                         "WHEN pay_type = 'salary' THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END) AS total_cost\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE works.end_date > SYSDATE\n" +
                         "GROUP BY comp_id\n" +
                         "ORDER BY total_cost";
            queries[3] = "SELECT person.per_id, person.per_name, works.pos_code\n" +
                         "FROM person, works\n" +
                         "WHERE person.per_id = works.per_id\n" +
                         "AND person.per_id = 1";
            queries[4] = "SELECT knowledge_skill.ks_code, knowledge_skill.title\n" +
                         "FROM has_skill, knowledge_skill\n" +
                         "WHERE has_skill.ks_code = knowledge_skill.ks_code\n" +
                         "AND per_id = 1";
            queries[5] = "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires, works\n" +
                         "WHERE requires.pos_code = works.pos_code\n" +
                         "AND works.per_id = 1\n" +
                         "AND works.end_date < SYSDATE )\n" +
                         "SELECT ks_code\n" +
                         "FROM needed_skills MINUS (SELECT ks_code\n" +
                         "FROM has_skill \n" +
                         "WHERE per_id = 1)";
            queries[6] = "WITH position_skills as (SELECT requires.pos_code, knowledge_skill.title, knowledge_skill.ks_code\n" +
                         "FROM requires, knowledge_skill\n" +
                         "WHERE requires.ks_code = knowledge_skill.ks_code\n" +
                         "AND requires.pos_code = 23)\n" +
                         "SELECT pos_code, title required_skill, ks_code\n" +
                         "FROM position_skills";
            //PART 2
            queries[27]= "WITH category_skills as (SELECT cate_code, knowledge_skill.title, ks_code\n" +
                         "FROM core_skill NATURAL JOIN knowledge_skill\n" +
                         "WHERE cate_code = 78)\n" +
                         "SELECT cate_code, title required_skill, ks_code\n" +
                         "FROM category_skills";
            queries[7] = "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23)\n" +
                         "SELECT ks_code\n" +
                         "FROM needed_skills MINUS (SELECT ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id = 2)";
            queries[8] = "WITH skills_needed AS ((SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE requires.pos_code = 23)\n" +
                         "MINUS\n" +
                         "(SELECT has_skill.ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id = 2))\n" +
                         "SELECT DISTINCT c_code\n" +
                         "FROM course P\n" +
                         "WHERE NOT EXISTS ((SELECT *\n" +
                         "FROM skills_needed)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches T\n" +
                         "WHERE T.c_code = P.c_code))";
            queries[9]=  "WITH skills_needed AS ((SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id = 2)),\n" +
                         "relevant_sections AS (SELECT c_code, sec_no, complete_date\n" +
                         "FROM section NATURAL JOIN (SELECT c_code\n" +
                         "FROM course P\n" +
                         "WHERE NOT EXISTS ((SELECT *\n" +
                         "FROM skills_needed)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches T\n" +
                         "WHERE T.c_code = P.c_code)))\n" +
                         "WHERE section.complete_date > SYSDATE),\n" +
                         "closest_date AS (SELECT MIN(complete_date) AS min_date\n" +
                         "FROM relevant_sections)\n" +
                         "SELECT DISTINCT c_code, sec_no, complete_date\n" +
                         "FROM relevant_sections, closest_date\n" +
                         "WHERE complete_date = min_date";
            queries[10]= "WITH skills_needed AS ((SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id =2)),\n" +
                         "relevant_course AS (SELECT c_code, retail_price, title\n" +
                         "FROM course P\n" +
                         "WHERE NOT EXISTS ((SELECT *\n" +
                         "FROM skills_needed)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches T\n" +
                         "WHERE T.c_code = P.c_code))),\n" +
                         "cheapest AS (SELECT MIN(retail_price) AS retail_price\n" +
                         "FROM relevant_course)\n" +
                         "SELECT *\n" +
                         "FROM relevant_course NATURAL JOIN section NATURAL JOIN cheapest\n" +
                         "WHERE complete_date > SYSDATE";
            queries[11]= "WITH needed_skills AS ((SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 26)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id = 3)),\n" +
                         "relevent_courses AS (SELECT DISTINCT (c_code), ks_code\n" +
                         "FROM teaches NATURAL JOIN needed_skills),\n" +
                         "c1 AS (SELECT *\n" +
                         "FROM relevent_courses),\n" +
                         "c2 AS (SELECT *\n" +
                         "FROM relevent_courses),\n" +
                         "c3 AS (SELECT *\n" +
                         "FROM relevent_courses),\n" +
                         "all_poss AS (SELECT DISTINCT c1.c_code AS c1_code, c2.c_code AS c2_code, c3.c_code AS c3_code\n" +
                         "FROM c1, c2, c3\n" +
                         "WHERE c1.c_code < c2.c_code\n" +
                         "AND c2.c_code < c3.c_code),\n" +
                         "covers_all AS (SELECT *\n" +
                         "FROM all_poss P\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches T\n" +
                         "WHERE T.c_code = P.c1_code\n" +
                         "OR T.c_code = P.c2_code\n" +
                         "OR T.c_code = P.c3_code))),\n" +
                         "sets_of_two AS (SELECT c1.c_code AS c1_code, c2.c_code AS c2_code\n" +
                         "FROM c1, c2\n" +
                         "WHERE c1.c_code < c2.c_code),\n" +
                         "legit_two AS (SELECT c1_code, c2_code\n" +
                         "FROM sets_of_two P\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches T\n" +
                         "WHERE T.c_code = P.c1_code\n" +
                         "OR T.c_code = P.c2_code))),\n" +
                         "legit_three AS (SELECT *\n" +
                         "FROM covers_all P\n" +
                         "WHERE EXISTS ((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches NATURAL JOIN relevent_courses\n" +
                         "WHERE c_code = P.c1_code OR c_code = P.c2_code))\n" +
                         "AND EXISTS ((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches NATURAL JOIN relevent_courses\n" +
                         "WHERE c_code = P.c2_code OR c_code = P.c3_code))\n" +
                         "AND EXISTS((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches NATURAL JOIN relevent_courses\n" +
                         "WHERE c_code = P.c1_code OR c_code = P.c3_code))),\n" +
                         "not_legit_three AS ((SELECT *\n" +
                         "FROM covers_all)\n" +
                         "MINUS\n" +
                         "(SELECT *\n" +
                         "FROM legit_three)),\n" +
                         "combine AS ((SELECT c1_code, c2_code, CASE\n" +
                         "WHEN EXISTS (SELECT c1_code, c2_code\n" +
                         "FROM legit_two T\n" +
                         "WHERE P.c1_code = T.c1_code\n" +
                         "AND P.c2_code = T.c2_code)\n" +
                         "THEN null\n" +
                         "ELSE c3_code \n" +
                         "END AS c3_code\n" +
                         "FROM covers_all P)\n" +
                         "MINUS\n" +
                         "(SELECT *\n" +
                         "FROM not_legit_three)),\n" +
                         "costs AS (SELECT c1_code, c2_code, c3_code, SUM(retail_price) AS total_cost\n" +
                         "FROM combine, course\n" +
                         "WHERE course.c_code = combine.c1_code\n" +
                         "OR course.c_code = combine.c2_code\n" +
                         "OR course.c_code = combine.c3_code\n" +
                         "GROUP BY c1_code, c2_code, c3_code)\n" +
                         "SELECT *\n" +
                         "FROM costs\n" +
                         "ORDER BY total_cost ASC";
            queries[12]= "WITH person_cc AS (SELECT cc_code\n" +
                         "FROM has_skill NATURAL JOIN knowledge_skill\n" +
                         "WHERE has_skill.per_id = 1) \n" +
                         "SELECT JC.cate_code, JC.cate_title\n" +
                         "FROM job_category JC\n" +
                         "WHERE NOT EXISTS ((SELECT cc_code\n" +
                         "FROM core_skill CS\n" +
                         "WHERE JC.cate_code = CS.cate_code)\n" +
                         "MINUS\n" +
                         "(SELECT cc_code\n" +
                         "FROM person_cc))";
            queries[13]= "WITH per_skills AS (SELECT ks_code\n" +
                         "FROM has_skill\n" +
                         "WHERE per_id = 1),\n" +
                         "qualified_for AS (SELECT DISTINCT pos_code\n" +
                         "FROM position R\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM requires P\n" +
                         "WHERE P.pos_code = R.pos_code)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM per_skills))),\n" +
                         "max_salary AS (SELECT MAX(pay_rate) AS max_sal\n" +
                         "FROM qualified_for NATURAL JOIN position\n" +
                         "WHERE pay_type = 'salary')\n" +
                         "SELECT position.pos_code, position.pay_rate\n" +
                         "FROM qualified_for, position, max_salary\n" +
                         "WHERE qualified_for.pos_code = position.pos_code\n" +
                         "AND position.pay_rate = max_salary.max_sal";
            queries[14]= "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 25)\n" +
                         "SELECT per_name, email\n" +
                         "FROM person P\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill T\n" +
                         "WHERE T.per_id = P.per_id))";
            queries[15]= "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23),\n" +
                         "num_skills_req AS (SELECT COUNT(ks_code) AS num\n" +
                         "FROM needed_skills),\n" +
                         "num_has AS (SELECT per_id, COUNT(ks_code) AS num\n" +
                         "FROM has_skill NATURAL JOIN needed_skills\n" +
                         "GROUP BY per_id)\n" +
                         "SELECT per_id\n" +
                         "FROM num_has, num_skills_req\n" +
                         "WHERE num_has.num = num_skills_req.num - 1";
            queries[16]= "WITH needed_skills AS (SELECT ks_code \n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23),\n" +
                         "missing_skills AS ((SELECT per_id, ks_code\n" +
                         "FROM person, needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT per_id, ks_code\n" +
                         "FROM has_skill))\n" +
                         "SELECT DISTINCT ks_code, COUNT(per_id)\n" +
                         "FROM missing_skills\n" +
                         "GROUP BY ks_code";
            queries[17]= "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23),\n" +
                         "missing_skills AS ((SELECT per_id, ks_code\n" +
                         "FROM person, needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT per_id, ks_code\n" +
                         "FROM has_skill NATURAL JOIN needed_skills)),\n" +
                         "count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing\n" +
                         "FROM missing_skills\n" +
                         "GROUP BY per_id),\n" +
                         "min_missing AS (SELECT MIN(num_missing) AS min_num\n" +
                         "FROM count_missing)\n" +
                         "SELECT per_id, num_missing\n" +
                         "FROM count_missing, min_missing\n" +
                         "WHERE num_missing = min_num";
            queries[18]= "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23),\n" +
                         "missing_skills AS ((SELECT per_id, ks_code\n" +
                         "FROM person, needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT per_id, ks_code\n" +
                         "FROM has_skill NATURAL JOIN needed_skills)),\n" +
                         "count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing\n" +
                         "FROM missing_skills\n" +
                         "GROUP BY per_id)\n" +
                         "SELECT per_id, num_missing\n" +
                         "FROM count_missing\n" +
                         "WHERE num_missing < 3\n" +
                         "ORDER BY num_missing ASC";
            queries[19]= "WITH needed_skills AS (SELECT ks_code\n" +
                         "FROM requires\n" +
                         "WHERE pos_code = 23),\n" +
                         "missing_skills AS ((SELECT per_id, ks_code\n" +
                         "FROM person, needed_skills)\n" +
                         "MINUS\n" +
                         "(SELECT per_id, ks_code\n" +
                         "FROM has_skill NATURAL JOIN needed_skills)),\n" +
                         "count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing\n" +
                         "FROM missing_skills\n" +
                         "GROUP BY per_id),\n" +
                         "missing_k AS (SELECT per_id, num_missing\n" +
                         "FROM count_missing\n" +
                         "WHERE num_missing < 3),\n" +
                         "missing_k_skills AS (SELECT ks_code, COUNT(per_id) AS num_people\n" +
                         "FROM missing_skills NATURAL JOIN missing_k\n" +
                         "GROUP BY ks_code)\n" +
                         "SELECT ks_code, num_people\n" +
                         "FROM missing_k_skills\n" +
                         "ORDER BY num_people ASC";
            queries[20]= "SELECT person.per_id, per_name, position.pos_code, EXTRACT(YEAR FROM start_date) AS start_year, EXTRACT(YEAR FROM end_date) AS end_year\n" +
                         "FROM person, works, position\n" +
                         "WHERE cate_code = 78\n" +
                         "AND end_date < SYSDATE\n" +
                         "AND person.per_id = works.per_id\n" +
                         "AND works.pos_code = position.pos_code";
            queries[21]= "SELECT per_id, per_name\n" +
                         "FROM person P\n" +
                         "WHERE NOT EXISTS (SELECT pos_code\n" +
                         "FROM works T\n" +
                         "WHERE T.per_id = P.per_id\n" +
                         "AND T.end_date > SYSDATE)\n" +
                         "AND EXISTS (SELECT *\n" +
                         "FROM works W\n" +
                         "WHERE W.pos_code = 26\n" +
                         "AND W.per_id = P.per_id)";
            queries[22]= "WITH num_employees AS (SELECT comp_id, COUNT(per_id) AS num_emp\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE\n" +
                         "GROUP BY comp_id),\n" +
                         "max_num AS (SELECT MAX(num_emp) AS max_emp\n" +
                         "FROM num_employees)\n" +
                         "SELECT comp_id, num_emp\n" +
                         "FROM num_employees, max_num\n" +
                         "WHERE num_emp = max_emp";
            //PART 2
            queries[28]= "WITH amount_paid AS (SELECT per_id, pos_code, comp_id, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE),\n" +
                         "total_paid AS (SELECT comp_id, SUM(pay) AS total\n" +
                         "FROM amount_paid\n" +
                         "GROUP BY comp_id),\n" +
                         "max_paid AS (SELECT MAX(total) AS max_total\n" +
                         "FROM total_paid)\n" +
                         "SELECT comp_id, total\n" +
                         "FROM total_paid, max_paid\n" +
                         "WHERE total = max_total";
            queries[23]= "WITH people_per_sector AS (SELECT ind_code, COUNT(per_id) AS num_people\n" +
                         "FROM company NATURAL JOIN position NATURAL JOIN works\n" +
                         "WHERE end_date > SYSDATE\n" +
                         "GROUP BY ind_code),\n" +
                         "max_people AS (SELECT MAX(num_people) AS max_num\n" +
                         "FROM people_per_sector)\n" +
                         "SELECT ind_code, num_people\n" +
                         "FROM people_per_sector, max_people\n" +
                         "WHERE num_people = max_num";
            //PART 2
            queries[29]= "WITH needed_info AS (SELECT ind_code, per_id, pos_code, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS payment\n" +
                         "FROM company NATURAL JOIN position NATURAL JOIN works\n" +
                         "WHERE end_date > SYSDATE),\n" +
                         "totals AS (SELECT ind_code, SUM(payment) AS total_spent\n" +
                         "FROM needed_info\n" +
                         "GROUP BY ind_code),\n" +
                         "max_spent AS (SELECT MAX(total_spent) AS the_max\n" +
                         "FROM totals)\n" +
                         "SELECT ind_code, total_spent\n" +
                         "FROM totals, max_spent\n" +
                         "WHERE totals.total_spent = max_spent.the_max";
            queries[24]= "WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date < SYSDATE),\n" +
                         "most_recent AS (SELECT per_id, pay, end_date\n" +
                         "FROM past_jobs P\n" +
                         "WHERE P.end_date = (SELECT MAX(end_date)\n" +
                         "FROM past_jobs T\n" +
                         "WHERE T.per_id = P.per_id)),\n" +
                         "current_pay AS (SELECT per_id, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE),\n" +
                         "difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change\n" +
                         "FROM current_pay, most_recent\n" +
                         "WHERE current_pay.per_id = most_recent.per_id)\n" +
                         "SELECT COUNT(per_id)\n" +
                         "FROM difference\n" +
                         "WHERE pay_change > 0";
            //PART 2
            queries[30]= "WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date < SYSDATE),\n" +
                         "most_recent AS (SELECT per_id, pay, end_date\n" +
                         "FROM past_jobs P\n" +
                         "WHERE P.end_date = (SELECT MAX(end_date)\n" +
                         "FROM past_jobs T\n" +
                         "WHERE T.per_id = P.per_id)),\n" +
                         "current_pay AS (SELECT per_id, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE),\n" +
                         "difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change\n" +
                         "FROM current_pay, most_recent\n" +
                         "WHERE current_pay.per_id = most_recent.per_id)\n" +
                         "SELECT COUNT(per_id)\n" +
                         "FROM difference\n" +
                         "WHERE pay_change < 0";
            //PART 3
            queries[31]= "WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date < SYSDATE),\n" +
                         "most_recent AS (SELECT per_id, pay, end_date\n" +
                         "FROM past_jobs P\n" +
                         "WHERE P.end_date = (SELECT MAX(end_date)\n" +
                         "FROM past_jobs T\n" +
                         "WHERE T.per_id = P.per_id)),\n" +
                         "current_pay AS (SELECT per_id, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position\n" +
                         "WHERE end_date > SYSDATE),\n" +
                         "difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change\n" +
                         "FROM current_pay, most_recent\n" +
                         "WHERE current_pay.per_id = most_recent.per_id),\n" +
                         "increased AS (SELECT COUNT (per_id) AS num_inc\n" +
                         "FROM difference\n" +
                         "WHERE pay_change > 0),\n" +
                         "decreased AS (SELECT COUNT (per_id) AS num_dec\n" +
                         "FROM difference\n" +
                         "WHERE pay_change < 0)\n" +
                         "SELECT *\n" +
                         "FROM increased, decreased";
            //PART 4
            queries[32]= "WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position NATURAL JOIN company\n" +
                         "WHERE end_date < SYSDATE\n" +
                         "AND ind_code = 511210),\n" +
                         "most_recent AS (SELECT per_id, pay, end_date\n" +
                         "FROM past_jobs P\n" +
                         "WHERE P.end_date = (SELECT MAX(end_date)\n" +
                         "FROM past_jobs T\n" +
                         "WHERE T.per_id = P.per_id)),\n" +
                         "current_pay AS (SELECT per_id, CASE\n" +
                         "WHEN pay_type = 'salary'\n" +
                         "THEN pay_rate\n" +
                         "ELSE pay_rate * 1920\n" +
                         "END AS pay\n" +
                         "FROM works NATURAL JOIN position NATURAL JOIN company\n" +
                         "WHERE end_date > SYSDATE\n" +
                         "AND ind_code = 511210),\n" +
                         "difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change\n" +
                         "FROM current_pay, most_recent\n" +
                         "WHERE current_pay.per_id = most_recent.per_id)\n" +
                         "SELECT AVG(pay_change)\n" +
                         "FROM difference";
            queries[25]= "WITH leaf_cate AS (SELECT cate_code\n" +
                         "FROM job_category T\n" +
                         "WHERE NOT EXISTS (SELECT parent_cate\n" +
                         "FROM job_category P\n" +
                         "WHERE P.parent_cate = T.cate_code)),\n" +
                         "emp_pos AS (SELECT pos_code, cate_code\n" +
                         "FROM position P\n" +
                         "WHERE NOT EXISTS (SELECT pos_code\n" +
                         "FROM works W\n" +
                         "WHERE P.pos_code = W.pos_code\n" +
                         "AND W.end_date > SYSDATE)),\n" +
                         "vacancies AS (SELECT cate_code, COUNT(pos_code) AS num_vac\n" +
                         "FROM leaf_cate NATURAL JOIN emp_pos\n" +
                         "GROUP BY cate_code),\n" +
                         "unemployed AS (SELECT per_id\n" +
                         "FROM person P\n" +
                         "WHERE NOT EXISTS (SELECT pos_code\n" +
                         "FROM works W\n" +
                         "WHERE w.per_id = P.per_id\n" +
                         "AND W.end_date > SYSDATE)),\n" +
                         "setup AS (SELECT cate_code, pos_code, per_id\n" +
                         "FROM unemployed, emp_pos),\n" +
                         "qualified_people AS (SELECT cate_code, per_id\n" +
                         "FROM setup T\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM requires P\n" +
                         "WHERE P.pos_code = T.pos_code\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill H\n" +
                         "WHERE H.per_id = T.per_id)))),\n" +
                         "total_qual AS (SELECT cate_code, COUNT(per_id) AS num_qual\n" +
                         "FROM qualified_people\n" +
                         "GROUP BY cate_code),\n" +
                         "diff AS (SELECT cate_code, num_vac - num_qual AS real_num\n" +
                         "FROM total_qual NATURAL JOIN vacancies),\n" +
                         "max_vac AS (SELECT MAX(real_num) AS max_num\n" +
                         "FROM diff)\n" +
                         "SELECT cate_code, real_num\n" +
                         "FROM diff, max_vac\n" +
                         "WHERE real_num = max_num";
            queries[26]= "WITH leaf_cate AS (SELECT cate_code\n" +
                         "FROM job_category T\n" +
                         "WHERE NOT EXISTS (SELECT parent_cate\n" +
                         "FROM job_category P\n" +
                         "WHERE P.parent_cate = T.cate_code)),\n" +
                         "emp_pos AS (SELECT pos_code, cate_code\n" +
                         "FROM position P\n" +
                         "WHERE NOT EXISTS (SELECT pos_code\n" +
                         "FROM works W\n" +
                         "WHERE P.pos_code = W.pos_code\n" +
                         "AND W.end_date > SYSDATE)),\n" +
                         "vacancies AS (SELECT cate_code, COUNT(pos_code) AS num_vac\n" +
                         "FROM leaf_cate NATURAL JOIN emp_pos\n" +
                         "GROUP BY cate_code),\n" +
                         "unemployed AS (SELECT per_id\n" +
                         "FROM person P\n" +
                         "WHERE NOT EXISTS (SELECT pos_code\n" +
                         "FROM works W\n" +
                         "WHERE W.per_id = P.per_id\n" +
                         "AND W.end_date > SYSDATE)),\n" +
                         "setup AS (SELECT cate_code, pos_code, per_id\n" +
                         "FROM unemployed, emp_pos),\n" +
                         "qualified_people AS (SELECT cate_code, per_id, pos_code\n" +
                         "FROM setup T\n" +
                         "WHERE NOT EXISTS ((SELECT ks_code\n" +
                         "FROM requires P\n" +
                         "WHERE P.pos_code = T.pos_code\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill H\n" +
                         "WHERE H.per_id = T.per_id)))),\n" +
                         "total_qual AS (SELECT cate_code, COUNT(per_id) AS num_qual\n" +
                         "FROM qualified_people\n" +
                         "GROUP BY cate_code),\n" +
                         "diff AS (SELECT cate_code, num_vac - num_qual AS real_num\n" +
                         "FROM total_qual NATURAL JOIN vacancies),\n" +
                         "max_vac AS (SELECT MAX(real_num) AS max_num\n" +
                         "FROM diff),\n" +
                         "relevent_cate AS (SELECT cate_code\n" +
                         "FROM diff, max_vac\n" +
                         "WHERE real_num = max_num),\n" +
                         "unqualified_people AS ((SELECT per_id\n" +
                         "FROM unemployed)\n" +
                         "MINUS\n" +
                         "(SELECT per_id\n" +
                         "FROM qualified_people NATURAL JOIN relevent_cate)),\n" +
                         "relevent_pos AS (SELECT pos_code, ks_code\n" +
                         "FROM position NATURAL JOIN requires NATURAL JOIN relevent_cate),\n" +
                         "setup_courses AS (SELECT c_code, per_id\n" +
                         "FROM unqualified_people, course),\n" +
                         "qualifies AS (SELECT c_code, COUNT(per_id) AS num_qual\n" +
                         "FROM setup_courses M\n" +
                         "WHERE EXISTS (SELECT pos_code\n" +
                         "FROM relevent_pos P\n" +
                         "WHERE NOT EXISTS (((SELECT ks_code\n" +
                         "FROM relevent_pos T\n" +
                         "WHERE P.pos_code = T.pos_code)\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM has_skill H\n" +
                         "WHERE H.per_id = M.per_id))\n" +
                         "MINUS\n" +
                         "(SELECT ks_code\n" +
                         "FROM teaches E\n" +
                         "WHERE E.c_code = M.c_code)))\n" +
                         "GROUP BY c_code),\n" +
                         "max_qualifies AS (SELECT MAX(num_qual) AS max_num\n" +
                         "FROM qualifies)\n" +
                         "SELECT c_code, num_qual\n" +
                         "FROM qualifies, max_qualifies\n" +
                         "WHERE max_num = num_qual";
  }
}
