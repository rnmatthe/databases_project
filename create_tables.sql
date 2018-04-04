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