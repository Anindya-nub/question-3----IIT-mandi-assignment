-- CodeJudge Part 3: Safe Staging Repair Scripts
-- Dialect: SQLite.
-- Important: This script does not modify original imported tables.
-- It creates staging copies, shows records before repair, applies safe repairs, and shows after evidence.

BEGIN TRANSACTION;

DROP TABLE IF EXISTS stg_students_repair;
DROP TABLE IF EXISTS stg_enrollments_repair;
DROP TABLE IF EXISTS stg_submissions_repair;
DROP TABLE IF EXISTS stg_test_results_repair;
DROP TABLE IF EXISTS stg_attendance_repair;
DROP TABLE IF EXISTS stg_regrade_requests_repair;
DROP TABLE IF EXISTS stg_operation_requests_repair;
DROP TABLE IF EXISTS stg_test_cases_repair;
DROP TABLE IF EXISTS stg_contests_repair;
DROP TABLE IF EXISTS rejected_submissions;
DROP TABLE IF EXISTS manual_review_students;

CREATE TABLE stg_students_repair AS SELECT * FROM students;
CREATE TABLE stg_enrollments_repair AS SELECT * FROM enrollments;
CREATE TABLE stg_submissions_repair AS SELECT * FROM submissions;
CREATE TABLE stg_test_results_repair AS SELECT * FROM test_results;
CREATE TABLE stg_attendance_repair AS SELECT * FROM attendance;
CREATE TABLE stg_regrade_requests_repair AS SELECT * FROM regrade_requests;
CREATE TABLE stg_operation_requests_repair AS SELECT * FROM operation_requests;
CREATE TABLE stg_test_cases_repair AS SELECT * FROM test_cases;
CREATE TABLE stg_contests_repair AS SELECT * FROM contests;

CREATE TABLE rejected_submissions AS SELECT *, '' AS issue_reason FROM submissions WHERE 0;
CREATE TABLE manual_review_students AS SELECT *, '' AS issue_reason FROM students WHERE 0;

-- Repair 1: Typo in student status: S0089 has 'actve'. This is a clear spelling correction.
SELECT 'before R1' AS phase, student_id, enrollment_status FROM stg_students_repair WHERE student_id = 'S0089';
UPDATE stg_students_repair
SET enrollment_status = 'active'
WHERE student_id = 'S0089' AND enrollment_status = 'actve';
SELECT 'after R1' AS phase, student_id, enrollment_status FROM stg_students_repair WHERE student_id = 'S0089';

-- Repair 2: Enrollment E00042 has 'ongoing'. Map it to the controlled value 'active'.
SELECT 'before R2' AS phase, enrollment_id, student_id, course_id, enrollment_status FROM stg_enrollments_repair WHERE enrollment_id = 'E00042';
UPDATE stg_enrollments_repair
SET enrollment_status = 'active'
WHERE enrollment_id = 'E00042' AND enrollment_status = 'ongoing';
SELECT 'after R2' AS phase, enrollment_id, student_id, course_id, enrollment_status FROM stg_enrollments_repair WHERE enrollment_id = 'E00042';

-- Repair 3: Submission SUB000208 has status 'OK'. In this platform it means successful/accepted.
SELECT 'before R3' AS phase, submission_id, status FROM stg_submissions_repair WHERE submission_id = 'SUB000208';
UPDATE stg_submissions_repair
SET status = 'Accepted'
WHERE submission_id = 'SUB000208' AND status = 'OK';
SELECT 'after R3' AS phase, submission_id, status FROM stg_submissions_repair WHERE submission_id = 'SUB000208';

-- Repair 4: Submission SUB000140 has unsupported language PseudoCode. It is moved to rejected staging, not forced into a valid language.
SELECT 'before R4' AS phase, submission_id, language FROM stg_submissions_repair WHERE submission_id = 'SUB000140';
INSERT INTO rejected_submissions
SELECT *, 'Unsupported programming language: PseudoCode' AS issue_reason
FROM stg_submissions_repair
WHERE submission_id = 'SUB000140' AND language = 'PseudoCode';
DELETE FROM stg_submissions_repair
WHERE submission_id = 'SUB000140' AND language = 'PseudoCode';
SELECT 'after R4 - remaining in staging' AS phase, COUNT(*) AS remaining_rows FROM stg_submissions_repair WHERE submission_id = 'SUB000140';
SELECT 'after R4 - rejected rows' AS phase, submission_id, language, issue_reason FROM rejected_submissions WHERE submission_id = 'SUB000140';

-- Repair 5: Test result R0000080 has result_status 'Correct'. Map it to controlled value 'Passed'.
SELECT 'before R5' AS phase, result_id, result_status FROM stg_test_results_repair WHERE result_id = 'R0000080';
UPDATE stg_test_results_repair
SET result_status = 'Passed'
WHERE result_id = 'R0000080' AND result_status = 'Correct';
SELECT 'after R5' AS phase, result_id, result_status FROM stg_test_results_repair WHERE result_id = 'R0000080';

-- Repair 6: Attendance A000046 has status 'joined'. It is equivalent to present for attendance marking.
SELECT 'before R6' AS phase, attendance_id, attendance_status FROM stg_attendance_repair WHERE attendance_id = 'A000046';
UPDATE stg_attendance_repair
SET attendance_status = 'present'
WHERE attendance_id = 'A000046' AND attendance_status = 'joined';
SELECT 'after R6' AS phase, attendance_id, attendance_status FROM stg_attendance_repair WHERE attendance_id = 'A000046';

-- Repair 7: Negative submission score SUB000056 is not valid. Clamp to 0 because score cannot be negative.
SELECT 'before R7' AS phase, submission_id, score FROM stg_submissions_repair WHERE submission_id = 'SUB000056';
UPDATE stg_submissions_repair
SET score = '0'
WHERE submission_id = 'SUB000056' AND CAST(score AS INTEGER) < 0;
SELECT 'after R7' AS phase, submission_id, score FROM stg_submissions_repair WHERE submission_id = 'SUB000056';

-- Repair 8: Negative runtime SUB000303 is not physically valid. Set to 0 and flag for possible re-run if needed.
SELECT 'before R8' AS phase, submission_id, runtime_ms FROM stg_submissions_repair WHERE submission_id = 'SUB000303';
UPDATE stg_submissions_repair
SET runtime_ms = '0'
WHERE submission_id = 'SUB000303' AND CAST(runtime_ms AS INTEGER) < 0;
SELECT 'after R8' AS phase, submission_id, runtime_ms FROM stg_submissions_repair WHERE submission_id = 'SUB000303';

-- Repair 9: SUB000103 score is greater than the problem max score. Cap it to P0040.max_score.
SELECT 'before R9' AS phase, s.submission_id, s.problem_id, s.score, p.max_score
FROM stg_submissions_repair s JOIN problems p ON p.problem_id = s.problem_id
WHERE s.submission_id = 'SUB000103';
UPDATE stg_submissions_repair
SET score = (SELECT max_score FROM problems WHERE problem_id = 'P0040')
WHERE submission_id = 'SUB000103'
  AND CAST(score AS INTEGER) > (SELECT CAST(max_score AS INTEGER) FROM problems WHERE problem_id = 'P0040');
SELECT 'after R9' AS phase, s.submission_id, s.problem_id, s.score, p.max_score
FROM stg_submissions_repair s JOIN problems p ON p.problem_id = s.problem_id
WHERE s.submission_id = 'SUB000103';

-- Repair 10: Duplicate submission_id SUB000701 belongs to two students. Preserve both rows by assigning a new staging ID to the later row.
SELECT 'before R10' AS phase, rowid, submission_id, student_id, problem_id FROM stg_submissions_repair WHERE submission_id = 'SUB000701';
UPDATE stg_submissions_repair
SET submission_id = 'SUB000701_DUP2'
WHERE rowid = (SELECT MAX(rowid) FROM stg_submissions_repair WHERE submission_id = 'SUB000701');
SELECT 'after R10' AS phase, rowid, submission_id, student_id, problem_id FROM stg_submissions_repair WHERE submission_id LIKE 'SUB000701%';

-- Repair 11: Regrade RG0019 has resolved_at before requested_at. Reopen and clear resolved_at for manual processing.
SELECT 'before R11' AS phase, request_id, request_status, requested_at, resolved_at FROM stg_regrade_requests_repair WHERE request_id = 'RG0019';
UPDATE stg_regrade_requests_repair
SET request_status = 'open', resolved_at = ''
WHERE request_id = 'RG0019' AND datetime(resolved_at) < datetime(requested_at);
SELECT 'after R11' AS phase, request_id, request_status, requested_at, resolved_at FROM stg_regrade_requests_repair WHERE request_id = 'RG0019';

-- Repair 12: Test case TC00034 has negative points. Set to 0 and keep it hidden until reviewed.
SELECT 'before R12' AS phase, test_case_id, problem_id, points, is_hidden FROM stg_test_cases_repair WHERE test_case_id = 'TC00034';
UPDATE stg_test_cases_repair
SET points = '0', is_hidden = '1'
WHERE test_case_id = 'TC00034' AND CAST(points AS INTEGER) < 0;
SELECT 'after R12' AS phase, test_case_id, problem_id, points, is_hidden FROM stg_test_cases_repair WHERE test_case_id = 'TC00034';

-- Repair 13: Students with missing/invalid email or missing batch are copied to a manual review table.
SELECT 'before R13' AS phase, student_id, full_name, email, batch_id
FROM stg_students_repair
WHERE student_id IN ('S0005', 'S0018', 'S0059', 'S0077');
INSERT INTO manual_review_students
SELECT *,
       CASE
           WHEN TRIM(COALESCE(email, '')) = '' THEN 'Missing email'
           WHEN email NOT LIKE '%_@_%._%' THEN 'Invalid email format'
           WHEN TRIM(COALESCE(batch_id, '')) = '' THEN 'Missing batch_id'
           WHEN batch_id = 'B999' THEN 'Batch_id does not exist'
           ELSE 'Manual review required'
       END AS issue_reason
FROM stg_students_repair
WHERE student_id IN ('S0005', 'S0018', 'S0059', 'S0077');
SELECT 'after R13' AS phase, student_id, full_name, issue_reason FROM manual_review_students;

COMMIT;
