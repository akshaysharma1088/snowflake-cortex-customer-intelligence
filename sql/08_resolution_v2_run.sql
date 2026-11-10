-- Versioned resolution-only inference. Calls AI_CLASSIFY on 24 synthetic vignettes.
-- Run only after sql/07_resolution_v2_seed.sql. Inference incurs charges.
USE WAREHOUSE CORTEX_CI_WH;
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;

-- Keep run history: do NOT replace previous results.
-- A version is used as a successful-run guard; use v3 when modifying categories.
INSERT INTO RESOLUTION_V2_RESULTS (CASE_ID,VERSION,RUN_AT,RESOLUTION_RAW)
SELECT c.CASE_ID, 'resolution-v2.0', CURRENT_TIMESTAMP(),
       AI_CLASSIFY(
         c.TRANSCRIPT,
         [
           {'label':'confirmed_resolved',
            'description':'Customer explicitly confirms the problem is fixed or desired outcome was received.'},
           {'label':'reported_unresolved',
            'description':'Customer clearly says their issue still exists or promised outcome has not occurred.'},
           {'label':'disputed',
            'description':'Customer contradicts an assertion that their issue was fixed or the ticket was resolved.'},
           {'label':'unknown',
            'description':'No reliable customer confirmation of resolution or explicit continuing issue, including future agent promises.'}
         ],
         {'task_description':
           'Determine resolution evidence in this support utterance, not emotional sentiment. Never infer resolution from gratitude or an agent promise. Choose exactly one category.'}
       )
FROM RESOLUTION_V2_CASES c
WHERE NOT EXISTS (
 SELECT 1 FROM RESOLUTION_V2_RESULTS r
 WHERE r.CASE_ID=c.CASE_ID AND r.VERSION='resolution-v2.0'
)
ORDER BY c.CASE_ID
LIMIT 24;

CREATE OR REPLACE VIEW V_RESOLUTION_V2_COMPARISON AS
SELECT c.CASE_ID, c.COHORT, c.TRANSCRIPT, c.GOLD_RESOLUTION,
       c.GOLD_DISSATISFACTION, r.VERSION,
       r.RESOLUTION_RAW:labels[0]::VARCHAR AS CORTEX_RESOLUTION,
       IFF(r.RESOLUTION_RAW:labels[0]::VARCHAR=c.GOLD_RESOLUTION,1,0) AS EXACT_MATCH,
       r.RESOLUTION_RAW, r.RUN_AT
FROM RESOLUTION_V2_CASES c
LEFT JOIN RESOLUTION_V2_RESULTS r
  ON c.CASE_ID=r.CASE_ID AND r.VERSION='resolution-v2.0'
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY c.CASE_ID ORDER BY r.RUN_AT DESC NULLS LAST
)=1;

SELECT CASE_ID, GOLD_RESOLUTION, CORTEX_RESOLUTION, EXACT_MATCH
FROM V_RESOLUTION_V2_COMPARISON
ORDER BY CASE_ID;

SELECT GOLD_RESOLUTION, COUNT(*) AS N,
       COUNT_IF(CORTEX_RESOLUTION IS NOT NULL) AS PREDICTED,
       COUNT_IF(EXACT_MATCH=1) AS MATCHED
FROM V_RESOLUTION_V2_COMPARISON
GROUP BY GOLD_RESOLUTION ORDER BY GOLD_RESOLUTION;

-- Export this complete result grid as CSV from Snowsight (not just aggregates).
SELECT * FROM V_RESOLUTION_V2_COMPARISON ORDER BY CASE_ID;
