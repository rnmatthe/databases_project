---------------------------
--drop tables
---------------------------
drop table phone;
drop table comp_naics;
drop table works;
drop table requires;
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
	email varchar(20),
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

create table position(
	pos_code number,
	emp_mode varchar(10) check (emp_mode = 'full-time' or emp_mode = 'part-time'),
	pay_rate number,
	pay_type varchar(10),
	comp_id number,

	primary key (pos_code)
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
	description varchar(30),
	status varchar(8) check (status = 'expired' or status = 'active'),
	retail_price number check (retail_price > 0),

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
    description varchar(20),
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

create table job_category(
    cate_code number,
    cate_title varchar(20),
    cate_description varchar(20),
    pay_range_high numeric(8,2) check (pay_range_high > 0),
    pay_range_low numeric(8,2) check (pay_range_low > 0),
    parent_cate number,
    
    primary key (cate_code)
);

create table core_skill(
    cate_code number,
    ks_code number,
    
    primary key (cate_code, ks_code),
    foreign key (cate_code) references job_category,
    foreign key (ks_code) references knowledge_skill
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

create table comp_naics(
    comp_id number,
    ind_code number,
    
    primary key (comp_id, ind_code),
    foreign key (ind_code) references naics,
    foreign key (comp_id) references company
);


-----------------------
--insertions
------------------------

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
