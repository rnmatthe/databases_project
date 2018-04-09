--1------people who work for a specific company
-------tested sufficiently
SELECT per_name
FROM person, works, position, company
WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id
AND position.pos_code = works.pos_code
AND comp_name = 'Flashdog';
      
--2--------------list salaries of a comp desc order 
-----------------sufficiently tested, including job history
WITH salaries AS (SELECT per_id, pay_rate
                  FROM works, position
                  WHERE works.pos_code = position.pos_code
                  AND works.end_date > SYSDATE
                  AND position.pay_type = 'salary')
SELECT person.per_name, position.pay_rate
FROM works, salaries, person, position
WHERE works.per_id = salaries.per_id
AND person.per_id = salaries.per_id
AND works.pos_code = position.pos_code
AND position.comp_id = 1
ORDER BY salaries.pay_rate DESC;

--3-------comp's total costs in desc order------
----------checked with hourly and salary, and with job histories
SELECT comp_id, SUM( CASE
                         WHEN pay_type = 'salary' THEN pay_rate
                         ELSE pay_rate * 1920
                     END) AS total_cost
FROM works NATURAL JOIN position
WHERE works.end_date > SYSDATE
GROUP BY comp_id
ORDER BY total_cost;
                     
--4------positions a person is working in now or in the past
-----tested sufficiently
SELECT person.per_id, person.per_name, works.pos_code
FROM person, works
WHERE person.per_id = works.per_id
AND person.per_id = 1;

--5-----skill code and title that a person has-------
-----tested, works
SELECT knowledge_skill.ks_code, knowledge_skill.title
FROM has_skill, knowledge_skill
WHERE has_skill.ks_code = knowledge_skill.ks_code
AND per_id = 1;

--6-----skill gap b/t a worker's position and their skills
-----tested, works
WITH needed_skills AS (SELECT knowledge_skill.ks_code, knowledge_skill.title
                  FROM knowledge_skill, requires, works
                  WHERE knowledge_skill.ks_code = requires.ks_code
                  AND requires.pos_code = works.pos_code
                  AND works.per_id = 1
                  AND works.end_date < to_date (SYSDATE) )
SELECT ks_code, title
FROM needed_skills MINUS (SELECT knowledge_skill.ks_code, knowledge_skill.title
                          FROM has_skill, knowledge_skill
                          WHERE has_skill.ks_code = knowledge_skill.ks_code
                          AND has_skill.per_id = 1);

--7---required knowledge skills of a specific job, and of a specific category (2 queries)
------tested, works
WITH position_skills as (SELECT requires.pos_code, knowledge_skill.title, knowledge_skill.ks_code
                         FROM requires, knowledge_skill
                         WHERE requires.ks_code = knowledge_skill.ks_code
                         AND requires.pos_code = 23)
SELECT pos_code, title required_skill, ks_code
FROM position_skills;

WITH category_skills as (SELECT core_skill.cate_code, knowledge_skill.title, knowledge_skill.ks_code
                         FROM core_skill, falls_under, knowledge_skill
                         WHERE knowledge_skill.ks_code = falls_under.ks_code
                         AND core_skill.cc_code = falls_under.cc_code
                         AND core_skill.cate_code = 78)
SELECT cate_code, title required_skill, ks_code
FROM category_skills;


--8------person's missing skills for a specific pos_code
---------tested, works
WITH needed_skills AS (SELECT knowledge_skill.ks_code, knowledge_skill.title
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 23)
SELECT ks_code, title
FROM needed_skills MINUS (SELECT has_skill.ks_code, knowledge_skill.title
                          FROM has_skill, knowledge_skill
                          WHERE per_id = 2
                          AND has_skill.ks_code = knowledge_skill.ks_code);
                          
--9---courses that alone teach all the missing knowledge
-----tested, works
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2))
SELECT DISTINCT(c_code), title
FROM course NATURAL JOIN (SELECT c_code
                          FROM teaches P
                          WHERE NOT EXISTS ((SELECT *
                                             FROM skills_needed)
                                             MINUS
                                            (SELECT ks_code
                                             FROM teaches T
                                             WHERE T.c_code = P.c_code))
                         );

--10----find quickest course to get skills
--------tested, works
WITH skills_needed AS ((SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23)
                       MINUS
                       (SELECT ks_code
                        FROM has_skill
                        WHERE per_id = 2)),
    relevent_sections AS (SELECT c_code, title, sec_no, complete_date
                         FROM section NATURAL JOIN course NATURAL JOIN (SELECT c_code
                                                                        FROM teaches P
                                                                        WHERE NOT EXISTS ((SELECT *
                                                                        FROM skills_needed)
                                                                        MINUS
                                                                       (SELECT ks_code
                                                                        FROM teaches T
                                                                        WHERE T.c_code = P.c_code))
                                                                        )
                         WHERE section.complete_date > SYSDATE 
                         ),
    closest_date AS (SELECT MIN(complete_date) AS min_date
                     FROM relevent_sections)
SELECT DISTINCT c_code, title, sec_no, complete_date
FROM relevent_sections, closest_date
WHERE complete_date = min_date;

--11----cheapest course to fill skill gap
---------tested, works
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2)),
    relevent_sections AS (SELECT c_code, title, sec_no, complete_date, retail_price
                          FROM section NATURAL JOIN course NATURAL JOIN (SELECT c_code
                                                                         FROM teaches P
                                                                         WHERE NOT EXISTS ((SELECT *
                                                                                            FROM skills_needed)
                                                                                            MINUS
                                                                                           (SELECT ks_code
                                                                                            FROM teaches T
                                                                                            WHERE T.c_code = P.c_code))
                                                                         )
                          WHERE section.complete_date > SYSDATE
                          ORDER BY course.retail_price
                          ),
    cheapest AS (SELECT MIN(retail_price) AS retail_price
                 FROM relevent_sections)
SELECT DISTINCT c_code, title, sec_no, complete_date, retail_price
FROM relevent_sections NATURAL JOIN cheapest;                      

--12--course sets that would make someone qualified (3 or less)
-----tested, works
WITH needed_skills AS ((SELECT ks_code
                       FROM requires
                       WHERE pos_code = 26)
                       MINUS
                      (SELECT ks_code
                       FROM has_skill
                       WHERE per_id = 3)),
                       
     relevent_courses AS (SELECT DISTINCT(c_code), ks_code
                          FROM teaches NATURAL JOIN needed_skills),
     c1 AS (SELECT *
            FROM relevent_courses),
     c2 AS (SELECT *
            FROM relevent_courses),
     c3 AS (SELECT *
            FROM relevent_courses),
     all_poss AS (SELECT DISTINCT c1.c_code AS c1_code, c2.c_code AS c2_code, c3.c_code AS c3_code
                  FROM c1, c2, c3
                  WHERE c1.c_code != c2.c_code
                  AND c1.c_code != c3.c_code
                  AND c2.c_code != c3.c_code),
     covers_all AS (SELECT *
                    FROM all_poss P
                    WHERE NOT EXISTS ((SELECT ks_code
                                       FROM needed_skills)
                                       MINUS
                                      (SELECT ks_code
                                       FROM teaches T
                                       WHERE T.c_code = P.c1_code
                                       OR T.c_code = P.c2_code
                                       OR T.c_code = P.c3_code)
                                     )
                   ),
     find_two AS (SELECT DISTINCT c1_code, c2_code, CASE
                                                WHEN EXISTS ((SELECT ks_code
                                                              FROM needed_skills)
                                                              MINUS
                                                             (SELECT ks_code
                                                              FROM teaches T
                                                              WHERE T.c_code = P.c1_code 
                                                              OR T.c_code = P.c2_code))
                                                      THEN c3_code
                                                ELSE -1 
                                           END AS c3_code
                  FROM covers_all P),
     legit_three AS (SELECT *
                     FROM find_two P
                     WHERE EXISTS ((SELECT ks_code
                                    FROM needed_skills)
                                    MINUS
                                   (SELECT ks_code
                                    FROM teaches NATURAL JOIN relevent_courses
                                    WHERE c_code = P.c1_code OR c_code = P.c2_code)
                                   )
                    AND EXISTS ((SELECT ks_code
                                 FROM needed_skills)
                                 MINUS
                                (SELECT ks_code
                                 FROM teaches NATURAL JOIN relevent_courses
                                 WHERE c_code = P.c2_code OR c_code = P.c3_code)
                                 )
                    AND EXISTS((SELECT ks_code
                                FROM needed_skills)
                                MINUS
                               (SELECT ks_code
                                FROM teaches NATURAL JOIN relevent_courses
                                WHERE c_code = P.c1_code OR c_code = P.c3_code)
                                )
                    ),
     combine_legit AS (SELECT c1_code, c2_code, c3_code
                       FROM find_two P
                       WHERE c3_code = -1
                       OR EXISTS (SELECT *
                                  FROM legit_three T
                                  WHERE T.c1_code = P.c1_code
                                  AND T.c2_code = P.c2_code
                                  AND T.c3_code = P.c3_code)), 
     remove_duplicates AS (SELECT c1_code, c2_code, c3_code
                           FROM combine_legit P
                           WHERE P.c1_code > P.c2_code
                           AND P.c2_code > P.c3_code),
     get_costs AS (SELECT c1_code, c2_code, c3_code, SUM (retail_price) AS price
                   FROM remove_duplicates, course
                   WHERE c_code = c1_code
                   OR c_code = c2_code
                   OR c_code = c3_code
                   GROUP BY c1_code, c2_code, c3_code)
SELECT c1_code, c2_code, CASE
                            WHEN c3_code = -1
                            THEN ' '
                            ELSE to_char(c3_code)
                         END AS last_code, price
FROM get_costs
ORDER BY price ASC;


--13--job categories that they're qualified for
WITH required_skills AS (SELECT ks_code, cate_code
                         FROM core_skill NATURAL JOIN falls_under),
     qualified_for AS (SELECT DISTINCT cate_code
                       FROM required_skills P
                       WHERE NOT EXISTS ((SELECT ks_code
                                          FROM required_skills T
                                          WHERE T.cate_code = P.cate_code)
                                          MINUS
                                         (SELECT ks_code
                                          FROM has_skill
                                          WHERE per_id = 1)))
SELECT cate_code, cate_title
FROM qualified_for NATURAL JOIN job_category;

--14--position with highest payrate according to their skills given pid 
------tested, works
WITH per_skills AS (SELECT ks_code
                    FROM has_skill
                    WHERE per_id = 1),
     qualified_for AS (SELECT DISTINCT pos_code
                       FROM requires R
                       WHERE NOT EXISTS ((SELECT ks_code
                                          FROM requires P
                                          WHERE P.pos_code = R.pos_code)
                                          MINUS
                                          (SELECT ks_code
                                          FROM per_skills))
                      ),
     max_salary AS (SELECT MAX(pay_rate) AS max_sal
                    FROM qualified_for NATURAL JOIN position
                    WHERE pay_type = 'salary')
SELECT position.pos_code, position.pay_rate
FROM qualified_for, position, max_salary
WHERE qualified_for.pos_code = position.pos_code
AND position.pay_rate = max_salary.max_sal;

--15-----people qualified for a specific job
--------tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 25)
SELECT per_name, email
FROM person P
WHERE NOT EXISTS ((SELECT ks_code
                   FROM needed_skills)
                   MINUS
                  (SELECT ks_code
                   FROM has_skill T
                   WHERE T.per_id = P.per_id));

--16 ------"missing one" skill list
----------tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
     num_skills_req AS (SELECT COUNT(ks_code) AS num
                        FROM needed_skills),
     num_has AS (SELECT per_id, COUNT(ks_code) AS num
                 FROM has_skill NATURAL JOIN needed_skills
                 GROUP BY per_id)
SELECT per_id
FROM num_has, num_skills_req
WHERE num_has.num = num_skills_req.num - 1;

--17------how many people missed each skill-------
---------tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
     num_skills_req AS (SELECT COUNT(ks_code) AS num
                        FROM needed_skills),
     num_has AS (SELECT per_id, COUNT(ks_code) AS num
                 FROM has_skill NATURAL JOIN needed_skills
                 GROUP BY per_id),
     ppl_list AS (SELECT per_id
                  FROM num_has, num_skills_req
                  WHERE num_has.num = num_skills_req.num - 1),
     combine AS (SELECT * 
                 FROM needed_skills, ppl_list)
SELECT ks_code, COUNT(per_id)
FROM combine P
WHERE NOT EXISTS (SELECT *
                  FROM has_skill T
                  WHERE T.per_id = P.per_id
                  AND T.ks_code = P.ks_code)
GROUP BY ks_code;

--18--ppl who miss the least number and report the least number
-----------tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
      missing_skills AS ((SELECT per_id, ks_code
                          FROM person, needed_skills)
                          MINUS
                         (SELECT per_id, ks_code
                          FROM has_skill NATURAL JOIN needed_skills)),
      count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing
                        FROM missing_skills
                        GROUP BY per_id),
      min_missing AS (SELECT MIN(num_missing) AS min_num
                      FROM count_missing)
SELECT per_id, num_missing
FROM count_missing, min_missing
WHERE num_missing = min_num;

--19--missing <= k number of skills, list per_id and num in ascending order of missing
------tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
      missing_skills AS ((SELECT per_id, ks_code
                          FROM person, needed_skills)
                          MINUS
                         (SELECT per_id, ks_code
                          FROM has_skill NATURAL JOIN needed_skills)),
      count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing
                        FROM missing_skills
                        GROUP BY per_id)
SELECT per_id, num_missing
FROM count_missing
WHERE num_missing < 3
ORDER BY num_missing ASC;


--20--- every skill needed by missking-k ppl and num ppl missing it, ascending order
------- tested, works
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
      missing_skills AS ((SELECT per_id, ks_code
                          FROM person, needed_skills)
                          MINUS
                         (SELECT per_id, ks_code
                          FROM has_skill NATURAL JOIN needed_skills)),
      count_missing AS (SELECT per_id, COUNT(ks_code) AS num_missing
                        FROM missing_skills
                        GROUP BY per_id),
      missing_k AS (SELECT per_id, num_missing
                    FROM count_missing
                    WHERE num_missing < 3),
      missing_k_skills AS (SELECT ks_code, COUNT(per_id) AS num_people
                           FROM missing_skills NATURAL JOIN missing_k
                           GROUP BY ks_code)
SELECT ks_code, num_people
FROM missing_k_skills
ORDER BY num_people ASC;

--21----people who once held a job category - per_id, name, possition title, *******************************************************
--start and end year
SELECT person.per_id, per_name, position.pos_code, EXTRACT(YEAR FROM start_date), EXTRACT(YEAR FROM end_date)
FROM person, works, position
WHERE cate_code = 78
AND end_date < SYSDATE
AND person.per_id = works.per_id
AND works.pos_code = position.pos_code;

SELECT per_id
FROM works NATURAL JOIN position;

--22--unemployed ppl once held position
------tested, works
SELECT per_id, per_name
FROM person P
WHERE NOT EXISTS (SELECT pos_code
                  FROM works T
                  WHERE T.per_id = P.per_id
                  AND T.end_date > SYSDATE)
AND EXISTS (SELECT *
            FROM works W
            WHERE W.pos_code = 26
            AND W.per_id = P.per_id);
            
--23--
----biggest employer in terms of number of employees ******************************************************************
WITH num_employees AS (SELECT comp_id, COUNT(per_id) AS num_emp
                       FROM works NATURAL JOIN position
                       WHERE end_date > SYSDATE
                       GROUP BY comp_id),
     max_num AS (SELECT MAX(num_emp) AS max_emp
                 FROM num_employees)
SELECT comp_id, num_emp
FROM num_employees, max_num
WHERE num_emp = max_emp;

---by number paid each employee ***************************************************************************************
WITH amount_paid AS (SELECT per_id, pos_code, comp_id, CASE
                                                       WHEN pay_type = 'salary'
                                                       THEN pay_rate
                                                       ELSE pay_rate * 1920
                                                       END AS pay
                     FROM works NATURAL JOIN position
                     WHERE end_date > SYSDATE),
    total_paid AS (SELECT comp_id, SUM(pay) AS total
                   FROM amount_paid
                   GROUP BY comp_id),
    max_paid AS (SELECT MAX(total) AS max_total
                 FROM total_paid)
SELECT comp_id, total
FROM total_paid, max_paid
WHERE total = max_total;


--24-- job distributions among business sectors
--------------------------max employees and max salaries/wages (two queries)
--max employees:
----tested, works
WITH people_per_sector AS (SELECT ind_code, COUNT(per_id) AS num_people
                           FROM company NATURAL JOIN position NATURAL JOIN works
                           WHERE end_date > SYSDATE
                           GROUP BY ind_code),
     max_people AS (SELECT MAX(num_people) AS max_num
                    FROM people_per_sector)
SELECT ind_code, num_people
FROM people_per_sector, max_people
WHERE num_people = max_num;

--max paid to employees:
-----tested, works
WITH needed_info AS (SELECT ind_code, per_id, pos_code, CASE
                                                        WHEN pay_type = 'salary'
                                                        THEN pay_rate
                                                        ELSE pay_rate * 1920
                                                        END AS payment
                     FROM company NATURAL JOIN position NATURAL JOIN works
                     WHERE end_date > SYSDATE),
     totals AS (SELECT ind_code, SUM(payment) AS total_spent
                FROM needed_info
                GROUP BY ind_code),
     max_spent AS (SELECT MAX(total_spent) AS the_max
                   FROM totals)
SELECT ind_code, total_spent
FROM totals, max_spent
WHERE totals.total_spent = max_spent.the_max;


--25--
--number of people whose earning increased
-----tested, works
WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE
                                                      WHEN pay_type = 'salary'
                                                      THEN pay_rate
                                                      ELSE pay_rate * 1920
                                                      END AS pay
                   FROM works NATURAL JOIN position
                   WHERE end_date < SYSDATE),
    most_recent AS (SELECT per_id, pay, end_date
                    FROM past_jobs P
                    WHERE P.end_date = (SELECT MAX(end_date)
                                        FROM past_jobs T
                                        WHERE T.per_id = P.per_id)
                    ),
    current_pay AS (SELECT per_id, CASE
                                   WHEN pay_type = 'salary'
                                   THEN pay_rate
                                   ELSE pay_rate * 1920
                                   END AS pay
                    FROM works NATURAL JOIN position
                    WHERE end_date > SYSDATE),
    difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change
                   FROM current_pay, most_recent
                   WHERE current_pay.per_id = most_recent.per_id)
SELECT COUNT(per_id)
FROM difference
WHERE pay_change > 0;

---- number whose earnings decreased
----tested, works
WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE
                                                      WHEN pay_type = 'salary'
                                                      THEN pay_rate
                                                      ELSE pay_rate * 1920
                                                      END AS pay
                   FROM works NATURAL JOIN position
                   WHERE end_date < SYSDATE),
    most_recent AS (SELECT per_id, pay, end_date
                    FROM past_jobs P
                    WHERE P.end_date = (SELECT MAX(end_date)
                                        FROM past_jobs T
                                        WHERE T.per_id = P.per_id)
                    ),
    current_pay AS (SELECT per_id, CASE
                                   WHEN pay_type = 'salary'
                                   THEN pay_rate
                                   ELSE pay_rate * 1920
                                   END AS pay
                    FROM works NATURAL JOIN position
                    WHERE end_date > SYSDATE),
    difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change
                   FROM current_pay, most_recent
                   WHERE current_pay.per_id = most_recent.per_id)
SELECT COUNT(per_id)
FROM difference
WHERE pay_change < 0;

--can skip 26, 27, 28