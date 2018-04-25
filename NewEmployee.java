import java.util.Scanner;
import java.sql.*;

public class NewEmployee{

	static int per_id;
	static int pos_code;

	public static void main(String[] args){

		Scanner input = new Scanner(System.in);

		input.next();
		per_id = input.nextInt();
		input.next();
		pos_code = input.nextInt();

		System.out.println("person id: " + per_id);

		System.out.println("pos: " + pos_code);

		try{
            
            Class.forName("oracle.jdbc.driver.OracleDriver");
                  
            Connection con=DriverManager.getConnection(
                "jdbc:oracle:thin:@dbsvcs.cs.uno.edu:1521:orcl", "rnmatthe", "McmfNXV9");

                  
            Statement stmt = con.createStatement();

			while(input.hasNext()){
				/*
				System.out.println("c_code: " + input.nextInt());
				System.out.println("sec_no: " + input.nextInt());
				System.out.println("complete_date: " + input.next());//java.sql.Date.valueOf(input.next()));
				*/
				
				
				PreparedStatement pStatement = con.prepareStatement("insert into takes(per_id, c_code, sec_no, complete_date) values (?,?,?, to_date(?, 'MM-DD-YYYY') )");
				pStatement.setInt(1, per_id);
				pStatement.setInt(2, input.nextInt());
				pStatement.setInt(3, input.nextInt());
				pStatement.setString(4, input.next() );
				pStatement.executeUpdate();
			}

			con.close();

		} catch (Exception e) {
            System.out.println(e);
        }


	}
}