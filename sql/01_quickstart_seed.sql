-- No local files or PUT required: use Snowsight worksheet after sql/00_setup.sql.
-- Synthetic examples ONLY. Safe to rerun (MERGE keys by CONVERSATION_ID).
USE DATABASE CORTEX_CI_DEMO;
USE SCHEMA APP;
MERGE INTO CONVERSATIONS t
USING (
SELECT column1::VARCHAR AS CONVERSATION_ID,
       TO_TIMESTAMP_NTZ(column2) AS CREATED_AT,
       column3::VARCHAR AS CHANNEL, column4::VARCHAR AS PRODUCT,
       column5::VARCHAR AS TRANSCRIPT, column6::VARCHAR AS GOLD_SENTIMENT,
       column7::VARCHAR AS GOLD_ISSUE, column8::BOOLEAN AS GOLD_UNRESOLVED
FROM VALUES
('SMOKE-001','2026-11-01 09:00:00','chat','Account Portal',
 'Thanks for looking into this, but the fix still does not work. I cannot log in.','mixed','login_access',TRUE),
('SMOKE-002','2026-11-01 10:00:00','case','Billing Hub',
 'The duplicate charge is still on my invoice. Please fix it.','negative','billing',TRUE),
('SMOKE-003','2026-11-01 11:00:00','chat','Analytics Studio',
 'Thanks! The dashboard now works and the issue is resolved.','positive','performance',FALSE),
('SMOKE-004','2026-11-01 12:00:00','email','Data Sync',
 'The webhook is failing with ERR-502. No fix yet.','negative','integration',TRUE),
('SMOKE-005','2026-11-01 13:00:00','chat','Mobile App',
 'Please send the updated receipt.','neutral','other',FALSE),
('SMOKE-006','2026-11-01 14:00:00','case','Account Portal',
 'Thanks for the update. I appreciate your efforts, but my account is still locked.','mixed','login_access',TRUE),
('SMOKE-007','2026-11-01 15:00:00','email','Billing Hub',
 'Everything is resolved. Thank you for the quick refund.','positive','billing',FALSE),
('SMOKE-008','2026-11-01 16:00:00','chat','Data Sync',
 'Can you share the documentation for API notifications?','neutral','integration',FALSE)
) s
ON t.CONVERSATION_ID=s.CONVERSATION_ID
WHEN NOT MATCHED THEN INSERT (
CONVERSATION_ID, CREATED_AT, CHANNEL, PRODUCT, TRANSCRIPT, GOLD_SENTIMENT,
GOLD_ISSUE, GOLD_UNRESOLVED
) VALUES (
s.CONVERSATION_ID, s.CREATED_AT, s.CHANNEL, s.PRODUCT, s.TRANSCRIPT,
s.GOLD_SENTIMENT, s.GOLD_ISSUE, s.GOLD_UNRESOLVED
);
SELECT COUNT(*) AS SMOKE_RECORDS FROM CONVERSATIONS
WHERE CONVERSATION_ID LIKE 'SMOKE-%';