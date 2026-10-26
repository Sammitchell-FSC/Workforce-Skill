-- 03_queries.sql : finalized query set for the Revised Proposal. Run after 01 and 02.
USE workforce_skills;

-- Q1 (LIVE DEMO): skill-gap profile for one respondent (multi-table join through view)
SELECT respondent_code, role_title, skill_name, required_level, current_level, gap_points
FROM v_skill_gap
WHERE respondent_code = 'R007' AND gap_points > 0
ORDER BY gap_points DESC, skill_name;

-- Q2: most common AI-related skill gaps across all respondents (aggregation)
SELECT skill_name,
       COUNT(*)                   AS respondents_required,
       SUM(gap_points > 0)        AS respondents_with_gap,
       ROUND(AVG(gap_points), 2)  AS avg_gap_points
FROM v_skill_gap
WHERE is_ai_related = 1
GROUP BY skill_id, skill_name
ORDER BY respondents_with_gap DESC, avg_gap_points DESC;

-- Q3: department-level average gap, ONLY departments with at least 3 respondents
SELECT department_name,
       COUNT(DISTINCT employee_id) AS respondents,
       ROUND(AVG(gap_points), 2)   AS avg_gap_points
FROM v_skill_gap
WHERE is_ai_related = 1
GROUP BY department_id, department_name
HAVING COUNT(DISTINCT employee_id) >= 3
ORDER BY avg_gap_points DESC;

-- Q4: the same measure rolled up to reporting groups, so no respondent is dropped
SELECT reporting_group,
       COUNT(DISTINCT employee_id) AS respondents,
       ROUND(AVG(gap_points), 2)   AS avg_gap_points
FROM v_skill_gap
WHERE is_ai_related = 1
GROUP BY reporting_group
ORDER BY avg_gap_points DESC;

-- Q5: departments suppressed by the minimum-group-size rule in Q3 (outer join + HAVING)
SELECT d.department_name, d.reporting_group, COUNT(e.employee_id) AS respondents
FROM Departments d
LEFT JOIN Employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.reporting_group
HAVING COUNT(e.employee_id) < 3
ORDER BY respondents;

-- Q6 (subquery): respondents with no AI-related skill rated 4 or higher
SELECT e.respondent_code, jr.role_title
FROM Employees e
JOIN Job_Roles jr ON jr.role_id = e.role_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Employee_Skills es
    JOIN Skills s ON s.skill_id = es.skill_id
    WHERE es.employee_id = e.employee_id
      AND s.is_ai_related = 1
      AND es.proficiency_level >= 4
);

-- Q7 (subquery): do respondents holding a certification show smaller AI skill gaps?
SELECT CASE WHEN employee_id IN (SELECT employee_id FROM Employee_Certifications)
            THEN 'Has certification' ELSE 'No certification' END AS cert_status,
       COUNT(DISTINCT employee_id) AS respondents,
       ROUND(AVG(gap_points), 2)   AS avg_gap_points
FROM v_skill_gap
WHERE is_ai_related = 1
GROUP BY cert_status;
