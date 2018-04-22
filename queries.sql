--1------people who work for a specific company
SELECT DISTINCT per_name
FROM person, works, position, company
WHERE person.per_id = works.per_id AND position.comp_id = company.comp_id
AND position.pos_code = works.pos_code
AND comp_name = 'Flashdog';
      
--2--------------list salaries of a comp desc order 
WITH salaries AS (SELECT per_id, pos_code, pay_rate
                  FROM works NATURAL JOIN position
                  WHERE end_date > SYSDATE
                  AND pay_type = 'salary')
SELECT per_name, pay_rate
FROM person NATURAL JOIN salaries
ORDER BY pay_rate DESC;

--3-------comp's total costs in desc order------
SELECT comp_id, SUM( CASE
                         WHEN pay_type = 'salary' THEN pay_rate
                         ELSE pay_rate * 1920
                     END) AS total_cost
FROM works NATURAL JOIN position
WHERE works.end_date > SYSDATE
GROUP BY comp_id
ORDER BY total_cost;
                     
--4------positions a person is working in now or in the past
SELECT person.per_id, person.per_name, works.pos_code
FROM person, works
WHERE person.per_id = works.per_id
AND person.per_id = 1;

--5-----skill code and title that a person has-------
SELECT knowledge_skill.ks_code, knowledge_skill.title
FROM has_skill, knowledge_skill
WHERE has_skill.ks_code = knowledge_skill.ks_code
AND per_id = 1;

--6-----skill gap b/t a worker's position and their skills
WITH needed_skills AS (SELECT ks_code
                  FROM requires, works
                  WHERE requires.pos_code = works.pos_code
                  AND works.per_id = 1
                  AND works.end_date < SYSDATE )
SELECT ks_code
FROM needed_skills MINUS (SELECT ks_code
                          FROM has_skill 
                          WHERE per_id = 1);

--7---required knowledge skills of a specific job, and of a specific category (2 queries)
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
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23)
SELECT ks_code
FROM needed_skills MINUS (SELECT ks_code
                          FROM has_skill
                          WHERE per_id = 2);
                          
--9---courses that alone teach all the missing knowledge
WITH skills_needed AS ((SELECT ks_code
                       FROM requires
                       WHERE requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2))
SELECT DISTINCT c_code
FROM course P
WHERE NOT EXISTS ((SELECT *
                   FROM skills_needed)
                   MINUS
                  (SELECT ks_code
                   FROM teaches T
                   WHERE T.c_code = P.c_code));

--10----find quickest course to get skills
WITH skills_needed AS ((SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23)
                       MINUS
                       (SELECT ks_code
                        FROM has_skill
                        WHERE per_id = 2)),
    relevent_sections AS (SELECT c_code, title, sec_no, complete_date
                         FROM section NATURAL JOIN (SELECT c_code
                                                    FROM course P
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
WITH skills_needed AS ((SELECT ks_code
                       FROM requires
                       WHERE requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2)),
    relevent_sections AS (SELECT c_code, title, sec_no, complete_date, retail_price
                          FROM section NATURAL JOIN (SELECT c_code, retial_price
                                                     FROM course P
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

--12--SIMPLIFIED
WITH needed_skills AS ((SELECT ks_code
                        FROM requires
                        WHERE pos_code = 26)
                        MINUS
                       (SELECT ks_code
                        FROM has_skill
                        WHERE per_id = 3)),
     relevent_courses AS (SELECT DISTINCT (c_code), ks_code
                          FROM teaches NATURAL JOIN needed_skills),
     c1 AS (SELECT *
            FROM relevent_courses),
     c2 AS (SELECT *
            FROM relevent_courses),
     c3 AS (SELECT *
            FROM relevent_courses),
     all_poss AS (SELECT DISTINCT c1.c_code AS c1_code, c2.c_code AS c2_code, c3.c_code AS c3_code
                  FROM c1, c2, c3
                  WHERE c1.c_code < c2.c_code
                  AND c2.c_code < c3.c_code),
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
     sets_of_two AS (SELECT c1.c_code AS c1_code, c2.c_code AS c2_code
                     FROM c1, c2
                     WHERE c1.c_code < c2.c_code),
     legit_two AS (SELECT c1_code, c2_code
                   FROM sets_of_two P
                   WHERE NOT EXISTS ((SELECT ks_code
                                      FROM needed_skills)
                                      MINUS
                                     (SELECT ks_code
                                      FROM teaches T
                                      WHERE T.c_code = P.c1_code
                                      OR T.c_code = P.c2_code))),
     legit_three AS (SELECT *
                     FROM covers_all P
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
     not_legit_three AS ((SELECT *
                          FROM covers_all)
                          MINUS
                         (SELECT *
                          FROM legit_three)),
     combine AS ((SELECT c1_code, c2_code, CASE
                                            WHEN EXISTS (SELECT c1_code, c2_code
                                                         FROM legit_two T
                                                         WHERE P.c1_code = T.c1_code
                                                         AND P.c2_code = T.c2_code)
                                            THEN null
                                            ELSE c3_code 
                                            END AS c3_code
                  FROM covers_all P)
                  MINUS
                 (SELECT *
                  FROM not_legit_three)),
     costs AS (SELECT c1_code, c2_code, c3_code, SUM(retail_price) AS total_cost
               FROM combine, course
               WHERE course.c_code = combine.c1_code
               OR course.c_code = combine.c2_code
               OR course.c_code = combine.c3_code
               GROUP BY c1_code, c2_code, c3_code)
                 
SELECT *
FROM costs
ORDER BY total_cost ASC;

--13--job categories that they're qualified for
WITH person_cc AS (SELECT cc_code
                   FROM has_skill NATURAL JOIN knowledge_skill
                   WHERE has_skill.per_id = 1) 
SELECT JC.cate_code, JC.cate_title
FROM job_category JC
WHERE NOT EXISTS ((SELECT cc_code
                   FROM core_skill CS
                   WHERE JC.cate_code = CS.cate_code)
                   MINUS
                  (SELECT cc_code
                   FROM person_cc)); 

--14--position with highest payrate according to their skills given pid 
WITH per_skills AS (SELECT ks_code
                    FROM has_skill
                    WHERE per_id = 1),
     qualified_for AS (SELECT DISTINCT pos_code
                       FROM position R
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
WITH needed_skills AS (SELECT ks_code 
                       FROM requires
                       WHERE pos_code = 23),
     missing_skills AS ((SELECT per_id, ks_code
                         FROM person, needed_skills)
                        MINUS
                         (SELECT per_id, ks_code
                          FROM has_skill))
SELECT DISTINCT ks_code, COUNT(per_id)                      
FROM missing_skills
GROUP BY ks_code;

--18--ppl who miss the least number and report the least number
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

--21----people who once held a job category - per_id, name, possition title,
--start and end year
SELECT person.per_id, per_name, position.pos_code, EXTRACT(YEAR FROM start_date) AS start_year, EXTRACT(YEAR FROM end_date) AS end_year
FROM person, works, position
WHERE cate_code = 78
AND end_date < SYSDATE
AND person.per_id = works.per_id
AND works.pos_code = position.pos_code;

--22--unemployed ppl once held position
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
----biggest employer in terms of number of employees 
WITH num_employees AS (SELECT comp_id, COUNT(per_id) AS num_emp
                       FROM works NATURAL JOIN position
                       WHERE end_date > SYSDATE
                       GROUP BY comp_id),
     max_num AS (SELECT MAX(num_emp) AS max_emp
                 FROM num_employees)
SELECT comp_id, num_emp
FROM num_employees, max_num
WHERE num_emp = max_emp;

---by number paid each employee 
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

--ratio of increased to decreased
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
                   WHERE current_pay.per_id = most_recent.per_id),
    increased AS (SELECT COUNT (per_id) AS num_inc
                  FROM difference
                  WHERE pay_change > 0),
    decreased AS (SELECT COUNT (per_id) AS num_dec
                  FROM difference
                  WHERE pay_change < 0)
SELECT *
FROM increased, decreased;

--average earning change rate for people in a particular sector
WITH past_jobs AS (SELECT per_id, pos_code, end_date, CASE
                                                      WHEN pay_type = 'salary'
                                                      THEN pay_rate
                                                      ELSE pay_rate * 1920
                                                      END AS pay
                   FROM works NATURAL JOIN position NATURAL JOIN company
                   WHERE end_date < SYSDATE
                   AND ind_code = 511210),
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
                    FROM works NATURAL JOIN position NATURAL JOIN company
                    WHERE end_date > SYSDATE
                    AND ind_code = 511210),
    difference AS (SELECT DISTINCT current_pay.per_id, current_pay.pay - most_recent.pay AS pay_change
                   FROM current_pay, most_recent
                   WHERE current_pay.per_id = most_recent.per_id)
SELECT AVG(pay_change)
FROM difference;

--26--max vacancies due to unqualfied workers
WITH leaf_cate AS (SELECT cate_code
                   FROM job_category T
                   WHERE NOT EXISTS (SELECT parent_cate
                                     FROM job_category P
                                     WHERE P.parent_cate = T.cate_code)),
     emp_pos AS (SELECT pos_code, cate_code
                 FROM position P
                 WHERE NOT EXISTS (SELECT pos_code
                                   FROM works W
                                   WHERE P.pos_code = W.pos_code
                                   AND W.end_date > SYSDATE)),
     vacancies AS (SELECT cate_code, COUNT(pos_code) AS num_vac
                   FROM leaf_cate NATURAL JOIN emp_pos
                   GROUP BY cate_code),
     unemployed AS (SELECT per_id
                    FROM person P
                    WHERE NOT EXISTS (SELECT pos_code
                                      FROM works W
                                      WHERE w.per_id = P.per_id
                                      AND W.end_date > SYSDATE)),
     setup AS (SELECT cate_code, pos_code, per_id
               FROM unemployed, emp_pos),
     qualified_people AS (SELECT cate_code, per_id
                          FROM setup T
                          WHERE NOT EXISTS ((SELECT ks_code
                                             FROM requires P
                                             WHERE P.pos_code = T.pos_code
                                             MINUS
                                            (SELECT ks_code
                                             FROM has_skill H
                                             WHERE H.per_id = T.per_id)))),
     
     total_qual AS (SELECT cate_code, COUNT(per_id) AS num_qual
                    FROM qualified_people
                    GROUP BY cate_code),
     diff AS (SELECT cate_code, num_vac - num_qual AS real_num
              FROM total_qual NATURAL JOIN vacancies),
     max_vac AS (SELECT MAX(real_num) AS max_num
                 FROM diff)
SELECT cate_code, real_num
FROM diff, max_vac
WHERE real_num = max_num;

--27--course that would make the most jobless people qualified for that category
WITH leaf_cate AS (SELECT cate_code
                   FROM job_category T
                   WHERE NOT EXISTS (SELECT parent_cate
                                     FROM job_category P
                                     WHERE P.parent_cate = T.cate_code)),
     emp_pos AS (SELECT pos_code, cate_code
                 FROM position P
                 WHERE NOT EXISTS (SELECT pos_code
                                   FROM works W
                                   WHERE P.pos_code = W.pos_code
                                   AND W.end_date > SYSDATE)),
     vacancies AS (SELECT cate_code, COUNT(pos_code) AS num_vac
                   FROM leaf_cate NATURAL JOIN emp_pos
                   GROUP BY cate_code),
     unemployed AS (SELECT per_id
                    FROM person P
                    WHERE NOT EXISTS (SELECT pos_code
                                      FROM works W
                                      WHERE w.per_id = P.per_id
                                      AND W.end_date > SYSDATE)),
     setup AS (SELECT cate_code, pos_code, per_id
               FROM unemployed, emp_pos),
     qualified_people AS (SELECT cate_code, per_id, pos_code
                          FROM setup T
                          WHERE NOT EXISTS ((SELECT ks_code
                                             FROM requires P
                                             WHERE P.pos_code = T.pos_code
                                             MINUS
                                            (SELECT ks_code
                                             FROM has_skill H
                                             WHERE H.per_id = T.per_id)))),
     
     total_qual AS (SELECT cate_code, COUNT(per_id) AS num_qual
                    FROM qualified_people
                    GROUP BY cate_code),
     diff AS (SELECT cate_code, num_vac - num_qual AS real_num
              FROM total_qual NATURAL JOIN vacancies),
     max_vac AS (SELECT MAX(real_num) AS max_num
                 FROM diff),
     relevent_cate AS (SELECT cate_code
                       FROM diff, max_vac
                       WHERE real_num = max_num),
     unqualified_people AS ((SELECT per_id
                             FROM unemployed)
                             MINUS
                            (SELECT per_id
                             FROM qualified_people NATURAL JOIN relevent_cate)),
     relevent_pos AS (SELECT pos_code, ks_code
                      FROM position NATURAL JOIN requires NATURAL JOIN relevent_cate),
     setup_courses AS (SELECT c_code, per_id
                       FROM unqualified_people, course),
     qualifies AS (SELECT c_code, COUNT(per_id) AS num_qual
                   FROM setup_courses M
                   WHERE EXISTS (SELECT pos_code
                                 FROM relevent_pos P
                                 WHERE NOT EXISTS (((SELECT ks_code
                                                    FROM relevent_pos T
                                                    WHERE P.pos_code = T.pos_code)
                                                    MINUS
                                                   (SELECT ks_code
                                                    FROM has_skill H
                                                    WHERE H.per_id = M.per_id))
                                                    MINUS
                                                   (SELECT ks_code
                                                    FROM teaches E
                                                    WHERE E.c_code = M.c_code)))
                  GROUP BY c_code),
     max_qualifies AS (SELECT MAX(num_qual) AS max_num
                       FROM qualifies)
SELECT c_code, num_qual
FROM qualifies, max_qualifies
WHERE max_num = num_qual;
                       