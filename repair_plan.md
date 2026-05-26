# Repair Plan

This repair plan separates issues into safe automatic corrections, rejected/staging records, and manual verification items. The original imported tables should remain unchanged. All repair actions should happen on staging copies first.

## Repair Principles

1. **Correct obvious spelling/synonym errors** when the intended controlled value is clear.
2. **Reject or stage records** when no reliable parent record exists or the value cannot be inferred.
3. **Do not invent missing business data** such as unknown student emails or missing batches.
4. **Preserve evidence** by copying bad rows into review/rejected tables before deletion from staging.
5. **Apply foreign keys only after cleanup**, because the raw CSV data contains intentional inconsistencies.

## Specific Dataset Examples

| # | Issue | Actual ID / Value | Proposed Action | Reason |
|---|---|---|---|---|
| 1 | Student status typo | `S0089`, `enrollment_status = actve` | Correct to `active` | Clear spelling mistake; same meaning as valid domain value. |
| 2 | Enrollment status outside allowed domain | `E00042`, `enrollment_status = ongoing` | Correct to `active` after verification | `ongoing` is semantically equivalent to an active enrollment. |
| 3 | Invalid submission status | `SUB000208`, `status = OK` | Correct to `Accepted` | In judging systems, `OK` usually means successful run/accepted answer. |
| 4 | Unsupported programming language | `SUB000140`, `language = PseudoCode` | Move to `rejected_submissions` | It cannot be executed by the judge and should not be forced into another language. |
| 5 | Invalid test-result status | `R0000080`, `result_status = Correct` | Correct to `Passed` | `Correct` is a synonym for the valid test-result value `Passed`. |
| 6 | Invalid attendance status | `A000046`, `attendance_status = joined` | Correct to `present` | `joined` indicates the student attended the session. |
| 7 | Negative submission score | `SUB000056`, `score = -10` | Correct to `0` | Scores cannot be negative; zero is the lowest valid value. |
| 8 | Negative runtime | `SUB000303`, `runtime_ms = -50` | Correct to `0` and flag if needed | Runtime cannot be negative. Zero is safer than leaving invalid numeric data. |
| 9 | Score greater than max score | `SUB000103`, `score = 999`, `P0040.max_score = 75` | Cap score to `75` | A submission score should not exceed the problem's maximum marks. |
| 10 | Duplicate submission primary key | Two rows with `SUB000701` | Assign new staging ID `SUB000701_DUP2` to the second row | Both rows refer to different students, so deleting one may lose real activity. |
| 11 | Resolved before requested | `RG0019`, `resolved_at < requested_at` | Reopen request and clear `resolved_at` | The resolution timestamp is logically impossible. |
| 12 | Negative test-case points | `TC00034`, `points = -5` | Set points to `0` and keep hidden | Test-case marks cannot be negative; manual review still needed. |
| 13 | Missing student email | `S0005`, blank email | Move/copy to manual review | Email cannot be invented safely. |
| 14 | Invalid email format | `S0018`, `ravi.no-at-symbol.codejudge.edu` | Move/copy to manual review | Needs source-system correction. |
| 15 | Missing batch link | `S0077`, blank `batch_id` | Move/copy to manual review | Batch assignment cannot be guessed. |
| 16 | Missing batch parent | `S0059`, `batch_id = B999` | Move/copy to manual review | Parent batch does not exist in `batches`. |
| 17 | Orphan enrollment student | `E00718`, `student_id = S9999` | Move to rejected/staging table | Enrollment has no valid student parent. |
| 18 | Orphan enrollment course | `E00719`, `course_id = C999` | Move to rejected/staging table | Enrollment has no valid course parent. |
| 19 | Contest end before start | `CT005`, end time before start time | Ask manual verification | Duration cannot be inferred with certainty. |
| 20 | Invalid operation request | `OP0003`, `operation_type = DROP` | Reject or require senior approval | `DROP` is destructive and outside the normal operation domain. |

## Issue Category Decisions

### Duplicate Primary or Candidate Keys

- **Safe duplicate rows** with identical content can be deleted from staging after preserving a copy.
- **Conflicting duplicates** must be manually checked. Example: `SUB000701` belongs to two different students, so both rows are preserved by assigning a staging-only replacement ID to the second row.

### Foreign-Key Orphans

Rows like `E00718`, `E00719`, `SUB000013`, `SUB000038`, `R0000012`, and `PF0020` should not be inserted into the clean schema until their missing parent records are resolved. The safest repair is to move them to rejected/staging tables.

### Invalid Domain Values

Clear synonyms such as `OK`, `Correct`, `joined`, and spelling errors like `actve` can be corrected. Ambiguous values such as unsupported language `PseudoCode` should be rejected or manually verified.

### Invalid Numeric Values

Negative score, runtime, memory, or marks should be corrected only when there is a safe default. `score = -10` can become `0`, but unusual judge outcomes may require rerun evidence.

### Invalid Timestamps

Timestamps such as `RG0019.resolved_at` before `requested_at` should not be guessed. The request can be reopened and sent for manual review.
