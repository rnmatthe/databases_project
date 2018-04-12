---------------------------
--drop tables
---------------------------
drop table phone;
drop table works;
drop table requires;
drop table has_prereq;
drop table position;
drop table company;
drop table takes;
drop table has_skill;
drop table person;
drop table core_skill;
drop table job_category;
drop table section;
drop table teaches;
drop table course;
drop table falls_under;
drop table knowledge_skill;
drop table nwcet;
drop table naics;

--------------------------
--create tables
--------------------------

create table person(
	per_id number,
	per_name varchar(30) not null,
	street_name varchar(20),
	street_num number,
	city varchar(20),
	state varchar(20),
	zip_code number(5,0),
	email varchar(25),
	gender varchar(8) check (gender = 'female' or gender = 'male'),

	primary key (per_id)
);

create table phone(
	per_id int,
	phone_num varchar(20),
	phone_type varchar(20) check (phone_type = 'cell' OR phone_type = 'home' OR phone_type = 'work'),

	primary key (per_id, phone_num),
	foreign key (per_id) references person on delete set null
);

create table job_category(
    cate_code number,
    cate_title varchar(20),
    cate_description varchar(20),
    pay_range_high numeric(8,2) check (pay_range_high > 0),
    pay_range_low numeric(8,2) check (pay_range_low > 0),
    parent_cate number,
    
    primary key (cate_code)
);

create table position(
	pos_code number,
	emp_mode varchar(10) check (emp_mode = 'full-time' or emp_mode = 'part-time'),
	pay_rate number,
	pay_type varchar(10) check (pay_type = 'salary' or pay_type = 'wage'),
	comp_id number,
    cate_code number,

	primary key (pos_code),
    foreign key (cate_code) references job_category
);

create table naics(
    ind_code number,
    ind_title varchar(72),
    parent_ind number,
    
    primary key (ind_code)
);

create table company(
	comp_id number,
    comp_name varchar(20),
    comp_city varchar(20),
	comp_street varchar(20),
    comp_street_num number,
    comp_state varchar(20),
	comp_zip_code number(5,0),
	website varchar(20),
    ind_code number,

	primary key (comp_id),
    foreign key (ind_code) references naics
);

create table works(
    per_id number,
    pos_code number,
    start_date date,
    end_date date,
    
    primary key (per_id, pos_code),
    foreign key (per_id) references person,
    foreign key (pos_code) references position
);

create table course(
	c_code number,
	title varchar(20),
	description varchar(50),
	status varchar(8) check (status = 'expired' or status = 'active'),
	retail_price number check (retail_price > 0),
	course_level varchar(8),

	primary key (c_code)
);

create table section(
    c_code number,
    sec_no number,
    complete_date date,
    year number,
    offered_by varchar(20),
    sec_format varchar(20),

    primary key (sec_no, c_code, complete_date),
    foreign key (c_code) references course
);

create table knowledge_skill(
    ks_code number,
    title varchar(10),
    description varchar(40),
    skill_level varchar(8),
    
    primary key (ks_code)
);

create table nwcet(
    cc_code varchar(4),
    title varchar(50),
    
    primary key (cc_code)
);

create table falls_under(
    ks_code number,
    cc_code varchar(4),
    
    primary key (ks_code, cc_code),
    foreign key (ks_code) references knowledge_skill,
    foreign key (cc_code) references nwcet
);

create table requires(
    pos_code number,
    ks_code number,
    prefer varchar(12) check (prefer = 'not prefered' or prefer = null),
    
    primary key (pos_code, ks_code),
    foreign key (pos_code) references position,
    foreign key (ks_code) references knowledge_skill
);

create table teaches(
    c_code number,
    ks_code number,
    
    primary key (c_code, ks_code),
    foreign key (c_code) references course,
    foreign key (ks_code) references knowledge_skill
);

create table core_skill(
    cate_code number,
    cc_code varchar(4),
    
    primary key (cate_code, cc_code),
    foreign key (cate_code) references job_category,
    foreign key (cc_code) references nwcet
);

create table has_skill(
    ks_code number,
    per_id number,
    
    primary key (ks_code, per_id),
    foreign key (ks_code) references knowledge_skill,
    foreign key (per_id) references person
);

create table takes(
    per_id number,
    c_code number,
    sec_no number,
    complete_date date,
    
    primary key (per_id, c_code),
    foreign key (per_id) references person,
    foreign key (c_code, sec_no, complete_date) references section
);

create table has_prereq(
    c_code number,
    prereq_code number,
    
    primary key (c_code, prereq_code),
    foreign key (c_code) references course
);


-----------------------
--insertions
------------------------

--person
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (1, 'Lolita Pottberry', '4th', 6, 'Albany', 'New York', 12262, 'lpottberry0@blog.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (2, 'Lemar Iban', 'Oxford', 156, 'Winston', 'North Carolina', 27157, 'lban1@ow.ly', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (3, 'Ferdinande Koche', 'Maple Wood', 201, 'Asheville', 'North Carolina', 28805, 'fkoche2@tinypic.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (4, 'Tobiah Faveryear', 'Hayes', 107, 'Rockville', 'Maryland', 20851, 'tfaveryear3@cdc.gov', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (5, 'Elke Lenham', 'Arkansas', 202, 'Miami', 'Florida', 33129, 'elenham4@marr.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (6, 'Harli Ives', 'Prairie Rose', 5, 'Hampton', 'Virginia', 23663, 'hives5@ocn.ne.jp', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (7, 'Adria De Ath', 'Golf', 08907, 'Washington', 'District of Columbia', 20430, 'ade6@kickstarter.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (8, 'Karola Hayball', 'Daystar', 9236, 'Springfield', 'Virginia', 22156, 'khayball7@loc.gov', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (9, 'Shurwood Sappy', 'Northridge', 671, 'New York City', 'New York', 10060, 'ssappy8@desdev.cn', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (10, 'Alison Stanbridge', 'Bluejay', 97848, 'El Paso', 'Texas', 88535, 'astanbridge9@google.ru', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (11, 'Archie Chatelain', 'Lillian', 87249, 'Norwalk', 'Connecticut', 06859, 'achatelaina@netlog.com', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (12, 'Franky Greenroyd', 'Stone Corner', 26, 'Raleigh', 'North Carolina', 27621, 'fgreenroydb@cornell.edu', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (13, 'Dorian Ludovici', 'Westerfield', 62992, 'Austin', 'Texas', 78726, 'dludovicic@omniture.com', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (14, 'Kristyn Aires', 'Onsgard', 5, 'Washington', 'District of Columbia', 20078, 'kairesd@alexa.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (15, 'Tulley Tippett', 'Bartillon', 5000, 'San Diego', 'California', 92170, 'ttippette@theatlantic.com', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (16, 'Tammie Dudin', 'Texas', 77371, 'Topeka', 'Kansas', 66622, 'tdudinf@diigo.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (17, 'Monika Fossick', 'Victoria', 5, 'Portsmouth', 'New Hampshire', 03804, 'mfossickg@springer.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (18, 'Adler Clementi', 'Oak', 57, 'El Paso', 'Texas', 88541, 'aclementih@digg.com', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (19, 'Alberto MacKnight', 'Nelson', 7, 'Fort Myers', 'Florida', 33913, 'amacknighti@biglobe.ne.jp', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (20, 'Damara Planks', 'Warbler', 93072, 'Newport News', 'Virginia', 23605, 'dplanksj@acquiret.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (21, 'Joli Chaff', 'Kenwood', 960, 'Seattle', 'Washington', 98195, 'jchaffk@hostgator.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (22, 'Sayres Le Provost', 'Roxbury', 54911, 'Newark', 'Delaware', 19729, 'slel@jimdo.com', 'male');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (23, 'Berna Brimmicombe', 'Pepper Wood', 74, 'Amarillo', 'Texas', 79116, 'bbrimmi@qcast.com', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (24, 'Catharina Donaway', 'Anderson', 02, 'Aurora', 'Colorado', 80015, 'cdonaway@mozilla.org', 'female');
insert into person (per_id, per_name, street_name, street_num, city, state, zip_code, email, gender) values (25, 'Tamar Jerrolt', 'Montana', 8, 'San Diego', 'California', 92165, 'tjerrolto@sfgate.com', 'female');


--job_category
insert into job_category(cate_code, cate_title, cate_description, pay_range_high, pay_range_low, parent_cate) values (78, 'DB Admin', 'Database Admin', 20000, 10000, null);
insert into job_category(cate_code, cate_title, cate_description, pay_range_high, pay_range_low, parent_cate) values (79, 'Graphic designer', 'create graphics', 10000, 1000, null);
insert into job_category(cate_code, cate_title, cate_description, pay_range_high, pay_range_low, parent_cate) values (80, 'C. Designer', 'Character designer', 10000, 1000, 79);


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

--NWCET
insert into nwcet(cc_code, title) values ('DDA', 'Database Development and Administration');
insert into nwcet(cc_code, title) values ('DM', 'Digital Media');
insert into nwcet(cc_code, title) values ('ESAI', 'Enterprise Systems Analysis and Integration');
insert into nwcet(cc_code, title) values ('NDA', 'Network Design and Administration');
insert into nwcet(cc_code, title) values ('PSE', 'Programming/Software Engineering');
insert into nwcet(cc_code, title) values ('TS', 'Technical Support');
insert into nwcet(cc_code, title) values ('WDA', 'Web Development and Administration');

--position
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values ( 23, 'full-time', 100000, 'salary', 1, 78);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values ( 24, 'full-time', 90000, 'salary', 1, 78);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values ( 25, 'full-time', 80000, 'salary', 2, 78);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values ( 26, 'full-time', 20, 'wage', 2, 78);
insert into position(pos_code, emp_mode, pay_rate, pay_type, comp_id, cate_code) values ( 27, 'full-time', 15, 'wage', 1, 78);

--works
insert into works(per_id, pos_code, start_date, end_date) values (1, 23, to_date ('02 MAY 1997'), to_date ('03 MAY 2002'));
insert into works(per_id, pos_code, start_date, end_date) values (1, 24, to_date ('02 MAY 1997'), to_date ('03 MAY 2020'));
insert into works(per_id, pos_code, start_date, end_date) values (7, 24, to_date ('02 MAY 2000'), to_date ('03 MAY 2020'));
insert into works(per_id, pos_code, start_date, end_date) values (7, 23, to_date ('02 MAY 1997'), to_date ('03 MAY 2000'));
insert into works(per_id, pos_code, start_date, end_date) values (2, 24, to_date ('03 MAY 2001'), to_date ('03 MAY 2020'));
insert into works(per_id, pos_code, start_date, end_date) values (3, 25, to_date ('03 MAY 2001'), to_date ('03 MAY 2020'));
insert into works(per_id, pos_code, start_date, end_date) values (4, 26, to_date ('03 MAY 2001'), to_date ('07 MAY 2011'));
insert into works(per_id, pos_code, start_date, end_date) values (5, 27, to_date ('03 MAY 2001'), to_date ('03 MAY 2020'));
insert into works(per_id, pos_code, start_date, end_date) values (8, 26, to_date ('03 MAY 2001'), to_date ('07 MAY 2021'));

--knowledge skill
insert into knowledge_skill(ks_code, title, description, skill_level) values (346, 'MySQL', 'query language', 'medium');
insert into knowledge_skill(ks_code, title, description, skill_level) values (478, 'Java', 'object oriented programming language', 'beginner');
insert into knowledge_skill(ks_code, title, description, skill_level) values (301, 'FireAlpaca', 'digital art program', 'beginner');
insert into knowledge_skill(ks_code, title, description, skill_level) values (451, 'JavaScript', 'scripting language', 'medium');

--falls under
insert into falls_under(ks_code, cc_code) values ( 346, 'DDA');
insert into falls_under(ks_code, cc_code) values ( 478, 'PSE');
insert into falls_under(ks_code, cc_code) values ( 301, 'DM');
insert into falls_under(ks_code, cc_code) values ( 451, 'WDA');

--has_skill
insert into has_skill(per_id, ks_code) values (1, 346);
insert into has_skill(per_id, ks_code) values (1, 301);
insert into has_skill(per_id, ks_code) values (2, 301);
insert into has_skill(per_id, ks_code) values (5, 346);
insert into has_skill(per_id, ks_code) values (5, 478);
insert into has_skill(per_id, ks_code) values (6, 478);
insert into has_skill(per_id, ks_code) values (6, 346);
insert into has_skill(per_id, ks_code) values (7, 301);
insert into has_skill(per_id, ks_code) values (8, 346);
insert into has_skill(per_id, ks_code) values (8, 301);

--requires
insert into requires(pos_code, ks_code, prefer) values (23, 346, null);
insert into requires(pos_code, ks_code, prefer) values (23, 478, null);
insert into requires(pos_code, ks_code, prefer) values (23, 301, null);
insert into requires(pos_code, ks_code, prefer) values (26, 346, null);
insert into requires(pos_code, ks_code, prefer) values (26, 478, null);
insert into requires(pos_code, ks_code, prefer) values (26, 301, null);
insert into requires(pos_code, ks_code, prefer) values (26, 451, null);
insert into requires(pos_code, ks_code, prefer) values (24, 346, null);
insert into requires(pos_code, ks_code, prefer) values (24, 301, null);
insert into requires(pos_code, ks_code, prefer) values (25, 346, null);
insert into requires(pos_code, ks_code, prefer) values (25, 301, null);


--course
insert into course(c_code, title, description, status, retail_price) values (123, 'Specail Topics', 'Survey of different topics', 'active', 300);
insert into course(c_code, title, description, status, retail_price) values (223, 'Adv. Specail Topics', 'Adv. Survey of different topics', 'active', 200);
insert into course(c_code, title, description, status, retail_price) values (238, 'Web and Other', 'Web dev and other stuff', 'active', 200);
insert into course(c_code, title, description, status, retail_price) values (350, 'Digital Art', 'FireAlpaca use and practice', 'active', 200);
insert into course(c_code, title, description, status, retail_price) values (187, 'Web Design', 'Web Design and Development', 'active', 200);

--teaches
insert into teaches(c_code, ks_code) values (123, 346);
insert into teaches(c_code, ks_code) values (123, 478);
insert into teaches(c_code, ks_code) values (223, 346);
insert into teaches(c_code, ks_code) values (223, 478);
insert into teaches(c_code, ks_code) values (223, 301);
insert into teaches(c_code, ks_code) values (238, 346);
insert into teaches(c_code, ks_code) values (238, 451);
insert into teaches(c_code, ks_code) values (350, 301);
insert into teaches(c_code, ks_code) values (187, 301);
insert into teaches(c_code, ks_code) values (187, 451);

--section
insert into section(c_code, sec_no, complete_date, year, offered_by, sec_format) values (123, 601, to_date('10 MAY 2019'), 2019, 'UNO', 'online');
insert into section(c_code, sec_no, complete_date, year, offered_by, sec_format) values (223, 601, to_date('10 MARCH 2019'), 2019, 'UNO', 'online');
insert into section(c_code, sec_no, complete_date, year, offered_by, sec_format) values (123, 101, date '2001-01-01', 2001, 'UNO', 'online');
insert into section(c_code, sec_no, complete_date, year, offered_by, sec_format) values (223, 201, to_date('10 MARCH 2019'), 2019, 'UNO', 'online');

--core_skill
insert into core_skill(cate_code, cc_code) values (78, 'DDA');
insert into core_skill(cate_code, cc_code) values (78, 'DM');
insert into core_skill(cate_code, cc_code) values (79, 'DM');