Use Workforce_skills;

SELECT 'Departments' AS tbl, COUNT(*) AS n FROM Departments
UNION ALL SELECT 'Job_Roles', COUNT(*) FROM Job_Roles
UNION ALL SELECT 'Skills', COUNT(*) FROM Skills
UNION ALL SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL SELECT 'Employee_Skills', COUNT(*) FROM Employee_Skills
UNION ALL SELECT 'Employee_Learning_Interests', COUNT(*) FROM Employee_Learning_Interests;

SELECT employee_id, COUNT(*) AS skills_rated
FROM Employee_Skills
GROUP BY employee_id
HAVING COUNT(*) <> 5;

SELECT es.employee_id, es.skill_id
FROM Employee_Skills es
LEFT JOIN Employees e ON e.employee_id = es.employee_id
LEFT JOIN Skills s ON s.skill_id = es.skill_id
WHERE e.employee_id IS NULL OR s.skill_id IS NULL;

SELECT SUM(n) AS respondents_in_groups
FROM (SELECT COUNT(*) AS n
      FROM Employees e JOIN Departments d ON d.department_id = e.department_id
      GROUP BY d.reporting_group) g;

SELECT COUNT(*) AS view_rows FROM v_skill_gap;


SELECT respondent_code, SUM(gap_points) AS total_gap_points
FROM v_skill_gap
GROUP BY respondent_code
HAVING SUM(gap_points) > 0;



UPDATE Employee_Skills SET proficiency_level = 6 WHERE employee_id = 1 AND skill_id = 1;

UPDATE Employee_Skills SET importance_level = 0 WHERE employee_id = 1 AND skill_id = 1;

UPDATE Employees SET ai_use_frequency = 'Daily' WHERE employee_id = 1;

UPDATE Employees SET certification_status = 'Maybe' WHERE employee_id = 1;

UPDATE Skills SET skill_category = 'Soft skill' WHERE skill_id = 1;

UPDATE Employees SET department_id = NULL WHERE employee_id = 1;

INSERT INTO Employees (respondent_code, department_id, role_id, ai_use_frequency)
VALUES ('TEST1', 99, 1, 'Never');

INSERT INTO Employee_Learning_Interests (employee_id, skill_id) VALUES (1, 99);

UPDATE Employees SET respondent_code = 'R001' WHERE employee_id = 2;

UPDATE Departments SET department_name = 'Student Services' WHERE department_id = 2;

INSERT INTO Employee_Skills (employee_id, skill_id, proficiency_level, importance_level)
VALUES (1, 1, 3, 3);

DELETE FROM Departments WHERE department_id = 1;

START TRANSACTION;
INSERT INTO Employees (respondent_code, department_id, role_id, ai_use_frequency)
VALUES ('TEST1', 1, 1, 'Never');
SELECT respondent_code, department_id FROM Employees WHERE respondent_code = 'TEST1';
ROLLBACK;
SELECT COUNT(*) AS employees_after_rollback FROM Employees;
