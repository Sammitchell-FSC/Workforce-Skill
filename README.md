# Workforce Skills Database for AI Reskilling Analytics (BUS 385, Topic 7)

Relational MySQL database that stores anonymized survey responses from college staff and
professors, compares each respondent's self-rated skills (1-5) with the AI-related
competencies required for their role, and reports skill gaps.

## Setup (MySQL 8.0.16+ / MySQL Workbench)
1. Open and run `01_schema.sql` (creates database `workforce_skills`, 8 tables, indexes, view `v_skill_gap`).
2. Run `02_sample_data.sql` (loads 24 SYNTHETIC test respondents; replace with real survey data later).
3. Run `03_queries.sql` to reproduce the query set (Q1 is the live-demo query).

Command line: `mysql -u root -p < 01_schema.sql` then the same for 02 and 03.

## Team
Sam, Oscar, Luigi, Raelle (see commit history for individual contributions).

