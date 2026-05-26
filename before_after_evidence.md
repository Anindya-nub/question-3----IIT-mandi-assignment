# Before/After Evidence

The following evidence is based on running `staging_repair_scripts.sql` on staging copies of the raw tables. Original tables are not changed.

## R1 student status typo

| student_id   | enrollment_status   |
|:-------------|:--------------------|
| S0089        | active              |

## R2 enrollment status value

| enrollment_id   | enrollment_status   |
|:----------------|:--------------------|
| E00042          | active              |

## R3 submission status OK

| submission_id   | status   |
|:----------------|:---------|
| SUB000208       | Accepted |

## R4 unsupported language rejected

| submission_id   | language   | issue_reason                                 |
|:----------------|:-----------|:---------------------------------------------|
| SUB000140       | PseudoCode | Unsupported programming language: PseudoCode |

## R5 test result status synonym

| result_id   | result_status   |
|:------------|:----------------|
| R0000080    | Passed          |

## R6 attendance status synonym

| attendance_id   | attendance_status   |
|:----------------|:--------------------|
| A000046         | present             |

## R7 negative score

| submission_id   |   score |
|:----------------|--------:|
| SUB000056       |       0 |

## R8 negative runtime

| submission_id   |   runtime_ms |
|:----------------|-------------:|
| SUB000303       |            0 |

## R9 score capped to max

| submission_id   |   score |   max_score |
|:----------------|--------:|------------:|
| SUB000103       |      75 |          75 |

## R10 duplicate submission ID preserved

| submission_id   | student_id   |
|:----------------|:-------------|
| SUB000701       | S0054        |
| SUB000701_DUP2  | S0248        |

## R11 invalid regrade time reopened

| request_id   | request_status   | requested_at        | resolved_at   |
|:-------------|:-----------------|:--------------------|:--------------|
| RG0019       | open             | 2025-03-30 16:08:00 |               |

## R12 negative test-case points

| test_case_id   |   points |   is_hidden |
|:---------------|---------:|------------:|
| TC00034        |        0 |           1 |

## R13 manual review students

| student_id   | issue_reason            |
|:-------------|:------------------------|
| S0005        | Missing email           |
| S0018        | Invalid email format    |
| S0059        | Batch_id does not exist |
| S0077        | Missing batch_id        |

## Validation Summary

After the staging script runs, the selected repaired rows no longer contain the original invalid values. Unsupported or non-inferable records are copied into review/rejected tables instead of being silently modified.
