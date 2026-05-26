-- CodeJudge Part 3: Import Validation Queries
-- Dialect: SQLite. Run after loading the raw CSV tables into codejudge_raw.db.
-- Purpose: verify row counts, intended primary-key distinct counts, blanks in mandatory columns, and empty tables.

-- 1. Row count of each imported table compared with raw CSV/data dictionary count.
WITH expected_counts(table_name, expected_rows) AS (
    VALUES
        ('batches', 6),
        ('courses', 10),
        ('students', 320),
        ('enrollments', 719),
        ('problems', 67),
        ('test_cases', 330),
        ('contests', 12),
        ('contest_problems', 63),
        ('submissions', 2501),
        ('test_results', 9673),
        ('sessions', 48),
        ('attendance', 2352),
        ('regrade_requests', 80),
        ('plagiarism_flags', 60),
        ('raw_student_import', 80),
        ('operation_requests', 35)
), actual_counts AS (
    SELECT 'batches' AS table_name, COUNT(*) AS actual_rows FROM batches
    UNION ALL
    SELECT 'courses' AS table_name, COUNT(*) AS actual_rows FROM courses
    UNION ALL
    SELECT 'students' AS table_name, COUNT(*) AS actual_rows FROM students
    UNION ALL
    SELECT 'enrollments' AS table_name, COUNT(*) AS actual_rows FROM enrollments
    UNION ALL
    SELECT 'problems' AS table_name, COUNT(*) AS actual_rows FROM problems
    UNION ALL
    SELECT 'test_cases' AS table_name, COUNT(*) AS actual_rows FROM test_cases
    UNION ALL
    SELECT 'contests' AS table_name, COUNT(*) AS actual_rows FROM contests
    UNION ALL
    SELECT 'contest_problems' AS table_name, COUNT(*) AS actual_rows FROM contest_problems
    UNION ALL
    SELECT 'submissions' AS table_name, COUNT(*) AS actual_rows FROM submissions
    UNION ALL
    SELECT 'test_results' AS table_name, COUNT(*) AS actual_rows FROM test_results
    UNION ALL
    SELECT 'sessions' AS table_name, COUNT(*) AS actual_rows FROM sessions
    UNION ALL
    SELECT 'attendance' AS table_name, COUNT(*) AS actual_rows FROM attendance
    UNION ALL
    SELECT 'regrade_requests' AS table_name, COUNT(*) AS actual_rows FROM regrade_requests
    UNION ALL
    SELECT 'plagiarism_flags' AS table_name, COUNT(*) AS actual_rows FROM plagiarism_flags
    UNION ALL
    SELECT 'raw_student_import' AS table_name, COUNT(*) AS actual_rows FROM raw_student_import
    UNION ALL
    SELECT 'operation_requests' AS table_name, COUNT(*) AS actual_rows FROM operation_requests
)
SELECT e.table_name,
       e.expected_rows,
       a.actual_rows,
       CASE WHEN e.expected_rows = a.actual_rows THEN 'PASS' ELSE 'FAIL' END AS count_check
FROM expected_counts e
JOIN actual_counts a ON a.table_name = e.table_name
ORDER BY e.table_name;

-- 2. Number of distinct intended primary key values in each table.
-- For contest_problems, the intended key is composite: contest_id + problem_id.
SELECT 'batches' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT batch_id) AS distinct_key_values FROM batches
UNION ALL
SELECT 'courses' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT course_id) AS distinct_key_values FROM courses
UNION ALL
SELECT 'students' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT student_id) AS distinct_key_values FROM students
UNION ALL
SELECT 'enrollments' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT enrollment_id) AS distinct_key_values FROM enrollments
UNION ALL
SELECT 'problems' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT problem_id) AS distinct_key_values FROM problems
UNION ALL
SELECT 'test_cases' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT test_case_id) AS distinct_key_values FROM test_cases
UNION ALL
SELECT 'contests' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT contest_id) AS distinct_key_values FROM contests
UNION ALL
SELECT 'contest_problems' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT contest_id || '|' || problem_id) AS distinct_key_values FROM contest_problems
UNION ALL
SELECT 'submissions' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT submission_id) AS distinct_key_values FROM submissions
UNION ALL
SELECT 'test_results' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT result_id) AS distinct_key_values FROM test_results
UNION ALL
SELECT 'sessions' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT session_id) AS distinct_key_values FROM sessions
UNION ALL
SELECT 'attendance' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT attendance_id) AS distinct_key_values FROM attendance
UNION ALL
SELECT 'regrade_requests' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT request_id) AS distinct_key_values FROM regrade_requests
UNION ALL
SELECT 'plagiarism_flags' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT flag_id) AS distinct_key_values FROM plagiarism_flags
UNION ALL
SELECT 'raw_student_import' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT raw_row_id) AS distinct_key_values FROM raw_student_import
UNION ALL
SELECT 'operation_requests' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT operation_id) AS distinct_key_values FROM operation_requests
ORDER BY table_name;

-- 3. Tables that imported as empty. Expected result: no rows.
WITH table_counts AS (
    SELECT 'batches' AS table_name, COUNT(*) AS actual_rows FROM batches
UNION ALL
SELECT 'courses' AS table_name, COUNT(*) AS actual_rows FROM courses
UNION ALL
SELECT 'students' AS table_name, COUNT(*) AS actual_rows FROM students
UNION ALL
SELECT 'enrollments' AS table_name, COUNT(*) AS actual_rows FROM enrollments
UNION ALL
SELECT 'problems' AS table_name, COUNT(*) AS actual_rows FROM problems
UNION ALL
SELECT 'test_cases' AS table_name, COUNT(*) AS actual_rows FROM test_cases
UNION ALL
SELECT 'contests' AS table_name, COUNT(*) AS actual_rows FROM contests
UNION ALL
SELECT 'contest_problems' AS table_name, COUNT(*) AS actual_rows FROM contest_problems
UNION ALL
SELECT 'submissions' AS table_name, COUNT(*) AS actual_rows FROM submissions
UNION ALL
SELECT 'test_results' AS table_name, COUNT(*) AS actual_rows FROM test_results
UNION ALL
SELECT 'sessions' AS table_name, COUNT(*) AS actual_rows FROM sessions
UNION ALL
SELECT 'attendance' AS table_name, COUNT(*) AS actual_rows FROM attendance
UNION ALL
SELECT 'regrade_requests' AS table_name, COUNT(*) AS actual_rows FROM regrade_requests
UNION ALL
SELECT 'plagiarism_flags' AS table_name, COUNT(*) AS actual_rows FROM plagiarism_flags
UNION ALL
SELECT 'raw_student_import' AS table_name, COUNT(*) AS actual_rows FROM raw_student_import
UNION ALL
SELECT 'operation_requests' AS table_name, COUNT(*) AS actual_rows FROM operation_requests
)
SELECT table_name, actual_rows
FROM table_counts
WHERE actual_rows = 0;

-- 4. NULL or blank values in columns that should normally be mandatory.
-- final_grade, contest_id, resolved_at, executed_at, import_notes are not included because they may be optional.
WITH blank_counts AS (
SELECT 'batches' AS table_name, 'batch_id' AS column_name, COUNT(*) AS blank_count FROM batches WHERE batch_id IS NULL OR TRIM(batch_id) = ''
UNION ALL
SELECT 'batches' AS table_name, 'batch_code' AS column_name, COUNT(*) AS blank_count FROM batches WHERE batch_code IS NULL OR TRIM(batch_code) = ''
UNION ALL
SELECT 'batches' AS table_name, 'program' AS column_name, COUNT(*) AS blank_count FROM batches WHERE program IS NULL OR TRIM(program) = ''
UNION ALL
SELECT 'batches' AS table_name, 'start_date' AS column_name, COUNT(*) AS blank_count FROM batches WHERE start_date IS NULL OR TRIM(start_date) = ''
UNION ALL
SELECT 'batches' AS table_name, 'end_date' AS column_name, COUNT(*) AS blank_count FROM batches WHERE end_date IS NULL OR TRIM(end_date) = ''
UNION ALL
SELECT 'batches' AS table_name, 'batch_status' AS column_name, COUNT(*) AS blank_count FROM batches WHERE batch_status IS NULL OR TRIM(batch_status) = ''
UNION ALL
SELECT 'courses' AS table_name, 'course_id' AS column_name, COUNT(*) AS blank_count FROM courses WHERE course_id IS NULL OR TRIM(course_id) = ''
UNION ALL
SELECT 'courses' AS table_name, 'course_code' AS column_name, COUNT(*) AS blank_count FROM courses WHERE course_code IS NULL OR TRIM(course_code) = ''
UNION ALL
SELECT 'courses' AS table_name, 'course_title' AS column_name, COUNT(*) AS blank_count FROM courses WHERE course_title IS NULL OR TRIM(course_title) = ''
UNION ALL
SELECT 'courses' AS table_name, 'course_status' AS column_name, COUNT(*) AS blank_count FROM courses WHERE course_status IS NULL OR TRIM(course_status) = ''
UNION ALL
SELECT 'courses' AS table_name, 'credit_hours' AS column_name, COUNT(*) AS blank_count FROM courses WHERE credit_hours IS NULL OR TRIM(credit_hours) = ''
UNION ALL
SELECT 'students' AS table_name, 'student_id' AS column_name, COUNT(*) AS blank_count FROM students WHERE student_id IS NULL OR TRIM(student_id) = ''
UNION ALL
SELECT 'students' AS table_name, 'roll_number' AS column_name, COUNT(*) AS blank_count FROM students WHERE roll_number IS NULL OR TRIM(roll_number) = ''
UNION ALL
SELECT 'students' AS table_name, 'full_name' AS column_name, COUNT(*) AS blank_count FROM students WHERE full_name IS NULL OR TRIM(full_name) = ''
UNION ALL
SELECT 'students' AS table_name, 'email' AS column_name, COUNT(*) AS blank_count FROM students WHERE email IS NULL OR TRIM(email) = ''
UNION ALL
SELECT 'students' AS table_name, 'batch_id' AS column_name, COUNT(*) AS blank_count FROM students WHERE batch_id IS NULL OR TRIM(batch_id) = ''
UNION ALL
SELECT 'students' AS table_name, 'admission_date' AS column_name, COUNT(*) AS blank_count FROM students WHERE admission_date IS NULL OR TRIM(admission_date) = ''
UNION ALL
SELECT 'students' AS table_name, 'enrollment_status' AS column_name, COUNT(*) AS blank_count FROM students WHERE enrollment_status IS NULL OR TRIM(enrollment_status) = ''
UNION ALL
SELECT 'students' AS table_name, 'graduation_year' AS column_name, COUNT(*) AS blank_count FROM students WHERE graduation_year IS NULL OR TRIM(graduation_year) = ''
UNION ALL
SELECT 'enrollments' AS table_name, 'enrollment_id' AS column_name, COUNT(*) AS blank_count FROM enrollments WHERE enrollment_id IS NULL OR TRIM(enrollment_id) = ''
UNION ALL
SELECT 'enrollments' AS table_name, 'student_id' AS column_name, COUNT(*) AS blank_count FROM enrollments WHERE student_id IS NULL OR TRIM(student_id) = ''
UNION ALL
SELECT 'enrollments' AS table_name, 'course_id' AS column_name, COUNT(*) AS blank_count FROM enrollments WHERE course_id IS NULL OR TRIM(course_id) = ''
UNION ALL
SELECT 'enrollments' AS table_name, 'enrolled_on' AS column_name, COUNT(*) AS blank_count FROM enrollments WHERE enrolled_on IS NULL OR TRIM(enrolled_on) = ''
UNION ALL
SELECT 'enrollments' AS table_name, 'enrollment_status' AS column_name, COUNT(*) AS blank_count FROM enrollments WHERE enrollment_status IS NULL OR TRIM(enrollment_status) = ''
UNION ALL
SELECT 'problems' AS table_name, 'problem_id' AS column_name, COUNT(*) AS blank_count FROM problems WHERE problem_id IS NULL OR TRIM(problem_id) = ''
UNION ALL
SELECT 'problems' AS table_name, 'course_id' AS column_name, COUNT(*) AS blank_count FROM problems WHERE course_id IS NULL OR TRIM(course_id) = ''
UNION ALL
SELECT 'problems' AS table_name, 'problem_code' AS column_name, COUNT(*) AS blank_count FROM problems WHERE problem_code IS NULL OR TRIM(problem_code) = ''
UNION ALL
SELECT 'problems' AS table_name, 'title' AS column_name, COUNT(*) AS blank_count FROM problems WHERE title IS NULL OR TRIM(title) = ''
UNION ALL
SELECT 'problems' AS table_name, 'difficulty' AS column_name, COUNT(*) AS blank_count FROM problems WHERE difficulty IS NULL OR TRIM(difficulty) = ''
UNION ALL
SELECT 'problems' AS table_name, 'max_score' AS column_name, COUNT(*) AS blank_count FROM problems WHERE max_score IS NULL OR TRIM(max_score) = ''
UNION ALL
SELECT 'problems' AS table_name, 'created_at' AS column_name, COUNT(*) AS blank_count FROM problems WHERE created_at IS NULL OR TRIM(created_at) = ''
UNION ALL
SELECT 'problems' AS table_name, 'is_active' AS column_name, COUNT(*) AS blank_count FROM problems WHERE is_active IS NULL OR TRIM(is_active) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'test_case_id' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE test_case_id IS NULL OR TRIM(test_case_id) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'problem_id' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE problem_id IS NULL OR TRIM(problem_id) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'case_no' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE case_no IS NULL OR TRIM(case_no) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'input_label' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE input_label IS NULL OR TRIM(input_label) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'expected_output_label' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE expected_output_label IS NULL OR TRIM(expected_output_label) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'points' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE points IS NULL OR TRIM(points) = ''
UNION ALL
SELECT 'test_cases' AS table_name, 'is_hidden' AS column_name, COUNT(*) AS blank_count FROM test_cases WHERE is_hidden IS NULL OR TRIM(is_hidden) = ''
UNION ALL
SELECT 'contests' AS table_name, 'contest_id' AS column_name, COUNT(*) AS blank_count FROM contests WHERE contest_id IS NULL OR TRIM(contest_id) = ''
UNION ALL
SELECT 'contests' AS table_name, 'course_id' AS column_name, COUNT(*) AS blank_count FROM contests WHERE course_id IS NULL OR TRIM(course_id) = ''
UNION ALL
SELECT 'contests' AS table_name, 'contest_title' AS column_name, COUNT(*) AS blank_count FROM contests WHERE contest_title IS NULL OR TRIM(contest_title) = ''
UNION ALL
SELECT 'contests' AS table_name, 'start_time' AS column_name, COUNT(*) AS blank_count FROM contests WHERE start_time IS NULL OR TRIM(start_time) = ''
UNION ALL
SELECT 'contests' AS table_name, 'end_time' AS column_name, COUNT(*) AS blank_count FROM contests WHERE end_time IS NULL OR TRIM(end_time) = ''
UNION ALL
SELECT 'contests' AS table_name, 'contest_status' AS column_name, COUNT(*) AS blank_count FROM contests WHERE contest_status IS NULL OR TRIM(contest_status) = ''
UNION ALL
SELECT 'contest_problems' AS table_name, 'contest_id' AS column_name, COUNT(*) AS blank_count FROM contest_problems WHERE contest_id IS NULL OR TRIM(contest_id) = ''
UNION ALL
SELECT 'contest_problems' AS table_name, 'problem_id' AS column_name, COUNT(*) AS blank_count FROM contest_problems WHERE problem_id IS NULL OR TRIM(problem_id) = ''
UNION ALL
SELECT 'contest_problems' AS table_name, 'problem_order' AS column_name, COUNT(*) AS blank_count FROM contest_problems WHERE problem_order IS NULL OR TRIM(problem_order) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'submission_id' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE submission_id IS NULL OR TRIM(submission_id) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'student_id' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE student_id IS NULL OR TRIM(student_id) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'problem_id' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE problem_id IS NULL OR TRIM(problem_id) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'language' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE language IS NULL OR TRIM(language) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'submitted_at' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE submitted_at IS NULL OR TRIM(submitted_at) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'status' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE status IS NULL OR TRIM(status) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'score' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE score IS NULL OR TRIM(score) = ''
UNION ALL
SELECT 'submissions' AS table_name, 'runtime_ms' AS column_name, COUNT(*) AS blank_count FROM submissions WHERE runtime_ms IS NULL OR TRIM(runtime_ms) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'result_id' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE result_id IS NULL OR TRIM(result_id) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'submission_id' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE submission_id IS NULL OR TRIM(submission_id) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'test_case_id' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE test_case_id IS NULL OR TRIM(test_case_id) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'result_status' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE result_status IS NULL OR TRIM(result_status) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'runtime_ms' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE runtime_ms IS NULL OR TRIM(runtime_ms) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'memory_kb' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE memory_kb IS NULL OR TRIM(memory_kb) = ''
UNION ALL
SELECT 'test_results' AS table_name, 'awarded_points' AS column_name, COUNT(*) AS blank_count FROM test_results WHERE awarded_points IS NULL OR TRIM(awarded_points) = ''
UNION ALL
SELECT 'sessions' AS table_name, 'session_id' AS column_name, COUNT(*) AS blank_count FROM sessions WHERE session_id IS NULL OR TRIM(session_id) = ''
UNION ALL
SELECT 'sessions' AS table_name, 'course_id' AS column_name, COUNT(*) AS blank_count FROM sessions WHERE course_id IS NULL OR TRIM(course_id) = ''
UNION ALL
SELECT 'sessions' AS table_name, 'session_title' AS column_name, COUNT(*) AS blank_count FROM sessions WHERE session_title IS NULL OR TRIM(session_title) = ''
UNION ALL
SELECT 'sessions' AS table_name, 'session_date' AS column_name, COUNT(*) AS blank_count FROM sessions WHERE session_date IS NULL OR TRIM(session_date) = ''
UNION ALL
SELECT 'sessions' AS table_name, 'session_type' AS column_name, COUNT(*) AS blank_count FROM sessions WHERE session_type IS NULL OR TRIM(session_type) = ''
UNION ALL
SELECT 'attendance' AS table_name, 'attendance_id' AS column_name, COUNT(*) AS blank_count FROM attendance WHERE attendance_id IS NULL OR TRIM(attendance_id) = ''
UNION ALL
SELECT 'attendance' AS table_name, 'session_id' AS column_name, COUNT(*) AS blank_count FROM attendance WHERE session_id IS NULL OR TRIM(session_id) = ''
UNION ALL
SELECT 'attendance' AS table_name, 'student_id' AS column_name, COUNT(*) AS blank_count FROM attendance WHERE student_id IS NULL OR TRIM(student_id) = ''
UNION ALL
SELECT 'attendance' AS table_name, 'attendance_status' AS column_name, COUNT(*) AS blank_count FROM attendance WHERE attendance_status IS NULL OR TRIM(attendance_status) = ''
UNION ALL
SELECT 'attendance' AS table_name, 'marked_at' AS column_name, COUNT(*) AS blank_count FROM attendance WHERE marked_at IS NULL OR TRIM(marked_at) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'request_id' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE request_id IS NULL OR TRIM(request_id) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'submission_id' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE submission_id IS NULL OR TRIM(submission_id) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'student_id' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE student_id IS NULL OR TRIM(student_id) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'requested_at' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE requested_at IS NULL OR TRIM(requested_at) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'reason' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE reason IS NULL OR TRIM(reason) = ''
UNION ALL
SELECT 'regrade_requests' AS table_name, 'request_status' AS column_name, COUNT(*) AS blank_count FROM regrade_requests WHERE request_status IS NULL OR TRIM(request_status) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'flag_id' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE flag_id IS NULL OR TRIM(flag_id) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'submission_id' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE submission_id IS NULL OR TRIM(submission_id) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'matched_submission_id' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE matched_submission_id IS NULL OR TRIM(matched_submission_id) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'similarity_score' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE similarity_score IS NULL OR TRIM(similarity_score) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'flag_status' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE flag_status IS NULL OR TRIM(flag_status) = ''
UNION ALL
SELECT 'plagiarism_flags' AS table_name, 'created_at' AS column_name, COUNT(*) AS blank_count FROM plagiarism_flags WHERE created_at IS NULL OR TRIM(created_at) = ''
UNION ALL
SELECT 'raw_student_import' AS table_name, 'raw_row_id' AS column_name, COUNT(*) AS blank_count FROM raw_student_import WHERE raw_row_id IS NULL OR TRIM(raw_row_id) = ''
UNION ALL
SELECT 'raw_student_import' AS table_name, 'roll_number' AS column_name, COUNT(*) AS blank_count FROM raw_student_import WHERE roll_number IS NULL OR TRIM(roll_number) = ''
UNION ALL
SELECT 'raw_student_import' AS table_name, 'email' AS column_name, COUNT(*) AS blank_count FROM raw_student_import WHERE email IS NULL OR TRIM(email) = ''
UNION ALL
SELECT 'raw_student_import' AS table_name, 'admission_date' AS column_name, COUNT(*) AS blank_count FROM raw_student_import WHERE admission_date IS NULL OR TRIM(admission_date) = ''
UNION ALL
SELECT 'raw_student_import' AS table_name, 'import_status' AS column_name, COUNT(*) AS blank_count FROM raw_student_import WHERE import_status IS NULL OR TRIM(import_status) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'operation_id' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE operation_id IS NULL OR TRIM(operation_id) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'requested_by' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE requested_by IS NULL OR TRIM(requested_by) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'operation_type' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE operation_type IS NULL OR TRIM(operation_type) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'target_table' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE target_table IS NULL OR TRIM(target_table) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'requested_at' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE requested_at IS NULL OR TRIM(requested_at) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'reason' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE reason IS NULL OR TRIM(reason) = ''
UNION ALL
SELECT 'operation_requests' AS table_name, 'approval_status' AS column_name, COUNT(*) AS blank_count FROM operation_requests WHERE approval_status IS NULL OR TRIM(approval_status) = ''
)
SELECT table_name, column_name, blank_count,
       CASE WHEN blank_count = 0 THEN 'PASS' ELSE 'FAIL' END AS blank_check
FROM blank_counts
WHERE blank_count > 0
ORDER BY table_name, column_name;

-- 5. Specific email import quality check for student source tables.
SELECT 'students' AS table_name, COUNT(*) AS invalid_or_blank_emails
FROM students
WHERE email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%_@_%._%'
UNION ALL
SELECT 'raw_student_import' AS table_name, COUNT(*) AS invalid_or_blank_emails
FROM raw_student_import
WHERE email IS NULL OR TRIM(email) = '' OR email NOT LIKE '%_@_%._%';
