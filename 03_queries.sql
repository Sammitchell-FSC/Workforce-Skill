-- 03_queries.sql (v2): finalized query set. Run after 01 and 02.
USE workforce_skills;

-- Q1 (LIVE DEMO): full skill profile for one respondent (multi-table join through a view)
SELECT respondent_code, role_title, skill_name, importance_level, proficiency_level, gap_points
FROM v_skill_gap
WHERE respondent_code = 'R004'
ORDER BY gap_points DESC, skill_name;

-- Q2: for each skill, how many need it, how many fall short, and how many want to learn it
SELECT v.skill_name,
       SUM(v.importance_level >= 2) AS respondents_needing_skill,
       SUM(v.gap_points > 0)        AS respondents_with_gap,
       ROUND(AVG(v.proficiency_level), 2) AS avg_proficiency,
       (SELECT COUNT(*) FROM Employee_Learning_Interests li
         WHERE li.skill_id = v.skill_id) AS respondents_wanting_to_learn
FROM v_skill_gap v
GROUP BY v.skill_id, v.skill_name
ORDER BY respondents_wanting_to_learn DESC;

-- Q3: department-level results, ONLY departments with at least 3 respondents
SELECT department_name,
       COUNT(DISTINCT employee_id)       AS respondents,
       ROUND(AVG(proficiency_level), 2)  AS avg_proficiency,
       ROUND(AVG(importance_level), 2)   AS avg_importance,
       ROUND(AVG(gap_points), 2)         AS avg_gap_points
FROM v_skill_gap
GROUP BY department_id, department_name
HAVING COUNT(DISTINCT employee_id) >= 3
ORDER BY avg_gap_points DESC;

-- Q4: the same measures by reporting group, so no respondent is dropped
SELECT reporting_group,
       COUNT(DISTINCT employee_id)       AS respondents,
       ROUND(AVG(proficiency_level), 2)  AS avg_proficiency,
       ROUND(AVG(importance_level), 2)   AS avg_importance,
       ROUND(AVG(gap_points), 2)         AS avg_gap_points
FROM v_skill_gap
GROUP BY reporting_group
ORDER BY avg_gap_points DESC;

-- Q5: departments suppressed by the minimum-group-size rule in Q3 (outer join + HAVING)
SELECT d.department_name, d.reporting_group, COUNT(e.employee_id) AS respondents
FROM Departments d
LEFT JOIN Employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.reporting_group
HAVING COUNT(e.employee_id) < 3
ORDER BY respondents;

-- Q6 (subquery): respondents who want to learn a skill they rate "Not needed" for their current job
SELECT e.respondent_code, s.skill_name
FROM Employees e
JOIN Employee_Skills es ON es.employee_id = e.employee_id
JOIN Skills s ON s.skill_id = es.skill_id
WHERE es.importance_level = 1
  AND EXISTS (SELECT 1 FROM Employee_Learning_Interests li
               WHERE li.employee_id = e.employee_id AND li.skill_id = es.skill_id)
ORDER BY e.respondent_code, s.skill_name;

-- Q7: does AI tool use frequency go with AI tool proficiency? (aggregation on a respondent attribute)
SELECT e.ai_use_frequency,
       COUNT(*) AS respondents,
       ROUND(AVG(es.proficiency_level), 2) AS avg_ai_tool_proficiency
FROM Employees e
JOIN Employee_Skills es ON es.employee_id = e.employee_id
JOIN Skills s ON s.skill_id = es.skill_id AND s.skill_name = 'AI tools'
GROUP BY e.ai_use_frequency
ORDER BY FIELD(e.ai_use_frequency, 'Never', 'Sometimes', 'Often');
