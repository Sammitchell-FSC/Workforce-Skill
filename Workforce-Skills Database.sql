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
    respondent_code      VARCHAR(10) NOT NULL UNIQUE,      
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
CREATE TABLE Employee_Skills (
    employee_id        INT NOT NULL,
    skill_id           INT NOT NULL,
    proficiency_level  INT NOT NULL CHECK (proficiency_level BETWEEN 1 AND 5),
    importance_level   INT NOT NULL CHECK (importance_level BETWEEN 1 AND 5),
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (skill_id)    REFERENCES Skills(skill_id)
) ENGINE=InnoDB;
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

show databases;
USE workforce_skills;

INSERT INTO Departments (department_id, department_name, reporting_group) VALUES
(1,'Student Services','Student Services'),
(2,'Academic Department','Academic'),
(3,'Campus Recreation & Athletics','Campus Recreation & Athletics'),
(4,'Administrative or Office Services','Administration & Operations'),
(5,'Academic Administration','Administration & Operations'),
(6,'Facilities or Operations','Administration & Operations');

INSERT INTO Job_Roles (role_id, role_title) VALUES
(1,'Student staff'),
(2,'Professor or faculty member'),
(3,'Administrative or office staff'),
(4,'Facilities or operations staff'),
(5,'Student services or support staff');

INSERT INTO Skills (skill_id, skill_name, skill_category, is_ai_related) VALUES
(1,'Data analysis','Technical',0),
(2,'Excel','Technical',0),
(3,'AI tools','AI-related',1),
(4,'Basic programming or scripting','Technical',0),
(5,'SQL and database skills','Technical',0);

INSERT INTO Employees (employee_id, respondent_code, department_id, role_id, ai_use_frequency, certification_status) VALUES
(1,'R001',1,1,'Often','None'),
(2,'R002',3,1,'Sometimes','None'),
(3,'R003',3,1,'Never','None'),
(4,'R004',1,1,'Sometimes','None'),
(5,'R005',1,3,'Often','None'),
(6,'R006',2,2,'Sometimes','None'),
(7,'R007',3,1,'Sometimes','None'),
(8,'R008',1,1,'Often','None'),
(9,'R009',2,2,'Sometimes','In progress'),
(10,'R010',4,4,'Sometimes','None'),
(11,'R011',6,1,'Often','None'),
(12,'R012',2,5,'Sometimes','None'),
(13,'R013',2,2,'Often','In progress'),
(14,'R014',1,1,'Often','None'),
(15,'R015',5,1,'Never','None'),
(16,'R016',1,1,'Never','None');

INSERT INTO Employee_Skills (employee_id, skill_id, proficiency_level, importance_level) VALUES
(1,1,4,2),
(1,2,3,2),
(1,3,4,1),
(1,4,3,2),
(1,5,3,2),
(2,1,1,1),
(2,2,2,1),
(2,3,3,3),
(2,4,1,1),
(2,5,1,1),
(3,1,2,1),
(3,2,1,1),
(3,3,3,1),
(3,4,1,1),
(3,5,1,1),
(4,1,2,3),
(4,2,2,2),
(4,3,3,3),
(4,4,1,2),
(4,5,1,2),
(5,1,3,3),
(5,2,3,3),
(5,3,3,3),
(5,4,3,3),
(5,5,3,3),
(6,1,3,3),
(6,2,2,2),
(6,3,4,3),
(6,4,1,1),
(6,5,2,2),
(7,1,3,1),
(7,2,3,1),
(7,3,3,1),
(7,4,2,1),
(7,5,2,1),
(8,1,1,2),
(8,2,2,2),
(8,3,4,2),
(8,4,2,2),
(8,5,1,2),
(9,1,3,2),
(9,2,3,2),
(9,3,4,2),
(9,4,3,2),
(9,5,3,2),
(10,1,2,2),
(10,2,3,2),
(10,3,3,2),
(10,4,2,1),
(10,5,2,2),
(11,1,3,2),
(11,2,3,2),
(11,3,3,2),
(11,4,3,2),
(11,5,3,2),
(12,1,3,2),
(12,2,3,2),
(12,3,3,2),
(12,4,3,1),
(12,5,3,2),
(13,1,2,1),
(13,2,2,2),
(13,3,3,2),
(13,4,2,2),
(13,5,2,1),
(14,1,1,1),
(14,2,2,1),
(14,3,5,2),
(14,4,1,1),
(14,5,1,1),
(15,1,1,1),
(15,2,1,1),
(15,3,1,1),
(15,4,1,1),
(15,5,1,1),
(16,1,1,1),
(16,2,1,1),
(16,3,3,1),
(16,4,1,1),
(16,5,1,1);

INSERT INTO Employee_Learning_Interests (employee_id, skill_id) VALUES
(1,1),
(1,2),
(2,3),
(3,1),
(3,2),
(3,3),
(3,4),
(3,5),
(4,1),
(4,2),
(4,3),
(4,4),
(5,3),
(6,4),
(7,4),
(8,3),
(9,3),
(10,1),
(10,2),
(10,3),
(11,1),
(11,2),
(11,3),
(11,4),
(11,5),
(12,2),
(12,3),
(13,1),
(13,3),
(13,4),
(14,3),
(15,1),
(16,2);
