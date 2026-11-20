-- BUS 385 Term Group Project | Topic 7: Workforce Skills Database for AI Reskilling Analytics
-- 01_schema.sql (v2): rebuilt to match the collected survey. Requires MySQL 8.0.16+.
-- WARNING: drops and recreates the workforce_skills database.

DROP DATABASE IF EXISTS workforce_skills;
CREATE DATABASE workforce_skills;
USE workforce_skills;

CREATE TABLE Departments (
    department_id    INT AUTO_INCREMENT PRIMARY KEY,
    department_name  VARCHAR(100) NOT NULL UNIQUE,
    reporting_group  VARCHAR(60)  NOT NULL   -- roll-up used when a department has fewer than 3 respondents
) ENGINE=InnoDB;

CREATE TABLE Job_Roles (
    role_id     INT AUTO_INCREMENT PRIMARY KEY,
    role_title  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Employees (
    employee_id          INT AUTO_INCREMENT PRIMARY KEY,
    respondent_code      VARCHAR(10) NOT NULL UNIQUE,      -- anonymized; no names or timestamps stored
    department_id        INT NOT NULL,
    role_id              INT NOT NULL,
    ai_use_frequency     VARCHAR(10) NOT NULL
        CHECK (ai_use_frequency IN ('Never', 'Sometimes', 'Often')),
    certification_status VARCHAR(12) NOT NULL DEFAULT 'None'
        CHECK (certification_status IN ('None', 'In progress', 'Holds')),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (role_id)       REFERENCES Job_Roles(role_id)
) ENGINE=InnoDB;

CREATE TABLE Skills (
    skill_id       INT AUTO_INCREMENT PRIMARY KEY,
    skill_name     VARCHAR(100) NOT NULL UNIQUE,
    skill_category VARCHAR(30)  NOT NULL
        CHECK (skill_category IN ('AI-related', 'Technical')),
    is_ai_related  TINYINT(1)   NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- One row per respondent per surveyed skill.
-- proficiency_level: 1 No experience, 2 Beginner, 3 Intermediate, 4 Advanced, 5 Expert
-- importance_level : 1 Not needed, 2 Slightly important, 3 Moderately important, 4 Very, 5 Extremely
-- Both use the same 1-5 scale, so a gap is importance minus proficiency when positive.
CREATE TABLE Employee_Skills (
    employee_id        INT NOT NULL,
    skill_id           INT NOT NULL,
    proficiency_level  INT NOT NULL CHECK (proficiency_level BETWEEN 1 AND 5),
    importance_level   INT NOT NULL CHECK (importance_level BETWEEN 1 AND 5),
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (skill_id)    REFERENCES Skills(skill_id)
) ENGINE=InnoDB;

-- Resolves the multi-select "which skills would you like to learn?" answer (1NF).
CREATE TABLE Employee_Learning_Interests (
    employee_id  INT NOT NULL,
    skill_id     INT NOT NULL,
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (skill_id)    REFERENCES Skills(skill_id)
) ENGINE=InnoDB;

CREATE INDEX idx_employees_department ON Employees(department_id);
CREATE INDEX idx_employees_role       ON Employees(role_id);
CREATE INDEX idx_empskills_skill      ON Employee_Skills(skill_id);
CREATE INDEX idx_interests_skill      ON Employee_Learning_Interests(skill_id);

-- One row per respondent per skill. gap_points is 0 when proficiency meets or exceeds importance.
CREATE VIEW v_skill_gap AS
SELECT e.employee_id,
       e.respondent_code,
       d.department_id,
       d.department_name,
       d.reporting_group,
       jr.role_title,
       s.skill_id,
       s.skill_name,
       es.importance_level,
       es.proficiency_level,
       CASE WHEN es.importance_level > es.proficiency_level
            THEN es.importance_level - es.proficiency_level ELSE 0 END AS gap_points
FROM Employees e
JOIN Departments d ON d.department_id = e.department_id
JOIN Job_Roles jr  ON jr.role_id = e.role_id
JOIN Employee_Skills es ON es.employee_id = e.employee_id
JOIN Skills s ON s.skill_id = es.skill_id;
