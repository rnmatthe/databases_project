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

--7--

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
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2))
SELECT *
FROM (SELECT c_code, title, sec_no, complete_date
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
     ORDER BY section.complete_date
      )
WHERE rownum = 1;

--11----cheapest course to fill skill gap
---------tested, works
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 23)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 2))
SELECT *
FROM (SELECT c_code, title, sec_no, complete_date, retail_price
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
      )
WHERE rownum = 1;                                                 

--12--course sets that would make someone qualified (3 or less)
WITH needed_skills AS (SELECT ks_code
                        FROM requires
                        WHERE pos_code = 23),
     relevent_courses AS (SELECT c_code
                          FROM teaches NATURAL JOIN needed_skills),
     c1 AS (SELECT *
            FROM relevent_courses),
     c2 AS (SELECT *
            FROM relevent_courses),
     c3 AS (SELECT *
            FROM relevent_courses),
     all_poss AS (SELECT c1.c_code AS c1_code, c2.c_code AS c2_code, c3.c_code AS c3_code
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
     find_two AS (SELECT c1_code, c2_code, CASE
                                                WHEN EXISTS ((SELECT ks_code
                                                              FROM needed_skills)
                                                              MINUS
                                                             (SELECT ks_code
                                                              FROM teaches T
                                                              WHERE T.c_code = P.c1_code 
                                                              OR T.c_code = P.c2_code))
                                                      THEN c3_code
                                                ELSE null
                                           END AS c3_code
                  FROM covers_all P),
     legit_three AS (SELECT *
                     FROM find_two P
                     WHERE NOT EXISTS ( SELECT c1_code, c2_code
                                        FROM find_two T
                                        WHERE T.c1_code = P.c1_code
                                        AND T.c2_code = P.c2_code
                                        AND T.c3_code = null )
                     AND NOT EXISTS ( SELECT c1_code, c2_code
                                      FROM find_two T
                                      WHERE T.c1_code = P.c2_code
                                      AND T.c2_code = P.c1_code
                                      AND T.c3_code = null )
                    ),
     with_costs AS (SELECT c1_code, c2_code, c3_code, course.retail_price
                    FROM legit_three, course
                    WHERE legit_three.c1_code = course.c_code
                    OR legit_three.c2_code = course.c_code
                    OR legit_three.c3_code = course.c_code),
     sum_costs AS (SELECT c1_code, c2_code, c3_code, SUM (retail_price) AS price
                   FROM with_costs 
                   GROUP BY c1_code, c2_code, c3_code),
     concat AS (SELECT CASE
                            WHEN P.c3_code = null 
                            THEN CASE
                                     WHEN P.c1_code < P.c2_code
                                         THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code)
                                     ELSE TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code)
                                 END  
                            ELSE CASE 
                                     WHEN P.c1_code < P.c2_code AND P.c2_code < P.c3_code--123
                                          THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c3_code)
                                     WHEN P.c1_code < P.c3_code AND P.c3_code < P.c2_code--132
                                          THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c2_code)
                                     WHEN P.c2_code < P.c1_code AND P.c1_code < P.c3_code--213
                                          THEN TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c3_code)
                                     WHEN P.c2_code < P.c3_code AND P.c3_code < P.c1_code--231
                                          THEN TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c1_code)
                                     WHEN P.c3_code < P.c1_code AND P.c1_code < P.c2_code--312
                                          THEN TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code)
                                     ELSE TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code)
                                 END   
                       END AS courses, price
                FROM sum_costs P)
SELECT DISTINCT(courses), price
FROM concat
ORDER BY price DESC;


--MESS WITH THIS COPY (below)

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
                                                ELSE null
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
                       WHERE c3_code IS NULL
                       OR EXISTS (SELECT *
                                  FROM legit_three T
                                  WHERE T.c1_code = P.c1_code
                                  AND T.c2_code = P.c2_code
                                  AND T.c3_code = P.c3_code)) -----good to this point :D
SELECT *
FROM combine_legit;
                    
                    
     with_costs AS (SELECT c1_code, c2_code, c3_code, course.retail_price
                    FROM legit_three, course
                    WHERE legit_three.c1_code = course.c_code
                    OR legit_three.c2_code = course.c_code
                    OR legit_three.c3_code = course.c_code),
     sum_costs AS (SELECT c1_code, c2_code, c3_code, SUM (retail_price) AS price
                   FROM with_costs 
                   GROUP BY c1_code, c2_code, c3_code),
     concat AS (SELECT CASE
                            WHEN P.c3_code IS NULL
                            THEN CASE
                                     WHEN P.c1_code < P.c2_code
                                         THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code)
                                     ELSE TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code)
                                 END  
                            ELSE CASE 
                                     WHEN P.c1_code < P.c2_code AND P.c2_code < P.c3_code--123
                                          THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c3_code)
                                     WHEN P.c1_code < P.c3_code AND P.c3_code < P.c2_code--132
                                          THEN TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c2_code)
                                     WHEN P.c2_code < P.c1_code AND P.c1_code < P.c3_code--213
                                          THEN TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c3_code)
                                     WHEN P.c2_code < P.c3_code AND P.c3_code < P.c1_code--231
                                          THEN TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c1_code)
                                     WHEN P.c3_code < P.c1_code AND P.c1_code < P.c2_code--312
                                          THEN TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c1_code) || ', ' || TO_CHAR(P.c2_code)
                                     ELSE TO_CHAR(P.c3_code) || ', ' || TO_CHAR(P.c2_code) || ', ' || TO_CHAR(P.c1_code)
                                 END   
                       END AS courses, price
                FROM sum_costs P)
SELECT DISTINCT(courses), price
FROM concat
ORDER BY price ASC;

--13--job categories that they're qualified for

--14--position with highest payrate according to their skills given pid 
WITH qualified_for AS (SELECT pos_code
                       FROM requires R
                       WHERE NOT EXISTS ((SELECT ks_code
                                          FROM requires P
                                          WHERE P.ks_code = R.ks_code)
                                          MINUS
                                         (SELECT ks_code
                                          FROM has_skill
                                          WHERE per_id = 1))),
     max_salary AS (SELECT MAX(pay_rate) AS sal
                    FROM position NATURAL JOIN qualified_for)
SELECT position.pos_code, sal
FROM qualified_for, max_salary, position
WHERE qualified_for.pos_code = position.pos_code
AND position.pay_rate = max_salary.sal;

--15

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
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
     combined AS (SELECT per_id, ks_code
                  FROM needed_skills, person),
     missing AS (SELECT per_id, COUNT(ks_code) AS num
                 FROM combined P
                 WHERE EXISTS ((SELECT *
                                FROM needed_skills T
                                WHERE T.ks_code = P.ks_code)
                                MINUS
                               (SELECT ks_code
                                FROM has_skill H
                                WHERE H.per_id = P.per_id
                                AND H.ks_code = P.ks_code))
                 GROUP BY per_id),
     min_missing AS (SELECT MIN(num) AS min_num
                     FROM missing)
SELECT per_id, num
FROM missing, min_missing
WHERE missing.num = min_missing.min_num;

--19--missing 'k' number of skills, list per_id and num in ascending order of missing
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
     combined AS (SELECT per_id, ks_code
                  FROM needed_skills, person),
     missing AS (SELECT per_id, COUNT(ks_code) AS num
                 FROM combined P
                 WHERE EXISTS ((SELECT *
                                FROM needed_skills T
                                WHERE T.ks_code = P.ks_code)
                                MINUS
                               (SELECT ks_code
                                FROM has_skill H
                                WHERE H.per_id = P.per_id
                                AND H.ks_code = P.ks_code))
                 GROUP BY per_id)
SELECT per_id, num
FROM missing
WHERE num < 5
ORDER BY num;

--20--- every skill needed by missking-k ppl and num ppl missing it, ascending order
WITH needed_skills AS (SELECT ks_code
                       FROM requires
                       WHERE pos_code = 23),
     combined AS (SELECT per_id, ks_code
                  FROM needed_skills, person),
     missing AS (SELECT per_id, COUNT(ks_code) AS num
                 FROM combined P
                 WHERE EXISTS ((SELECT *
                                FROM needed_skills T
                                WHERE T.ks_code = P.ks_code)
                                MINUS
                               (SELECT ks_code
                                FROM has_skill H
                                WHERE H.per_id = P.per_id
                                AND H.ks_code = P.ks_code))
                 GROUP BY per_id),
     missing_k AS (SELECT per_id
                   FROM missing
                   WHERE num < 5)
SELECT ks_code, COUNT(per_id) AS num_ppl
FROM combined P
WHERE EXISTS ((SELECT *
               FROM needed_skills N
               WHERE N.ks_code = P.ks_code)
               MINUS
              (SELECT ks_code
               FROM has_skill T
               WHERE T.ks_code = P.ks_code
               AND T.per_id = P.per_id
               AND EXISTS (SELECT *
                           FROM missing_k M
                           WHERE M.per_id = T.per_id))
              )
GROUP BY ks_code
ORDER BY num_ppl;

--21

--22--unemployed ppl once held position
------tested with one person
SELECT per_id, per_name
FROM person P
WHERE NOT EXISTS (SELECT pos_code
                  FROM works T
                  WHERE T.per_id = P.per_id
                  AND T.end_date > SYSDATE)
AND EXISTS (SELECT *
            FROM works W
            WHERE W.pos_code = 23
            AND W.per_id = P.per_id);
            
--23

--24--requires specialites


--25