# question-3----IIT-mandi-assignment
This repository contains the solution for **Q4 / Part 3** of the CodeJudge DBMS assignment.

The solution assumes that the raw CSV files were first imported into SQLite tables with the same names as the CSV files. The provided loader imports all columns as `TEXT`, so the audit queries use `CAST`, `date()`, and `datetime()` where numeric or timestamp validation is required.

## Repository Files

```text
codejudge-part3/
├── README.md
├── import_validation.sql
├── integrity_audit.sql
├── domain_rule_checks.sql
├── repair_plan.md
├── staging_repair_scripts.sql
└── before_after_evidence.md
```

## How to Run

1. Import the CSV files into SQLite using the raw loader or equivalent import method.
2. Run the audit files in this order:

```bash
sqlite3 codejudge_raw.db < import_validation.sql
sqlite3 codejudge_raw.db < integrity_audit.sql
sqlite3 codejudge_raw.db < domain_rule_checks.sql
```

3. Run the staging repair script only after reviewing the audit output:

```bash
sqlite3 codejudge_raw.db < staging_repair_scripts.sql
```

The repair script creates staging tables such as `stg_students_repair` and does **not** modify the original imported tables.

## Main Findings Summary

### Import Validation

|Table|Actual rows|Expected CSV rows|Distinct key values|PK check|
|---|---|---|---|---|
|batches|6|6|6|PASS|
|courses|10|10|10|PASS|
|students|320|320|320|PASS|
|enrollments|719|719|719|PASS|
|problems|67|67|67|PASS|
|test_cases|330|330|330|PASS|
|contests|12|12|12|PASS|
|contest_problems|63|63|62|FAIL|
|submissions|2501|2501|2500|FAIL|
|test_results|9673|9673|9673|PASS|
|sessions|48|48|48|PASS|
|attendance|2352|2352|2352|PASS|
|regrade_requests|80|80|80|PASS|
|plagiarism_flags|60|60|60|PASS|
|raw_student_import|80|80|80|PASS|
|operation_requests|35|35|35|PASS|

Observation: all raw row counts matched the expected CSV row counts. The main import issue is not missing tables, but dirty values and relationship problems inside the imported data.

### Uniqueness Findings

|Check|Rows involved|Result|
|---|---|---|
|submissions.submission_id|2|FAIL|
|students.roll_number|2|FAIL|
|students.email|0|PASS|
|courses.course_code|2|FAIL|
|problems.problem_code|2|FAIL|
|enrollments.student_id + course_id|2|FAIL|
|contest_problems.contest_id + problem_id|2|FAIL|
|test_cases.problem_id + case_no|2|FAIL|
|test_results.submission_id + test_case_id|2|FAIL|
|attendance.session_id + student_id|4|FAIL|

### Foreign-Key / Relationship Findings

|Relationship check|Issue rows|
|---|---|
|students.batch_id -> batches.batch_id|2|
|enrollments.student_id -> students.student_id|1|
|enrollments.course_id -> courses.course_id|1|
|problems.course_id -> courses.course_id|1|
|test_cases.problem_id -> problems.problem_id|1|
|contests.course_id -> courses.course_id|1|
|contest_problems.contest_id -> contests.contest_id|1|
|contest_problems.problem_id -> problems.problem_id|1|
|submissions.student_id -> students.student_id|1|
|submissions.problem_id -> problems.problem_id|1|
|submissions.contest_id -> contests.contest_id|1|
|test_results.submission_id -> submissions.submission_id|1|
|test_results.test_case_id -> test_cases.test_case_id|1|
|sessions.course_id -> courses.course_id|1|
|attendance.session_id -> sessions.session_id|1|
|attendance.student_id -> students.student_id|6|
|regrade_requests.submission_id -> submissions.submission_id|1|
|regrade_requests.student_id -> students.student_id|1|
|plagiarism_flags.submission_id -> submissions.submission_id|1|
|plagiarism_flags.matched_submission_id -> submissions.submission_id|0|

### Domain Rule Findings

|Domain check|Issue rows|Example|
|---|---|---|
|students.enrollment_status|1|S0089 = actve|
|enrollments.enrollment_status|1|E00042 = ongoing|
|contests.contest_status|1|CT010 = done|
|submissions.status|1|SUB000208 = OK|
|submissions.language|1|SUB000140 = PseudoCode|
|test_results.result_status|1|R0000080 = Correct|
|attendance.attendance_status|1|A000046 = joined|
|regrade_requests.request_status|1|RG0023 = done|
|plagiarism_flags.flag_status|1|PF0026 = pending|
|operation_requests.operation_type|1|OP0003 = DROP|

## Notes

- Blank `contest_id` in `submissions` is treated as allowed because submissions may happen outside a contest.
- Blank `final_grade`, `resolved_at`, `executed_at`, and `import_notes` are treated as optional depending on workflow state.
- Bad foreign keys are not automatically corrected unless a trustworthy mapping exists.
