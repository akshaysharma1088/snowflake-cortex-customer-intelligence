-- Run in Snowsight after setup; the AI calls below can incur minimal usage charges.
-- These probes test the SAME functions and output shapes used in the project.
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;
SELECT CURRENT_ACCOUNT() AS ACCOUNT_ID, CURRENT_REGION() AS REGION,
       CURRENT_ROLE() AS ACTIVE_ROLE, CURRENT_WAREHOUSE() AS ACTIVE_WH;
SELECT COUNT(*) AS DEMO_RECORDS FROM CONVERSATIONS;
-- Test only after checking role access and Cortex inference availability.
SELECT AI_SENTIMENT(
  'Thanks for checking, but the issue still has not been resolved.'
) AS SENTIMENT_SHAPE;
SELECT AI_EXTRACT(
  text => 'Account Portal login failed with AUTH-403.',
  responseFormat => {'product':'What software product is named?',
                     'error_code':'What error code appears?'}
) AS EXTRACTION_SHAPE;
SELECT AI_CLASSIFY(
  'The invoice includes a duplicate charge.',
  ['login_access','billing','performance','integration','other']
) AS CLASSIFICATION_SHAPE;