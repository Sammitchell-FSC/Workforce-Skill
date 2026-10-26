-- BUS 385 Term Group Project | Topic 7: Workforce Skills Database for AI Reskilling Analytics
-- 01_schema.sql : creates the MySQL database, 8 tables (3NF), indexes, and one reporting view.
-- Requires MySQL 8.0.16+ (CHECK constraints are enforced from that version).

DROP DATABASE IF EXISTS workforce_skills;
CREATE DATABASE workforce_skills;
USE workforce_skills;

CREATE TABLE Departments (
    department_id    INT AUTO_INCREMENT PRIMARY KEY,
    department_name  VARCHAR(100) NOT NULL UNIQUE,
    reporting_group  VARCHAR(60)  NOT NULL   -- used to roll up small departments
) ENGINE=InnoDB;

CREATE TABLE Job_Roles (
    role_id     INT AUTO_INCREMENT PRIMARY KEY,
    role_title  VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Employees (
    employee_id      INT AUTO_INCREMENT PRIMARY KEY,
    respondent_code  VARCHAR(10) NOT NULL UNIQUE,   -- anonymized; no names stored
    department_id    INT NOT NULL,
    role_id          INT NOT NULL,
    survey_date      DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (role_id)       REFERENCES Job_Roles(role_id)
) ENGINE=InnoDB;

CREATE TABLE Skills (
    skill_id        INT AUTO_INCREMENT PRIMARY KEY,
    skill_name      VARCHAR(100) NOT NULL UNIQUE,
    skill_category  VARCHAR(30)  NOT NULL
        CHECK (skill_category IN ('AI-related', 'Technical', 'Soft skill')),
    is_ai_related   TINYINT(1)   NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE Certifications (
    certification_id    INT AUTO_INCREMENT PRIMARY KEY,
    certification_name  VARCHAR(150) NOT NULL UNIQUE,
    issuing_body        VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Employee_Skills (
    employee_id        INT NOT NULL,
    skill_id           INT NOT NULL,
    proficiency_level  INT NOT NULL CHECK (proficiency_level BETWEEN 1 AND 5),
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (skill_id)    REFERENCES Skills(skill_id)
) ENGINE=InnoDB;

CREATE TABLE Employee_Certifications (
    employee_id       INT NOT NULL,
    certification_id  INT NOT NULL,
    date_earned       DATE NOT NULL,
    PRIMARY KEY (employee_id, certification_id),
    FOREIGN KEY (employee_id)      REFERENCES Employees(employee_id),
    FOREIGN KEY (certification_id) REFERENCES Certifications(certification_id)
) ENGINE=InnoDB;

CREATE TABLE Role_Competency_Requirements (
    role_id         INT NOT NULL,
    skill_id        INT NOT NULL,
    required_level  INT NOT NULL CHECK (required_level BETWEEN 1 AND 5),
    PRIMARY KEY (role_id, skill_id),
    FOREIGN KEY (role_id)  REFERENCES Job_Roles(role_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
) ENGINE=InnoDB;

-- Indexes for the join and GROUP BY paths used by the gap-analysis queries
CREATE INDEX idx_employees_department ON Employees(department_id);
CREATE INDEX idx_employees_role       ON Employees(role_id);
CREATE INDEX idx_empskills_skill      ON Employee_Skills(skill_id);
CREATE INDEX idx_rolereq_skill        ON Role_Competency_Requirements(skill_id);

-- One row per respondent per skill their role requires.
-- A missing Employee_Skills row counts as current_level 0 (no skill reported).
-- gap_points is 0 when the respondent meets or exceeds the requirement.
CREATE VIEW v_skill_gap AS
SELECT e.employee_id,
       e.respondent_code,
       d.department_id,
       d.department_name,
       d.reporting_group,
       jr.role_id,
       jr.role_title,
       s.skill_id,
       s.skill_name,
       s.is_ai_related,
       r.required_level,
       COALESCE(es.proficiency_level, 0) AS current_level,
       CASE WHEN r.required_level > COALESCE(es.proficiency_level, 0)
            THEN r.required_level - COALESCE(es.proficiency_level, 0)
            ELSE 0 END AS gap_points
FROM Employees e
JOIN Departments d ON d.department_id = e.department_id
JOIN Job_Roles jr  ON jr.role_id = e.role_id
JOIN Role_Competency_Requirements r ON r.role_id = e.role_id
JOIN Skills s ON s.skill_id = r.skill_id
LEFT JOIN Employee_Skills es
       ON es.employee_id = e.employee_id AND es.skill_id = r.skill_id;
