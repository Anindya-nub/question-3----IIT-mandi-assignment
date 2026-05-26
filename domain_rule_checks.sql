-- CodeJudge Part 3: Domain and Rule Validation Checks
-- Dialect: SQLite. These queries do not modify data.

-- Invalid status/domain values.
SELECT student_id, enrollment_status FROM students WHERE enrollment_status NOT IN ('active', 'inactive', 'dropped', 'graduated');
SELECT enrollment_id, student_id, course_id, enrollment_status FROM enrollments WHERE enrollment_status NOT IN ('active', 'completed', 'dropped');
SELECT problem_id, difficulty FROM problems WHERE difficulty NOT IN ('Easy', 'Medium', 'Hard', 'Very Hard');
SELECT contest_id, contest_status FROM contests WHERE contest_status NOT IN ('scheduled', 'published', 'completed');
SELECT submission_id, status FROM submissions WHERE status NOT IN ('Accepted', 'Wrong Answer', 'Runtime Error', 'Compilation Error', 'Time Limit Exceeded');
SELECT submission_id, language FROM submissions WHERE language NOT IN ('C', 'C++', 'Go', 'Java', 'JavaScript', 'Python');
SELECT result_id, result_status FROM test_results WHERE result_status NOT IN ('Passed', 'Failed', 'Skipped', 'Runtime Error', 'Time Limit Exceeded');
SELECT attendance_id, attendance_status FROM attendance WHERE attendance_status NOT IN ('present', 'absent', 'late');
SELECT request_id, request_status FROM regrade_requests WHERE request_status NOT IN ('open', 'approved', 'rejected', 'closed');
SELECT flag_id, flag_status FROM plagiarism_flags WHERE flag_status NOT IN ('new', 'reviewing', 'confirmed', 'cleared');
SELECT operation_id, operation_type, target_table, target_record_id FROM operation_requests WHERE operation_type NOT IN ('INSERT', 'UPDATE', 'DELETE', 'MERGE');
SELECT operation_id, approval_status FROM operation_requests WHERE approval_status NOT IN ('pending', 'approved', 'rejected');

-- Numeric rule checks.
SELECT submission_id, score, runtime_ms FROM submissions WHERE CAST(score AS INTEGER) < 0 OR CAST(runtime_ms AS INTEGER) < 0;

-- Submissions whose score is greater than the problem's maximum marks.
SELECT sub.submission_id, sub.problem_id, sub.score, p.max_score
FROM submissions sub
JOIN problems p ON p.problem_id = sub.problem_id
WHERE CAST(sub.score AS INTEGER) > CAST(p.max_score AS INTEGER);

-- Invalid problem/test-case numbers and marks.
SELECT course_id, course_code, credit_hours FROM courses WHERE CAST(credit_hours AS INTEGER) <= 0;
SELECT problem_id, max_score FROM problems WHERE CAST(max_score AS INTEGER) <= 0;
SELECT test_case_id, problem_id, case_no FROM test_cases WHERE CAST(case_no AS INTEGER) <= 0;
SELECT test_case_id, problem_id, points FROM test_cases WHERE CAST(points AS INTEGER) < 0;

-- Test result numeric checks.
SELECT result_id, runtime_ms, memory_kb, awarded_points
FROM test_results
WHERE CAST(runtime_ms AS INTEGER) < 0
   OR CAST(memory_kb AS INTEGER) < 0
   OR CAST(awarded_points AS INTEGER) < 0;

-- Awarded points should not exceed the test case's points.
SELECT tr.result_id, tr.submission_id, tr.test_case_id, tr.awarded_points, tc.points
FROM test_results tr
JOIN test_cases tc ON tc.test_case_id = tr.test_case_id
WHERE CAST(tr.awarded_points AS INTEGER) > CAST(tc.points AS INTEGER);

-- Boolean-like flag checks.
SELECT problem_id, is_active FROM problems WHERE is_active NOT IN ('0', '1');
SELECT test_case_id, is_hidden FROM test_cases WHERE is_hidden NOT IN ('0', '1');

-- Time-order rule checks.
SELECT batch_id, start_date, end_date FROM batches WHERE date(end_date) < date(start_date);
SELECT contest_id, start_time, end_time FROM contests WHERE datetime(end_time) < datetime(start_time);
SELECT request_id, requested_at, resolved_at FROM regrade_requests WHERE TRIM(COALESCE(resolved_at, '')) <> '' AND datetime(resolved_at) < datetime(requested_at);
SELECT operation_id, requested_at, executed_at FROM operation_requests WHERE TRIM(COALESCE(executed_at, '')) <> '' AND datetime(executed_at) < datetime(requested_at);

-- Submission timestamp before enrollment date for the same student and course.
SELECT sub.submission_id, sub.student_id, p.course_id, sub.problem_id, sub.submitted_at, e.enrollment_id, e.enrolled_on
FROM submissions sub
JOIN problems p ON p.problem_id = sub.problem_id
JOIN enrollments e ON e.student_id = sub.student_id AND e.course_id = p.course_id
WHERE datetime(sub.submitted_at) < datetime(e.enrolled_on);

-- Mandatory blank checks that are most harmful in this dataset.
SELECT student_id, full_name, email FROM students WHERE email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%_@_%._%';
SELECT student_id, full_name, batch_id FROM students WHERE batch_id IS NULL OR TRIM(batch_id) = '';
SELECT raw_row_id, full_name, email FROM raw_student_import WHERE email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%_@_%._%';

-- Optional but useful: operation request target IDs look suspicious when the prefix does not match the target table.
SELECT operation_id, operation_type, target_table, target_record_id
FROM operation_requests
WHERE (target_table = 'students' AND target_record_id NOT LIKE 'S%')
   OR (target_table = 'enrollments' AND target_record_id NOT LIKE 'E%')
   OR (target_table = 'submissions' AND target_record_id NOT LIKE 'SUB%')
   OR (target_table = 'test_results' AND target_record_id NOT LIKE 'R%')
   OR (target_table = 'problems' AND target_record_id NOT LIKE 'P%');
