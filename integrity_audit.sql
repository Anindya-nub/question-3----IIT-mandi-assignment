-- CodeJudge Part 3: Primary Key, Uniqueness, and Foreign Key Integrity Audit
-- Dialect: SQLite. These queries do not modify data.

-- ============================================================
-- Task 2: Primary key and uniqueness audit
-- ============================================================

-- Duplicate primary key values. Each query should return zero rows in a clean database.
SELECT 'batches.batch_id' AS check_name, batch_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM batches GROUP BY batch_id HAVING COUNT(*) > 1;
SELECT 'courses.course_id' AS check_name, course_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM courses GROUP BY course_id HAVING COUNT(*) > 1;
SELECT 'students.student_id' AS check_name, student_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM students GROUP BY student_id HAVING COUNT(*) > 1;
SELECT 'enrollments.enrollment_id' AS check_name, enrollment_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM enrollments GROUP BY enrollment_id HAVING COUNT(*) > 1;
SELECT 'problems.problem_id' AS check_name, problem_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM problems GROUP BY problem_id HAVING COUNT(*) > 1;
SELECT 'test_cases.test_case_id' AS check_name, test_case_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM test_cases GROUP BY test_case_id HAVING COUNT(*) > 1;
SELECT 'contests.contest_id' AS check_name, contest_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM contests GROUP BY contest_id HAVING COUNT(*) > 1;
SELECT 'submissions.submission_id' AS check_name, submission_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM submissions GROUP BY submission_id HAVING COUNT(*) > 1;
SELECT 'test_results.result_id' AS check_name, result_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM test_results GROUP BY result_id HAVING COUNT(*) > 1;
SELECT 'sessions.session_id' AS check_name, session_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM sessions GROUP BY session_id HAVING COUNT(*) > 1;
SELECT 'attendance.attendance_id' AS check_name, attendance_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM attendance GROUP BY attendance_id HAVING COUNT(*) > 1;
SELECT 'regrade_requests.request_id' AS check_name, request_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM regrade_requests GROUP BY request_id HAVING COUNT(*) > 1;
SELECT 'plagiarism_flags.flag_id' AS check_name, flag_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM plagiarism_flags GROUP BY flag_id HAVING COUNT(*) > 1;
SELECT 'raw_student_import.raw_row_id' AS check_name, raw_row_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM raw_student_import GROUP BY raw_row_id HAVING COUNT(*) > 1;
SELECT 'operation_requests.operation_id' AS check_name, operation_id AS duplicate_value, COUNT(*) AS duplicate_rows FROM operation_requests GROUP BY operation_id HAVING COUNT(*) > 1;

-- Duplicate candidate key values.
SELECT 'students.roll_number' AS check_name, roll_number, COUNT(*) AS duplicate_rows FROM students GROUP BY roll_number HAVING COUNT(*) > 1;
SELECT 'students.email' AS check_name, email, COUNT(*) AS duplicate_rows FROM students WHERE TRIM(email) <> '' GROUP BY email HAVING COUNT(*) > 1;
SELECT 'courses.course_code' AS check_name, course_code, COUNT(*) AS duplicate_rows FROM courses GROUP BY course_code HAVING COUNT(*) > 1;
SELECT 'problems.problem_code' AS check_name, problem_code, COUNT(*) AS duplicate_rows FROM problems GROUP BY problem_code HAVING COUNT(*) > 1;
SELECT 'enrollments.student_id_course_id' AS check_name, student_id, course_id, COUNT(*) AS duplicate_rows FROM enrollments GROUP BY student_id, course_id HAVING COUNT(*) > 1;
SELECT 'contest_problems.contest_id_problem_id' AS check_name, contest_id, problem_id, COUNT(*) AS duplicate_rows FROM contest_problems GROUP BY contest_id, problem_id HAVING COUNT(*) > 1;
SELECT 'test_cases.problem_id_case_no' AS check_name, problem_id, case_no, COUNT(*) AS duplicate_rows FROM test_cases GROUP BY problem_id, case_no HAVING COUNT(*) > 1;
SELECT 'test_results.submission_id_test_case_id' AS check_name, submission_id, test_case_id, COUNT(*) AS duplicate_rows FROM test_results GROUP BY submission_id, test_case_id HAVING COUNT(*) > 1;
SELECT 'attendance.session_id_student_id' AS check_name, session_id, student_id, COUNT(*) AS duplicate_rows FROM attendance GROUP BY session_id, student_id HAVING COUNT(*) > 1;

-- ============================================================
-- Task 3: Foreign key and relationship audit
-- Each query lists child records that point to a missing parent.
-- ============================================================

-- Students linked to missing batches: students cannot be grouped correctly by cohort.
SELECT s.student_id, s.full_name, s.batch_id
FROM students s
LEFT JOIN batches b ON b.batch_id = s.batch_id
WHERE b.batch_id IS NULL;

-- Enrollments linked to missing students: enrollment records become ownerless.
SELECT e.enrollment_id, e.student_id, e.course_id
FROM enrollments e
LEFT JOIN students s ON s.student_id = e.student_id
WHERE s.student_id IS NULL;

-- Enrollments linked to missing courses: students appear enrolled in a non-existent course.
SELECT e.enrollment_id, e.student_id, e.course_id
FROM enrollments e
LEFT JOIN courses c ON c.course_id = e.course_id
WHERE c.course_id IS NULL;

-- Problems linked to missing courses: problem ownership and course reporting break.
SELECT p.problem_id, p.problem_code, p.course_id
FROM problems p
LEFT JOIN courses c ON c.course_id = p.course_id
WHERE c.course_id IS NULL;

-- Test cases linked to missing problems: test cases cannot be used for valid judging.
SELECT tc.test_case_id, tc.problem_id, tc.case_no
FROM test_cases tc
LEFT JOIN problems p ON p.problem_id = tc.problem_id
WHERE p.problem_id IS NULL;

-- Contests linked to missing courses: contest-course reporting becomes invalid.
SELECT ct.contest_id, ct.contest_title, ct.course_id
FROM contests ct
LEFT JOIN courses c ON c.course_id = ct.course_id
WHERE c.course_id IS NULL;

-- Contest-problem mappings linked to missing contests.
SELECT cp.contest_id, cp.problem_id, cp.problem_order
FROM contest_problems cp
LEFT JOIN contests ct ON ct.contest_id = cp.contest_id
WHERE ct.contest_id IS NULL;

-- Contest-problem mappings linked to missing problems.
SELECT cp.contest_id, cp.problem_id, cp.problem_order
FROM contest_problems cp
LEFT JOIN problems p ON p.problem_id = cp.problem_id
WHERE p.problem_id IS NULL;

-- Submissions linked to missing students.
SELECT sub.submission_id, sub.student_id, sub.problem_id, sub.contest_id
FROM submissions sub
LEFT JOIN students s ON s.student_id = sub.student_id
WHERE s.student_id IS NULL;

-- Submissions linked to missing problems.
SELECT sub.submission_id, sub.student_id, sub.problem_id, sub.contest_id
FROM submissions sub
LEFT JOIN problems p ON p.problem_id = sub.problem_id
WHERE p.problem_id IS NULL;

-- Submissions linked to missing contests. Blank contest_id is allowed because contest_id is optional.
SELECT sub.submission_id, sub.student_id, sub.problem_id, sub.contest_id
FROM submissions sub
LEFT JOIN contests ct ON ct.contest_id = sub.contest_id
WHERE TRIM(COALESCE(sub.contest_id, '')) <> ''
  AND ct.contest_id IS NULL;

-- Test results linked to missing submissions.
SELECT tr.result_id, tr.submission_id, tr.test_case_id
FROM test_results tr
LEFT JOIN submissions sub ON sub.submission_id = tr.submission_id
WHERE sub.submission_id IS NULL;

-- Test results linked to missing test cases.
SELECT tr.result_id, tr.submission_id, tr.test_case_id
FROM test_results tr
LEFT JOIN test_cases tc ON tc.test_case_id = tr.test_case_id
WHERE tc.test_case_id IS NULL;

-- Sessions linked to missing courses.
SELECT ses.session_id, ses.course_id, ses.session_title
FROM sessions ses
LEFT JOIN courses c ON c.course_id = ses.course_id
WHERE c.course_id IS NULL;

-- Attendance linked to missing sessions.
SELECT a.attendance_id, a.session_id, a.student_id
FROM attendance a
LEFT JOIN sessions ses ON ses.session_id = a.session_id
WHERE ses.session_id IS NULL;

-- Attendance linked to missing students.
SELECT a.attendance_id, a.session_id, a.student_id
FROM attendance a
LEFT JOIN students s ON s.student_id = a.student_id
WHERE s.student_id IS NULL;

-- Regrade requests linked to missing submissions.
SELECT rr.request_id, rr.submission_id, rr.student_id
FROM regrade_requests rr
LEFT JOIN submissions sub ON sub.submission_id = rr.submission_id
WHERE sub.submission_id IS NULL;

-- Regrade requests linked to missing students.
SELECT rr.request_id, rr.submission_id, rr.student_id
FROM regrade_requests rr
LEFT JOIN students s ON s.student_id = rr.student_id
WHERE s.student_id IS NULL;

-- Plagiarism flags linked to missing source submissions.
SELECT pf.flag_id, pf.submission_id, pf.matched_submission_id
FROM plagiarism_flags pf
LEFT JOIN submissions sub ON sub.submission_id = pf.submission_id
WHERE sub.submission_id IS NULL;

-- Plagiarism flags linked to missing matched submissions.
SELECT pf.flag_id, pf.submission_id, pf.matched_submission_id
FROM plagiarism_flags pf
LEFT JOIN submissions sub ON sub.submission_id = pf.matched_submission_id
WHERE sub.submission_id IS NULL;
