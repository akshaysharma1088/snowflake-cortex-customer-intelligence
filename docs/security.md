# Security and privacy

**Synthetic support data only.** Do not insert Salesforce or real customer transcripts into this demo.

Before any real deployment:
- Obtain authorization and review contractual, privacy and residency obligations.
- Detect and redact PII, account IDs, secrets, credentials and sensitive data before inference.
- Assign dedicated setup, enrichment and read-only dashboard roles, with minimum necessary grants.
- Validate Snowflake Cortex privileges, model access and AI data processing restrictions.
- Configure billing monitoring, warehouse auto-suspend, inference limits and retention rules.
- Treat model outputs as untrusted; require human review for escalation or consequential decisions.
- Use enterprise authentication and secrets management; never commit credentials.
- Test record deletion, auditability, access controls and redaction robustness.
