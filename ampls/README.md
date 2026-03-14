# Azure Monitor Private Link Scope (AMPLS) – Terraform

This module deploys a **production-grade Azure Monitor Private Link Scope** that routes all Azure Monitor ingestion and query traffic exclusively over private IP space inside a Virtual Network. No public endpoint exposure is required or permitted once this configuration is applied.

---

## Architecture

```
Workload (VM / Container / Function)
        │
        ▼
Private Endpoint (azuremonitor sub-resource)
        │
        ▼
Azure Monitor Private Link Scope (AMPLS)
   ├── Log Analytics Workspace   (public access DISABLED)
   └── Application Insights      (public access DISABLED)
```

Traffic never leaves the VNet. DNS resolution is handled by five Azure Private DNS Zones that are linked to the VNet and auto-populated by the private endpoint DNS zone group.

---

## Resources Deployed

| Resource | Description |
|---|---|
| `azurerm_resource_group` | Container for all AMPLS resources |
| `azurerm_virtual_network` | VNet that hosts the private endpoint |
| `azurerm_subnet` | Dedicated subnet for private endpoints |
| `azurerm_log_analytics_workspace` | LA workspace – public access disabled |
| `azurerm_application_insights` | App Insights (workspace-based) – public access disabled |
| `azurerm_monitor_private_link_scope` | AMPLS – PrivateOnly ingestion & query |
| `azurerm_monitor_private_link_scoped_service` | Links LA workspace and App Insights to AMPLS |
| `azurerm_private_endpoint` | Single private endpoint for AMPLS |
| `azurerm_private_dns_zone` (×5) | DNS zones required by Azure Monitor Private Link |
| `azurerm_private_dns_zone_virtual_network_link` (×5) | Link each DNS zone to the VNet |
| `azurerm_resource_group_policy_assignment` (×2) | Azure Policy – deny public access on LA & App Insights |

### Private DNS Zones

| Zone | Purpose |
|---|---|
| `privatelink.monitor.azure.com` | Azure Monitor REST APIs |
| `privatelink.oms.opinsights.azure.com` | OMS agent ingestion |
| `privatelink.ods.opinsights.azure.com` | ODS agent ingestion |
| `privatelink.agentsvc.azure-automation.net` | Agent heartbeat / config |
| `privatelink.blob.core.windows.net` | Agent storage artefacts |

---

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI (`az`) or a Service Principal with the following roles on the target subscription:
  - `Contributor` (to create resources)
  - `Resource Policy Contributor` (to assign Azure Policies)
- An Azure subscription

---

## Usage

### 1. Authenticate

```bash
# Option A – Azure CLI (interactive)
az login

# Option B – Service Principal (CI/CD)
export ARM_CLIENT_ID="<sp-app-id>"
export ARM_CLIENT_SECRET="<sp-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

### 2. Initialise

```bash
cd ampls
terraform init
```

### 3. Validate

```bash
terraform validate
```

### 4. Plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

### 6. Destroy

```bash
terraform destroy
```

---

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `location` | `string` | `"eastus"` | Azure region |
| `resource_group_name` | `string` | `"rg-ampls-prod"` | Resource group name |
| `environment` | `string` | `"prod"` | Environment tag |
| `vnet_name` | `string` | `"vnet-ampls-prod"` | VNet name |
| `vnet_address_space` | `list(string)` | `["10.0.0.0/16"]` | VNet address space |
| `subnet_name` | `string` | `"snet-privateendpoints"` | Subnet name |
| `subnet_address_prefixes` | `list(string)` | `["10.0.1.0/24"]` | Subnet address prefix |
| `log_analytics_workspace_name` | `string` | `"law-ampls-prod"` | LA workspace name |
| `log_analytics_sku` | `string` | `"PerGB2018"` | LA SKU |
| `log_analytics_retention_days` | `number` | `90` | Retention in days |
| `app_insights_name` | `string` | `"appi-ampls-prod"` | App Insights name |
| `app_insights_application_type` | `string` | `"web"` | App Insights type |
| `ampls_name` | `string` | `"ampls-prod"` | AMPLS name |
| `private_endpoint_name` | `string` | `"pe-ampls-prod"` | Private endpoint name |
| `tags` | `map(string)` | See variables.tf | Resource tags |

---

## Outputs

| Name | Description |
|---|---|
| `resource_group_name` | Resource group name |
| `resource_group_id` | Resource group resource ID |
| `virtual_network_id` | VNet resource ID |
| `subnet_id` | Private-endpoint subnet resource ID |
| `log_analytics_workspace_id` | LA workspace resource ID |
| `log_analytics_workspace_name` | LA workspace name |
| `application_insights_id` | App Insights resource ID |
| `application_insights_instrumentation_key` | Instrumentation key (sensitive) |
| `application_insights_connection_string` | Connection string (sensitive) |
| `ampls_id` | AMPLS resource ID |
| `ampls_name` | AMPLS name |
| `private_endpoint_id` | Private endpoint resource ID |
| `private_endpoint_ip_address` | Private IP of the endpoint NIC |
| `private_dns_zone_ids` | Map of DNS zone names → resource IDs |

---

## CI/CD

A GitHub Actions workflow (`.github/workflows/terraform-ampls.yml`) runs automatically on every push or pull request that modifies files under `ampls/`. The pipeline executes:

1. **`terraform fmt -check`** – enforces canonical formatting
2. **`terraform init`** – installs the AzureRM provider
3. **`terraform validate`** – checks configuration syntax and semantics
4. **`terraform plan`** – produces an execution plan (posted as a PR comment on pull requests; only runs when Azure credentials are configured)

---

## Required Setup to Enable the CI Pipeline

> Complete the steps below **before** merging. Steps 1–3 are needed for `fmt`, `init`, and `validate` to run. Step 4 is additionally needed for `terraform plan`.

### Step 1 – Approve the Copilot bot's workflow runs (one-time)

GitHub blocks workflow runs from first-time contributors (including bots) until a repository owner approves them.

1. Go to your repository on GitHub.
2. Click **Actions** in the top navigation bar.
3. Find the workflow run that shows **"Waiting for approval"** or **"Action required"**.
4. Click **"Approve and run"**.

After this one-time approval the Copilot bot's future workflow runs will execute automatically.

**Alternative (permanent):** Loosen the approval requirement for all future outside contributors:
1. Go to **Settings → Actions → General**.
2. Under *"Fork pull request workflows from outside collaborators"*, select **"Require approval for first time outside collaborators only"**.
3. Click **Save**.

### Step 2 – Verify Actions are enabled

1. Go to **Settings → Actions → General**.
2. Under *"Actions permissions"*, make sure **"Allow all actions and reusable workflows"** (or a suitable policy) is selected.
3. Click **Save** if you made a change.

### Step 3 – Confirm `fmt`, `init`, `validate` pass (no Azure credentials needed)

Once the bot is approved (Step 1), push any small change to the `ampls/` directory. The `Terraform fmt`, `Terraform init`, and `Terraform validate` steps will run **without any Azure credentials** — these only need access to the public Terraform Registry.

### Step 4 – Create an Azure Service Principal and add GitHub Secrets (enables `terraform plan`)

The `terraform plan` step requires real Azure credentials. These are passed in as repository secrets.

#### 4a – Create a Service Principal

```bash
# Log in
az login

# Create the service principal with Contributor + Resource Policy Contributor
# on the target subscription
az ad sp create-for-rbac \
  --name "sp-github-terraform-ampls" \
  --role "Contributor" \
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>" \
  --sdk-auth
```

> If Azure Policy assignment is required (used in `policy.tf`), also assign **Resource Policy Contributor**:
> ```bash
> az role assignment create \
>   --assignee <appId-from-above> \
>   --role "Resource Policy Contributor" \
>   --scope "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
> ```

The command outputs JSON like:
```json
{
  "clientId":       "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret":   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId":       "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

#### 4b – Add the four secrets to GitHub

1. Go to **Settings → Secrets and variables → Actions → New repository secret**.
2. Create each secret below using the values from the JSON above:

| Secret name | Value |
|---|---|
| `ARM_CLIENT_ID` | `clientId` from the JSON |
| `ARM_CLIENT_SECRET` | `clientSecret` from the JSON |
| `ARM_SUBSCRIPTION_ID` | `subscriptionId` from the JSON |
| `ARM_TENANT_ID` | `tenantId` from the JSON |

Once all four secrets are added, the `Terraform plan` step will run automatically on the next push or PR and post the plan output as a PR comment.

---

### Summary of what each step unlocks

| Step | What it enables |
|---|---|
| 1 – Approve bot | `fmt`, `init`, `validate`, `plan` jobs actually execute |
| 2 – Enable Actions | Workflow is allowed to run at all |
| 3 – (no secrets needed) | `fmt ✅`, `init ✅`, `validate ✅` pass immediately |
| 4 – Add ARM_\* secrets | `plan ✅` runs and posts output to PR comment |

---

### Required GitHub Secrets (reference)

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `ARM_CLIENT_ID` | Service principal application (client) ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Target Azure subscription ID |
| `ARM_TENANT_ID` | Azure AD tenant ID |

---

## Security Considerations

- **Public network access is disabled** on the Log Analytics workspace and Application Insights component at the resource level (`internet_ingestion_enabled = false`, `internet_query_enabled = false`).
- **Azure Policy assignments** enforce the same restriction at the resource-group scope, preventing accidental re-enablement via the Portal or other tools.
- **PrivateOnly mode** on AMPLS (`ingestion_access_mode = "PrivateOnly"`, `query_access_mode = "PrivateOnly"`) blocks any non-private-endpoint traffic.
- The **instrumentation key** and **connection string** outputs are marked `sensitive = true` so they are not displayed in plain-text plan/apply output.

---

## Production Rollout Guidance

> ⚠️ **Important:** Disabling public access *before* DNS propagation completes will cause agents to fail ingestion silently for 5–15 minutes, creating monitoring blind spots.

**Recommended staged rollout:**

1. Deploy all resources with `internet_ingestion_enabled = true` / `internet_query_enabled = true` (canary workspace).
2. Validate DNS resolution from the workload subnet:
   ```bash
   nslookup <workspace-id>.ods.opinsights.azure.com
   # Should resolve to a 10.x.x.x address
   ```
3. Once DNS is confirmed, set `internet_ingestion_enabled = false` and `internet_query_enabled = false` and re-apply.
