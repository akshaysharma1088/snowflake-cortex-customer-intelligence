-- =========================================================
-- Cortex customer intelligence — 200-case synthetic benchmark
-- Trial-friendly one-file script; run all statements in order.
-- PRECONDITION: Database CORTEX_CI_DEMO and warehouse CORTEX_CI_WH exist.
-- EXPENSE: 200 AI_CLASSIFY inference calls (if no prior v3 results).
-- Version: resolution-v3.0; deliberately separate from v2 cases.
-- =========================================================
USE WAREHOUSE CORTEX_CI_WH;
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;

CREATE TABLE IF NOT EXISTS RESOLUTION_V3_CASES (
  CASE_ID VARCHAR,
  TRANSCRIPT VARCHAR,
  GOLD_RESOLUTION VARCHAR,
  GOLD_DISSATISFACTION VARCHAR,
  COHORT VARCHAR,
  PRODUCT VARCHAR,
  DOMAIN VARCHAR
);

CREATE TABLE IF NOT EXISTS RESOLUTION_V3_RESULTS (
  CASE_ID VARCHAR,
  VERSION VARCHAR,
  RUN_AT TIMESTAMP_NTZ,
  RESOLUTION_RAW VARIANT
);

-- All 200 texts are synthetic and intentionally template-driven.
MERGE INTO RESOLUTION_V3_CASES t USING (
 SELECT COLUMN1::VARCHAR AS CASE_ID,
        COLUMN2::VARCHAR AS TRANSCRIPT,
        COLUMN3::VARCHAR AS GOLD_RESOLUTION,
        COLUMN4::VARCHAR AS GOLD_DISSATISFACTION,
        COLUMN5::VARCHAR AS COHORT,
        COLUMN6::VARCHAR AS PRODUCT,
        COLUMN7::VARCHAR AS DOMAIN
 FROM VALUES

) s ON t.CASE_ID=s.CASE_ID
WHEN NOT MATCHED THEN INSERT
 (CASE_ID,TRANSCRIPT,GOLD_RESOLUTION,GOLD_DISSATISFACTION,COHORT,PRODUCT,DOMAIN)
 VALUES (s.CASE_ID,s.TRANSCRIPT,s.GOLD_RESOLUTION,
         s.GOLD_DISSATISFACTION,s.COHORT,s.PRODUCT,s.DOMAIN);

-- Optional: this query should report 200 / 50 per reference class.
SELECT GOLD_RESOLUTION, COUNT(*) AS CASES
FROM RESOLUTION_V3_CASES WHERE CASE_ID LIKE 'R3-%'
GROUP BY GOLD_RESOLUTION ORDER BY GOLD_RESOLUTION;

-- Execute 200 classifications once. Successful existing results are skipped.
-- This is a *new* version, never overwrites v2.
INSERT INTO RESOLUTION_V3_RESULTS (CASE_ID, VERSION, RUN_AT, RESOLUTION_RAW)
SELECT c.CASE_ID, 'resolution-v3.0', CURRENT_TIMESTAMP(),
       AI_CLASSIFY(
         c.TRANSCRIPT,
         [
          {'label':'confirmed_resolved',
           'description':'The customer explicitly confirms they tested a fix or received the desired outcome and the problem is resolved.'},
          {'label':'reported_unresolved',
           'description':'The customer reports the problem is ongoing or an attempted fix failed, without explicitly contradicting a previous declaration that it was resolved.'},
          {'label':'disputed',
           'description':'The customer explicitly challenges another actor\'s statement or ticket status asserting the issue is resolved, completed, or fixed.'},
          {'label':'unknown',
           'description':'There is insufficient evidence about current resolution status: a procedural question, a future promise, a documentation request or a polite closing is not proof of a working fix or ongoing failure.'}
         ],
         {'task_description':
          'Classify resolution evidence only, not sentiment or courtesy. A failed attempted fix is reported_unresolved unless someone explicitly declared success and the customer contradicts that declaration. Choose disputed only for contradiction of a prior completion/resolution claim. For future plans or questions without current issue evidence, choose unknown. Return exactly one label.',
          'output_mode':'single'}
       )
FROM RESOLUTION_V3_CASES c
WHERE c.CASE_ID LIKE 'R3-%'
 AND NOT EXISTS (
  SELECT 1 FROM RESOLUTION_V3_RESULTS r
  WHERE r.CASE_ID=c.CASE_ID AND r.VERSION='resolution-v3.0'
    AND r.RESOLUTION_RAW:labels[0] IS NOT NULL
 )
ORDER BY c.CASE_ID LIMIT 200;

CREATE OR REPLACE VIEW V_RESOLUTION_V3_COMPARISON AS
SELECT c.CASE_ID, c.PRODUCT, c.DOMAIN, c.COHORT, c.TRANSCRIPT,
       c.GOLD_RESOLUTION, c.GOLD_DISSATISFACTION,
       r.VERSION, r.RUN_AT, r.RESOLUTION_RAW,
       r.RESOLUTION_RAW:labels[0]::VARCHAR AS CORTEX_RESOLUTION,
       IFF(r.RESOLUTION_RAW:labels[0] IS NULL, NULL,
           IFF(r.RESOLUTION_RAW:labels[0]::VARCHAR=c.GOLD_RESOLUTION,1,0))
           AS EXACT_MATCH
FROM RESOLUTION_V3_CASES c
LEFT JOIN RESOLUTION_V3_RESULTS r
 ON r.CASE_ID=c.CASE_ID AND r.VERSION='resolution-v3.0'
WHERE c.CASE_ID LIKE 'R3-%'
QUALIFY ROW_NUMBER() OVER
 (PARTITION BY c.CASE_ID ORDER BY r.RUN_AT DESC NULLS LAST)=1;

-- Summary (denominator excludes missing predictions for agreement rate).
SELECT COUNT(*) AS TOTAL_CASES,
       COUNT(CORTEX_RESOLUTION) AS PREDICTIONS_RETURNED,
       COUNT_IF(EXACT_MATCH=1) AS CORRECT_PREDICTIONS,
       ROUND(100.0*COUNT(CORTEX_RESOLUTION)/NULLIF(COUNT(*),0),2) AS COVERAGE_PCT,
       ROUND(100.0*COUNT_IF(EXACT_MATCH=1)/NULLIF(COUNT(CORTEX_RESOLUTION),0),2) AS EXACT_AGREEMENT_PCT
FROM V_RESOLUTION_V3_COMPARISON;

-- Confusion matrix.
SELECT GOLD_RESOLUTION, COALESCE(CORTEX_RESOLUTION,'NO_PREDICTION') AS CORTEX_RESOLUTION,
       COUNT(*) AS CASE_COUNT
FROM V_RESOLUTION_V3_COMPARISON
GROUP BY GOLD_RESOLUTION, COALESCE(CORTEX_RESOLUTION,'NO_PREDICTION')
ORDER BY GOLD_RESOLUTION, CORTEX_RESOLUTION;

-- Error analysis: which patterns need work?
SELECT COHORT, COUNT(*) AS N,
       COUNT_IF(EXACT_MATCH=0) AS MISMATCHES,
       COUNT_IF(CORTEX_RESOLUTION IS NULL) AS MISSING_PREDICTIONS
FROM V_RESOLUTION_V3_COMPARISON
GROUP BY COHORT ORDER BY COHORT;

-- IMPORTANT: download the entire following result set as CSV before trial expiry.
SELECT * FROM V_RESOLUTION_V3_COMPARISON ORDER BY CASE_ID;
