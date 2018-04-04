--1---------------------------
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
WITH needed_info AS (SELECT position.comp_id, works.per_id, position.pay_rate, position.pay_type
                     FROM works, position
                     WHERE works.pos_code = position.pos_code
                     AND works.end_date > SYSDATE),
     costs AS (SELECT comp_id, per_id, CASE 
                                            WHEN P.pay_type = 'salary' THEN P.pay_rate
                                            ELSE P.pay_rate * 1920
                                       END AS real_cost
               FROM needed_info P)
SELECT comp_id, SUM(real_cost) AS total_cost
FROM costs
GROUP BY comp_id
ORDER BY total_cost DESC;
                     
--4------------------------------
SELECT person.per_id, person.per_name, works.pos_code
FROM person, works
WHERE person.per_id = works.per_id
AND person.per_id = 1;

--5------------------------------
SELECT knowledge_skill.ks_code, knowledge_skill.title
FROM has_skill, knowledge_skill
WHERE has_skill.ks_code = knowledge_skill.ks_code
AND per_id = 1;

--6-------------------------------
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

--8-------------------------------
WITH needed_skills AS (SELECT knowledge_skill.ks_code, knowledge_skill.title
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 1)
SELECT ks_code, title
FROM needed_skills MINUS (SELECT knowledge_skill.ks_code, knowledge_skill.title
                          FROM knowledge_skill, requires
                          WHERE knowledge_skill.ks_code = requires.ks_code
                          AND requires.pos_code = 23);
                          
--9
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 1)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 1))
SELECT c_code, title
FROM course NATURAL JOIN (SELECT c_code
                          FROM teaches P
                          WHERE NOT EXISTS ((SELECT *
                                             FROM skills_needed)
                                             MINUS
                                            (SELECT ks_code
                                             FROM teaches T
                                             WHERE T.c_code = P.c_code))
                         );

--10----------------------------
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 1)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 1))
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

--11--------------------------------------
WITH skills_needed AS ((SELECT knowledge_skill.ks_code
                       FROM knowledge_skill, requires
                       WHERE knowledge_skill.ks_code = requires.ks_code
                       AND requires.pos_code = 1)
                       MINUS
                       (SELECT has_skill.ks_code
                        FROM has_skill
                        WHERE per_id = 1))
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
     ORDER BY course.retail_price
      )
WHERE rownum = 1;                                                 

--12--course sets that would make someone qualified (3 or less)


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