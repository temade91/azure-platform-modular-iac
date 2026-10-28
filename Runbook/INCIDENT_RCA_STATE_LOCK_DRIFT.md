# Incident Post-Mortem & Runbook: Remote State Lock Contention & Configuration Drift

## 1. Executive Summary
- **Incident Type:** Infrastructure Pipeline Outage / State Blob Lock Deadlock & Configuration Drift
- **Severity:** P2 (CI/CD Deployment Blocked / Production Drift Detected)
- **Impacted Systems:** Azure Blob Remote State (tfstate/dev.terraform.tfstate), CI/CD Deployment Runners

---

## 2. Problem Statement
1. **State Lock Deadlock:** An aborted CI/CD runner execution left an orphaned, infinite lease on the Azure Blob remote state storage account. Subsequent pipeline runs failed with Error: Error acquiring the state lock.
2. **Out-of-Band Drift:** Out-of-band portal/CLI modifications introduced unexpected metadata tags to live resource groups without corresponding Pull Requests or Terraform declarations.

---

## 3. Root Cause Analysis (RCA)
- **Deadlock Cause:** The AzureRM backend enforces distributed locking via Azure Blob leases. The interrupted process exited without triggering its cleanup routine or Terraform backend release API call, leaving an active exclusive lease (leaseId).
- **Drift Cause:** Insufficient Azure RBAC guardrails allowed direct modifications to live Azure resource attributes outside of the declared GitOps pipeline.

---

## 4. Remediation Procedure Executed

### Step A: Emergency Lock Remediation
1. Audited CI/CD runners to verify zero concurrent active jobs were writing to the environment.
2. Extracted unique Lock ID from pipeline execution telemetry.
3. Cleared lock via CLI:
   terraform force-unlock <LOCK_ID>
4. Azure Fallback Executed: Where CLI lease breaking encounters auth timeouts, cleared directly via Azure CLI:
   az storage blob lease break \
     --account-name "<STORAGE_ACCOUNT>" \
     --container-name "tfstate" \
     --blob-name "dev.terraform.tfstate" \
     --auth-mode login

### Step B: Safe Drift Isolation & Reconciliation
1. Ran safe, non-destructive drift inspection:
   terraform plan -refresh-only -var-file="environments/dev/dev.tfvars"
2. Reconciled unauthorized drift by enforcing code state via declarative terraform apply or backporting approved hotfixes into .tf configuration files.

---

## 5. Preventative Actions & Governance
- [x] Configure CI/CD runner timeout boundaries (kill orphaned jobs after 20 minutes).
- [x] Update Azure RBAC subscription roles to enforce Reader for individual developers and restrict Contributor access exclusively to the automation Service Principal.
- [x] Enforce automated daily terraform plan -refresh-only scheduled workflows with alerts on unapproved drift.