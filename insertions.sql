--person
insert into person(per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (1, 'Lolita Pottberry', '4th', 6, 'Albany', 'New York', 12262, 'lpottberry0@blog.com', 'female');
insert into person(per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (2, 'Lemar Iban', 'Oxford', 156, 'Winston', 'North Carolina', 27157, 'lban1@ow.ly', 'male');
insert into person(per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (3, 'Ferdinande Koche', 'Maple Wood', 201, 'Asheville', 'North Carolina', 28805, 'fkoche2@tinypic.com', 'female');
insert into person(per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (4, 'Tobiah Faveryear', 'Hayes', 107, 'Rockville', 'Maryland', 20851, 'tfaveryear3@cdc.gov', 'male');
insert into person(per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (5, 'Elke Lenham', 'Arkansas', 202, 'Miami', 'Florida', 33129, 'elenham4@marr.com', 'female');

--NWCET
insert into nwcet(cc_code, title) values ('DDA', 'Database Development and Administration');
insert into nwcet(cc_code, title) values ('DM', 'Digital Media');
insert into nwcet(cc_code, title) values ('ESAI', 'Enterprise Systems Analysis and Integration');
insert into nwcet(cc_code, title) values ('NDA', 'Network Design and Administration');
insert into nwcet(cc_code, title) values ('PSE', 'Programming/Software Engineering');
insert into nwcet(cc_code, title) values ('TS', 'Technical Support');
insert into nwcet(cc_code, title) values ('WDA', 'Web Development and Administration');

--naics
insert into naics(ind_code, ind_title) values (511210, 'Software Publishers');
insert into naics(ind_code, ind_title) values (518210, 'Data Processing, Hosting, and Related Services');
insert into naics(ind_code, ind_title) values (541511, 'Custom Computer Programming Services');
insert into naics(ind_code, ind_title) values (541512, 'Computer Systems Design Services');
insert into naics(ind_code, ind_title) values (541513, 'Computer Facilities Management Services');
insert into naics(ind_code, ind_title) values (541519, 'Other Computer Related Services');
insert into naics(ind_code, ind_title) values (541715, 'Research and Development in the Physical, Engineering, and Life Sciences');
insert into naics(ind_code, ind_title) values (611420, 'Computer Training');

--company
insert into company(comp_id, comp_name, comp_city, comp_street, comp_street_num, comp_state, comp_zip_code, website, ind_code) values (1, 'Flashdog', 'San Antonio', 'Riverside', 51, 'Texas', 78253, 'www.flashdog.com', 511210);
insert into company(comp_id, comp_name, comp_city, comp_street, comp_street_num, comp_state, comp_zip_code, website, ind_code) values (2, 'Yamia', 'Inglewood', 'Chinook', 589, 'California', 90305, 'www.yamida.com', 518210);
insert into company(comp_id, comp_name, comp_city, comp_street, comp_street_num, comp_state, comp_zip_code, website, ind_code) values (3, 'Twiyo', 'Little Rock', 'Village Green', 2064, 'Arkansas', 72209, 'www.twiyo.com', 541511);
insert into company(comp_id, comp_name, comp_city, comp_street, comp_street_num, comp_state, comp_zip_code, website, ind_code) values (4, 'Realbridge', 'Dallas', 'Schiller', 5, 'Texas', 25353, 'www.realbridge.com', 541512);
insert into company(comp_id, comp_name, comp_city, comp_street, comp_street_num, comp_state, comp_zip_code, website, ind_code) values (5, 'Flipopia', 'Rochester', 'Northport', 73, 'New York', 14646, 'www.flipopia.com', 541519);

--position
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id) values ( 23, 'full-time', 100000, 'salary', 1);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id) values ( 24, 'full-time', 90000, 'salary', 1);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id) values ( 25, 'full-time', 80000, 'salary', 2);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id) values ( 26, 'full-time', 20, 'wage', 2);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id) values ( 27, 'full-time', 15, 'wage', 1);

--works
insert into works(per_id, pos_code, start_date, end_date) values (1, 23, to_date ('02 MAY 1997'), to_date ('03 MAY 2002'));
insert into works(per_id, pos_code, start_date, end_date) values (2, 24, to_date ('03 MAY 2001'), to_date ('07 MAY 2019'));
insert into works(per_id, pos_code, start_date, end_date) values (3, 25, to_date ('03 MAY 2001'), to_date ('07 MAY 2019'));
insert into works(per_id, pos_code, start_date, end_date) values (4, 26, to_date ('03 MAY 2001'), to_date ('07 MAY 2011'));
insert into works(per_id, pos_code, start_date, end_date) values (5, 27, to_date ('03 MAY 2001'), to_date ('07 MAY 2019'));


insert into course(c_code, title, description, status, retail_price) values (123, 'Alpacas', 'Alpaca farming', 'active', 100);


insert into section(c_code, sec_no, complete_date, year, offered_by, sec_format) values (123, 101, date '2001-01-01', 2001, 'UNO', 'online');