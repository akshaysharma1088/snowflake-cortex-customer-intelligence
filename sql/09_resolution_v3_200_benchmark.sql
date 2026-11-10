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
('R3-001', 'I tested account access again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Account Portal', 'login'),
('R3-002', 'The issue with account access is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Account Portal', 'login'),
('R3-003', 'Thank you, account access works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Account Portal', 'login'),
('R3-004', 'I received the expected result from account access. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Account Portal', 'login'),
('R3-005', 'After another test, account access completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Account Portal', 'login'),
('R3-006', 'I tested refund again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Billing Hub', 'billing'),
('R3-007', 'The issue with refund is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Billing Hub', 'billing'),
('R3-008', 'Thank you, refund works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Billing Hub', 'billing'),
('R3-009', 'I received the expected result from refund. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Billing Hub', 'billing'),
('R3-010', 'After another test, refund completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Billing Hub', 'billing'),
('R3-011', 'I tested webhook again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Data Sync', 'integration'),
('R3-012', 'The issue with webhook is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Data Sync', 'integration'),
('R3-013', 'Thank you, webhook works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Data Sync', 'integration'),
('R3-014', 'I received the expected result from webhook. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Data Sync', 'integration'),
('R3-015', 'After another test, webhook completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Data Sync', 'integration'),
('R3-016', 'I tested dashboard again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Analytics Studio', 'performance'),
('R3-017', 'The issue with dashboard is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Analytics Studio', 'performance'),
('R3-018', 'Thank you, dashboard works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Analytics Studio', 'performance'),
('R3-019', 'I received the expected result from dashboard. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Analytics Studio', 'performance'),
('R3-020', 'After another test, dashboard completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Analytics Studio', 'performance'),
('R3-021', 'I tested app startup again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Mobile App', 'mobile'),
('R3-022', 'The issue with app startup is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Mobile App', 'mobile'),
('R3-023', 'Thank you, app startup works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Mobile App', 'mobile'),
('R3-024', 'I received the expected result from app startup. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Mobile App', 'mobile'),
('R3-025', 'After another test, app startup completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Mobile App', 'mobile'),
('R3-026', 'I tested report export again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Reporting Studio', 'export'),
('R3-027', 'The issue with report export is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Reporting Studio', 'export'),
('R3-028', 'Thank you, report export works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Reporting Studio', 'export'),
('R3-029', 'I received the expected result from report export. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Reporting Studio', 'export'),
('R3-030', 'After another test, report export completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Reporting Studio', 'export'),
('R3-031', 'I tested user access again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Identity Hub', 'permissions'),
('R3-032', 'The issue with user access is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Identity Hub', 'permissions'),
('R3-033', 'Thank you, user access works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Identity Hub', 'permissions'),
('R3-034', 'I received the expected result from user access. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Identity Hub', 'permissions'),
('R3-035', 'After another test, user access completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Identity Hub', 'permissions'),
('R3-036', 'I tested email notifications again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Notification Center', 'notifications'),
('R3-037', 'The issue with email notifications is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Notification Center', 'notifications'),
('R3-038', 'Thank you, email notifications works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Notification Center', 'notifications'),
('R3-039', 'I received the expected result from email notifications. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Notification Center', 'notifications'),
('R3-040', 'After another test, email notifications completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Notification Center', 'notifications'),
('R3-041', 'I tested API requests again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'API Gateway', 'api'),
('R3-042', 'The issue with API requests is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'API Gateway', 'api'),
('R3-043', 'Thank you, API requests works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'API Gateway', 'api'),
('R3-044', 'I received the expected result from API requests. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'API Gateway', 'api'),
('R3-045', 'After another test, API requests completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'API Gateway', 'api'),
('R3-046', 'I tested billing plan again and can confirm it now works.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Subscription Portal', 'subscription'),
('R3-047', 'The issue with billing plan is resolved; I verified it myself.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Subscription Portal', 'subscription'),
('R3-048', 'Thank you, billing plan works correctly after the change.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Subscription Portal', 'subscription'),
('R3-049', 'I received the expected result from billing plan. The issue is fixed.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Subscription Portal', 'subscription'),
('R3-050', 'After another test, billing plan completes successfully and there is no problem.', 'confirmed_resolved', 'no_evidence', 'confirmed_resolved', 'Subscription Portal', 'subscription'),
('R3-051', 'Thanks for the update, but account access still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Account Portal', 'login'),
('R3-052', 'The problem with account access continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Account Portal', 'login'),
('R3-053', 'Please help: account access keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Account Portal', 'login'),
('R3-054', 'I tried again, and account access is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Account Portal', 'login'),
('R3-055', 'I appreciate the work so far, though account access has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Account Portal', 'login'),
('R3-056', 'Thanks for the update, but refund still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Billing Hub', 'billing'),
('R3-057', 'The problem with refund continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Billing Hub', 'billing'),
('R3-058', 'Please help: refund keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Billing Hub', 'billing'),
('R3-059', 'I tried again, and refund is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Billing Hub', 'billing'),
('R3-060', 'I appreciate the work so far, though refund has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Billing Hub', 'billing'),
('R3-061', 'Thanks for the update, but webhook still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Data Sync', 'integration'),
('R3-062', 'The problem with webhook continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Data Sync', 'integration'),
('R3-063', 'Please help: webhook keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Data Sync', 'integration'),
('R3-064', 'I tried again, and webhook is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Data Sync', 'integration'),
('R3-065', 'I appreciate the work so far, though webhook has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Data Sync', 'integration'),
('R3-066', 'Thanks for the update, but dashboard still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Analytics Studio', 'performance'),
('R3-067', 'The problem with dashboard continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Analytics Studio', 'performance'),
('R3-068', 'Please help: dashboard keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Analytics Studio', 'performance'),
('R3-069', 'I tried again, and dashboard is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Analytics Studio', 'performance'),
('R3-070', 'I appreciate the work so far, though dashboard has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Analytics Studio', 'performance'),
('R3-071', 'Thanks for the update, but app startup still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Mobile App', 'mobile'),
('R3-072', 'The problem with app startup continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Mobile App', 'mobile'),
('R3-073', 'Please help: app startup keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Mobile App', 'mobile'),
('R3-074', 'I tried again, and app startup is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Mobile App', 'mobile'),
('R3-075', 'I appreciate the work so far, though app startup has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Mobile App', 'mobile'),
('R3-076', 'Thanks for the update, but report export still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Reporting Studio', 'export'),
('R3-077', 'The problem with report export continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Reporting Studio', 'export'),
('R3-078', 'Please help: report export keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Reporting Studio', 'export'),
('R3-079', 'I tried again, and report export is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Reporting Studio', 'export'),
('R3-080', 'I appreciate the work so far, though report export has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Reporting Studio', 'export'),
('R3-081', 'Thanks for the update, but user access still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Identity Hub', 'permissions'),
('R3-082', 'The problem with user access continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Identity Hub', 'permissions'),
('R3-083', 'Please help: user access keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Identity Hub', 'permissions'),
('R3-084', 'I tried again, and user access is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Identity Hub', 'permissions'),
('R3-085', 'I appreciate the work so far, though user access has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Identity Hub', 'permissions'),
('R3-086', 'Thanks for the update, but email notifications still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Notification Center', 'notifications'),
('R3-087', 'The problem with email notifications continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Notification Center', 'notifications'),
('R3-088', 'Please help: email notifications keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Notification Center', 'notifications'),
('R3-089', 'I tried again, and email notifications is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Notification Center', 'notifications'),
('R3-090', 'I appreciate the work so far, though email notifications has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Notification Center', 'notifications'),
('R3-091', 'Thanks for the update, but API requests still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'API Gateway', 'api'),
('R3-092', 'The problem with API requests continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'API Gateway', 'api'),
('R3-093', 'Please help: API requests keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'API Gateway', 'api'),
('R3-094', 'I tried again, and API requests is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'API Gateway', 'api'),
('R3-095', 'I appreciate the work so far, though API requests has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'API Gateway', 'api'),
('R3-096', 'Thanks for the update, but billing plan still does not work.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Subscription Portal', 'subscription'),
('R3-097', 'The problem with billing plan continues after troubleshooting.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Subscription Portal', 'subscription'),
('R3-098', 'Please help: billing plan keeps failing and the issue remains open.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Subscription Portal', 'subscription'),
('R3-099', 'I tried again, and billing plan is still broken.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Subscription Portal', 'subscription'),
('R3-100', 'I appreciate the work so far, though billing plan has not been fixed.', 'reported_unresolved', 'yes', 'reported_unresolved', 'Subscription Portal', 'subscription'),
('R3-101', 'Support marked account access as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Account Portal', 'login'),
('R3-102', 'The case says resolved for account access; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Account Portal', 'login'),
('R3-103', 'You confirmed account access was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Account Portal', 'login'),
('R3-104', 'The ticket was closed as solved, yet account access is still broken.', 'disputed', 'yes', 'disputed', 'Account Portal', 'login'),
('R3-105', 'The agent said account access is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Account Portal', 'login'),
('R3-106', 'Support marked refund as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Billing Hub', 'billing'),
('R3-107', 'The case says resolved for refund; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Billing Hub', 'billing'),
('R3-108', 'You confirmed refund was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Billing Hub', 'billing'),
('R3-109', 'The ticket was closed as solved, yet refund is still broken.', 'disputed', 'yes', 'disputed', 'Billing Hub', 'billing'),
('R3-110', 'The agent said refund is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Billing Hub', 'billing'),
('R3-111', 'Support marked webhook as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Data Sync', 'integration'),
('R3-112', 'The case says resolved for webhook; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Data Sync', 'integration'),
('R3-113', 'You confirmed webhook was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Data Sync', 'integration'),
('R3-114', 'The ticket was closed as solved, yet webhook is still broken.', 'disputed', 'yes', 'disputed', 'Data Sync', 'integration'),
('R3-115', 'The agent said webhook is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Data Sync', 'integration'),
('R3-116', 'Support marked dashboard as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Analytics Studio', 'performance'),
('R3-117', 'The case says resolved for dashboard; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Analytics Studio', 'performance'),
('R3-118', 'You confirmed dashboard was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Analytics Studio', 'performance'),
('R3-119', 'The ticket was closed as solved, yet dashboard is still broken.', 'disputed', 'yes', 'disputed', 'Analytics Studio', 'performance'),
('R3-120', 'The agent said dashboard is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Analytics Studio', 'performance'),
('R3-121', 'Support marked app startup as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Mobile App', 'mobile'),
('R3-122', 'The case says resolved for app startup; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Mobile App', 'mobile'),
('R3-123', 'You confirmed app startup was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Mobile App', 'mobile'),
('R3-124', 'The ticket was closed as solved, yet app startup is still broken.', 'disputed', 'yes', 'disputed', 'Mobile App', 'mobile'),
('R3-125', 'The agent said app startup is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Mobile App', 'mobile'),
('R3-126', 'Support marked report export as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Reporting Studio', 'export'),
('R3-127', 'The case says resolved for report export; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Reporting Studio', 'export'),
('R3-128', 'You confirmed report export was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Reporting Studio', 'export'),
('R3-129', 'The ticket was closed as solved, yet report export is still broken.', 'disputed', 'yes', 'disputed', 'Reporting Studio', 'export'),
('R3-130', 'The agent said report export is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Reporting Studio', 'export'),
('R3-131', 'Support marked user access as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Identity Hub', 'permissions'),
('R3-132', 'The case says resolved for user access; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Identity Hub', 'permissions'),
('R3-133', 'You confirmed user access was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Identity Hub', 'permissions'),
('R3-134', 'The ticket was closed as solved, yet user access is still broken.', 'disputed', 'yes', 'disputed', 'Identity Hub', 'permissions'),
('R3-135', 'The agent said user access is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Identity Hub', 'permissions'),
('R3-136', 'Support marked email notifications as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Notification Center', 'notifications'),
('R3-137', 'The case says resolved for email notifications; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Notification Center', 'notifications'),
('R3-138', 'You confirmed email notifications was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Notification Center', 'notifications'),
('R3-139', 'The ticket was closed as solved, yet email notifications is still broken.', 'disputed', 'yes', 'disputed', 'Notification Center', 'notifications'),
('R3-140', 'The agent said email notifications is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Notification Center', 'notifications'),
('R3-141', 'Support marked API requests as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'API Gateway', 'api'),
('R3-142', 'The case says resolved for API requests; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'API Gateway', 'api'),
('R3-143', 'You confirmed API requests was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'API Gateway', 'api'),
('R3-144', 'The ticket was closed as solved, yet API requests is still broken.', 'disputed', 'yes', 'disputed', 'API Gateway', 'api'),
('R3-145', 'The agent said API requests is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'API Gateway', 'api'),
('R3-146', 'Support marked billing plan as fixed, but I tested it and it still fails.', 'disputed', 'yes', 'disputed', 'Subscription Portal', 'subscription'),
('R3-147', 'The case says resolved for billing plan; that is incorrect because the problem remains.', 'disputed', 'yes', 'disputed', 'Subscription Portal', 'subscription'),
('R3-148', 'You confirmed billing plan was repaired, but I still get the same failure.', 'disputed', 'yes', 'disputed', 'Subscription Portal', 'subscription'),
('R3-149', 'The ticket was closed as solved, yet billing plan is still broken.', 'disputed', 'yes', 'disputed', 'Subscription Portal', 'subscription'),
('R3-150', 'The agent said billing plan is working, but my latest test proves otherwise.', 'disputed', 'yes', 'disputed', 'Subscription Portal', 'subscription'),
('R3-151', 'Could you send documentation for account access?', 'unknown', 'no_evidence', 'unknown', 'Account Portal', 'login'),
('R3-152', 'Please share the steps needed to configure account access.', 'unknown', 'no_evidence', 'unknown', 'Account Portal', 'login'),
('R3-153', 'The agent said they will investigate account access tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Account Portal', 'login'),
('R3-154', 'Thanks for the information about account access; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Account Portal', 'login'),
('R3-155', 'Is there a support guide explaining account access?', 'unknown', 'no_evidence', 'unknown', 'Account Portal', 'login'),
('R3-156', 'Could you send documentation for refund?', 'unknown', 'no_evidence', 'unknown', 'Billing Hub', 'billing'),
('R3-157', 'Please share the steps needed to configure refund.', 'unknown', 'no_evidence', 'unknown', 'Billing Hub', 'billing'),
('R3-158', 'The agent said they will investigate refund tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Billing Hub', 'billing'),
('R3-159', 'Thanks for the information about refund; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Billing Hub', 'billing'),
('R3-160', 'Is there a support guide explaining refund?', 'unknown', 'no_evidence', 'unknown', 'Billing Hub', 'billing'),
('R3-161', 'Could you send documentation for webhook?', 'unknown', 'no_evidence', 'unknown', 'Data Sync', 'integration'),
('R3-162', 'Please share the steps needed to configure webhook.', 'unknown', 'no_evidence', 'unknown', 'Data Sync', 'integration'),
('R3-163', 'The agent said they will investigate webhook tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Data Sync', 'integration'),
('R3-164', 'Thanks for the information about webhook; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Data Sync', 'integration'),
('R3-165', 'Is there a support guide explaining webhook?', 'unknown', 'no_evidence', 'unknown', 'Data Sync', 'integration'),
('R3-166', 'Could you send documentation for dashboard?', 'unknown', 'no_evidence', 'unknown', 'Analytics Studio', 'performance'),
('R3-167', 'Please share the steps needed to configure dashboard.', 'unknown', 'no_evidence', 'unknown', 'Analytics Studio', 'performance'),
('R3-168', 'The agent said they will investigate dashboard tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Analytics Studio', 'performance'),
('R3-169', 'Thanks for the information about dashboard; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Analytics Studio', 'performance'),
('R3-170', 'Is there a support guide explaining dashboard?', 'unknown', 'no_evidence', 'unknown', 'Analytics Studio', 'performance'),
('R3-171', 'Could you send documentation for app startup?', 'unknown', 'no_evidence', 'unknown', 'Mobile App', 'mobile'),
('R3-172', 'Please share the steps needed to configure app startup.', 'unknown', 'no_evidence', 'unknown', 'Mobile App', 'mobile'),
('R3-173', 'The agent said they will investigate app startup tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Mobile App', 'mobile'),
('R3-174', 'Thanks for the information about app startup; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Mobile App', 'mobile'),
('R3-175', 'Is there a support guide explaining app startup?', 'unknown', 'no_evidence', 'unknown', 'Mobile App', 'mobile'),
('R3-176', 'Could you send documentation for report export?', 'unknown', 'no_evidence', 'unknown', 'Reporting Studio', 'export'),
('R3-177', 'Please share the steps needed to configure report export.', 'unknown', 'no_evidence', 'unknown', 'Reporting Studio', 'export'),
('R3-178', 'The agent said they will investigate report export tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Reporting Studio', 'export'),
('R3-179', 'Thanks for the information about report export; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Reporting Studio', 'export'),
('R3-180', 'Is there a support guide explaining report export?', 'unknown', 'no_evidence', 'unknown', 'Reporting Studio', 'export'),
('R3-181', 'Could you send documentation for user access?', 'unknown', 'no_evidence', 'unknown', 'Identity Hub', 'permissions'),
('R3-182', 'Please share the steps needed to configure user access.', 'unknown', 'no_evidence', 'unknown', 'Identity Hub', 'permissions'),
('R3-183', 'The agent said they will investigate user access tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Identity Hub', 'permissions'),
('R3-184', 'Thanks for the information about user access; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Identity Hub', 'permissions'),
('R3-185', 'Is there a support guide explaining user access?', 'unknown', 'no_evidence', 'unknown', 'Identity Hub', 'permissions'),
('R3-186', 'Could you send documentation for email notifications?', 'unknown', 'no_evidence', 'unknown', 'Notification Center', 'notifications'),
('R3-187', 'Please share the steps needed to configure email notifications.', 'unknown', 'no_evidence', 'unknown', 'Notification Center', 'notifications'),
('R3-188', 'The agent said they will investigate email notifications tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Notification Center', 'notifications'),
('R3-189', 'Thanks for the information about email notifications; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Notification Center', 'notifications'),
('R3-190', 'Is there a support guide explaining email notifications?', 'unknown', 'no_evidence', 'unknown', 'Notification Center', 'notifications'),
('R3-191', 'Could you send documentation for API requests?', 'unknown', 'no_evidence', 'unknown', 'API Gateway', 'api'),
('R3-192', 'Please share the steps needed to configure API requests.', 'unknown', 'no_evidence', 'unknown', 'API Gateway', 'api'),
('R3-193', 'The agent said they will investigate API requests tomorrow.', 'unknown', 'no_evidence', 'unknown', 'API Gateway', 'api'),
('R3-194', 'Thanks for the information about API requests; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'API Gateway', 'api'),
('R3-195', 'Is there a support guide explaining API requests?', 'unknown', 'no_evidence', 'unknown', 'API Gateway', 'api'),
('R3-196', 'Could you send documentation for billing plan?', 'unknown', 'no_evidence', 'unknown', 'Subscription Portal', 'subscription'),
('R3-197', 'Please share the steps needed to configure billing plan.', 'unknown', 'no_evidence', 'unknown', 'Subscription Portal', 'subscription'),
('R3-198', 'The agent said they will investigate billing plan tomorrow.', 'unknown', 'no_evidence', 'unknown', 'Subscription Portal', 'subscription'),
('R3-199', 'Thanks for the information about billing plan; I will review it later.', 'unknown', 'no_evidence', 'unknown', 'Subscription Portal', 'subscription'),
('R3-200', 'Is there a support guide explaining billing plan?', 'unknown', 'no_evidence', 'unknown', 'Subscription Portal', 'subscription')
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
