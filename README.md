# Workforce Skills Database for AI Reskilling Analytics (BUS 385, Topic 7)

Relational MySQL database built from a survey of college staff, student staff, and faculty (16 anonymized responses).
It stores each respondent's self-rated proficiency and job importance (both on a 1-5 scale) for five skills,
their AI tool use, and the skills they want to learn. A gap is importance minus proficiency when positive.

## Setup (MySQL 8.0.16+ / MySQL Workbench)
Run the files in this order (File > Open SQL Script, then the lightning bolt):
1. `01_schema.sql`: creates database `workforce_skills`, 6 tables, indexes, and view `v_skill_gap` (drops any existing copy).
2. `02_load_survey.sql`: loads the 16 survey responses.
3. `03_queries.sql`: the finalized query set (Q1 is the live-demo query).
4. `04_demo_new_respondent.sql`: live demo that adds a new respondent and shows their gaps in real time.

Command line: `mysql -u root -p < 01_schema.sql` then the same for 02, 03, and 04.

## Data notes
- No names, emails, or timestamps are stored; respondents are identified by codes (R001-R016).
- Results for departments with fewer than 3 respondents are suppressed and rolled up into reporting groups.

## Team
Sam, Oscar, Luigi, Raelle (see commit history for individual contributions).
