USE workforce_skills;

-- Step 1: Insert simulated employee
INSERT INTO Employees (
    respondent_code,
    department_id,
    role_id,
    ai_use_frequency,
    certification_status
)
VALUES (
    'R017',
    1,
    1,
    'Sometimes',
    'None'
);

-- Step 2: Insert simulated employee skill ratings
INSERT INTO Employee_Skills (
    employee_id,
    skill_id,
    proficiency_level,
    importance_level
)
VALUES
    (LAST_INSERT_ID(), 1, 2, 4),
    (LAST_INSERT_ID(), 2, 2, 5),
    (LAST_INSERT_ID(), 3, 3, 4),
    (LAST_INSERT_ID(), 4, 1, 1),
    (LAST_INSERT_ID(), 5, 1, 2);
    
    -- Step 3: Analyze the simulated employee skill gaps
SELECT
    respondent_code,
    role_title,
    skill_name,
    importance_level,
    proficiency_level,
    gap_points
FROM v_skill_gap
WHERE respondent_code = 'R017'
ORDER BY gap_points DESC, skill_name;

-- Step 4: Delete the simulated employee after demo
DELETE FROM Employee_Learning_Interests
WHERE employee_id = (
    SELECT employee_id
    FROM Employees
    WHERE respondent_code = 'R017'
);

DELETE FROM Employee_Skills
WHERE employee_id = (
    SELECT employee_id
    FROM Employees
    WHERE respondent_code = 'R017'
);

DELETE FROM Employees
WHERE respondent_code = 'R017';