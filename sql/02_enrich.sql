-- Manually triggered, capped Cortex inference; calls incur charges.
-- Validate AI function availability, role privileges, and output shapes in your region.
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;
SET run_id = 'smoke-test-001'; -- constant assignment; replace with a unique literal for each manual run
SET enrich_version = 'v1';
INSERT INTO ENRICHED_CONVERSATIONS
 (CONVERSATION_ID, ENRICHMENT_VERSION, RUN_ID, ENRICHED_AT,
  SENTIMENT_RAW, EXTRACTION_RAW, ISSUE_CLASSIFICATION_RAW, STATUS, ERROR_MESSAGE)
WITH batch AS (
 SELECT c.CONVERSATION_ID, c.TRANSCRIPT
 FROM CONVERSATIONS c
 WHERE NOT EXISTS (
  SELECT 1 FROM ENRICHED_CONVERSATIONS e
  WHERE e.CONVERSATION_ID=c.CONVERSATION_ID
    AND e.ENRICHMENT_VERSION=$enrich_version AND e.STATUS='SUCCESS'
 )
 ORDER BY c.CONVERSATION_ID LIMIT 25
), calls AS (
 SELECT CONVERSATION_ID,
  AI_SENTIMENT(TRANSCRIPT) AS SENTIMENT_RAW,
  AI_EXTRACT(
   text => TRANSCRIPT,
   responseFormat => {
    'product': 'Which software product is mentioned? Return a short value or unknown.',
    'feature': 'Which feature is mentioned? Return a short value or unknown.',
    'error_code': 'What exact error code appears, or unknown?',
    'resolution': 'Was the issue explicitly confirmed resolved? Respond yes, no, or unknown.'
   }
  ) AS EXTRACTION_RAW,
  AI_CLASSIFY(TRANSCRIPT,
    ['login_access','billing','performance','integration','other']
  ) AS ISSUE_CLASSIFICATION_RAW
 FROM batch
)
SELECT CONVERSATION_ID, $enrich_version, $run_id, CURRENT_TIMESTAMP(),
 SENTIMENT_RAW, EXTRACTION_RAW, ISSUE_CLASSIFICATION_RAW,
 IFF(SENTIMENT_RAW IS NOT NULL AND EXTRACTION_RAW IS NOT NULL
     AND ISSUE_CLASSIFICATION_RAW IS NOT NULL,'SUCCESS','INCOMPLETE'),
 NULL
FROM calls;
SELECT CONVERSATION_ID, SENTIMENT_RAW, EXTRACTION_RAW, ISSUE_CLASSIFICATION_RAW
FROM ENRICHED_CONVERSATIONS ORDER BY ENRICHED_AT DESC LIMIT 5;