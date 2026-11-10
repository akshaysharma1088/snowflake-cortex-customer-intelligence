-- BIRD-inspired resolution experiment v2. Independent from v1.
-- Synthetic constructed vignettes, NOT the BIRD paper's 90 public-corpus cases.
USE WAREHOUSE CORTEX_CI_WH;
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;

CREATE TABLE IF NOT EXISTS RESOLUTION_V2_CASES (
  CASE_ID VARCHAR, TRANSCRIPT VARCHAR, GOLD_RESOLUTION VARCHAR,
  GOLD_DISSATISFACTION VARCHAR, COHORT VARCHAR
);
CREATE TABLE IF NOT EXISTS RESOLUTION_V2_RESULTS (
  CASE_ID VARCHAR, VERSION VARCHAR, RUN_AT TIMESTAMP_NTZ,
  RESOLUTION_RAW VARIANT
);

MERGE INTO RESOLUTION_V2_CASES t
USING (
 SELECT column1::VARCHAR CASE_ID, column2::VARCHAR TRANSCRIPT,
        column3::VARCHAR GOLD_RESOLUTION,
        column4::VARCHAR GOLD_DISSATISFACTION,
        column5::VARCHAR COHORT
 FROM VALUES
 ('R2-001','Thanks for checking, but the fix still does not work.','reported_unresolved','yes','courtesy_unresolved'),
 ('R2-002','I appreciate the update, but my account remains locked.','reported_unresolved','yes','courtesy_unresolved'),
 ('R2-003','Please help. The refund has not arrived yet.','reported_unresolved','yes','courtesy_unresolved'),
 ('R2-004','Thanks, the app is still crashing after the patch.','reported_unresolved','yes','courtesy_unresolved'),
 ('R2-005','I am still seeing error ERR-502.','reported_unresolved','yes','explicit_unresolved'),
 ('R2-006','The duplicate invoice charge remains on my account.','reported_unresolved','yes','explicit_unresolved'),
 ('R2-007','The integration fails every time I retry.','reported_unresolved','yes','explicit_unresolved'),
 ('R2-008','No one has fixed the access issue yet.','reported_unresolved','yes','explicit_unresolved'),
 ('R2-009','Thank you! I can log in and confirm everything is working now.','confirmed_resolved','no_evidence','confirmed_resolved'),
 ('R2-010','The refund arrived in my account today. The matter is resolved.','confirmed_resolved','no_evidence','confirmed_resolved'),
 ('R2-011','I tested the webhook again; the error is gone and delivery succeeds.','confirmed_resolved','no_evidence','confirmed_resolved'),
 ('R2-012','The dashboard loads normally after the change. It is fixed.','confirmed_resolved','no_evidence','confirmed_resolved'),
 ('R2-013','Please send the updated receipt.','unknown','no_evidence','procedural_unknown'),
 ('R2-014','Can you provide the API documentation?','unknown','no_evidence','procedural_unknown'),
 ('R2-015','Thanks for the information. I will check it later.','unknown','no_evidence','procedural_unknown'),
 ('R2-016','The agent said a refund will be processed tomorrow.','unknown','no_evidence','agent_promise_unknown'),
 ('R2-017','Support has opened a ticket and promised an investigation.','unknown','no_evidence','agent_promise_unknown'),
 ('R2-018','Please let me know when a fix is available.','unknown','no_evidence','procedural_unknown'),
 ('R2-019','The agent says my issue is resolved, but I still cannot sign in.','disputed','yes','disputed'),
 ('R2-020','The ticket was closed as fixed. I tested it, and the crash remains.','disputed','yes','disputed'),
 ('R2-021','Support marked the refund complete, but the money has not arrived.','disputed','yes','disputed'),
 ('R2-022','The technician says everything works; I still see the same error.','disputed','yes','disputed'),
 ('R2-023','You told me the export was repaired, but it continues failing.','disputed','yes','disputed'),
 ('R2-024','The case shows resolved even though the integration is still broken.','disputed','yes','disputed')
) s
ON t.CASE_ID=s.CASE_ID
WHEN NOT MATCHED THEN INSERT (CASE_ID,TRANSCRIPT,GOLD_RESOLUTION,GOLD_DISSATISFACTION,COHORT)
VALUES (s.CASE_ID,s.TRANSCRIPT,s.GOLD_RESOLUTION,s.GOLD_DISSATISFACTION,s.COHORT);

SELECT GOLD_RESOLUTION, COUNT(*) AS N
FROM RESOLUTION_V2_CASES GROUP BY GOLD_RESOLUTION ORDER BY GOLD_RESOLUTION;
