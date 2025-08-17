# Campus Study Buddy - Infrastructure

🏗️ **Infrastructure as Code** for the Campus Study Buddy platform using Terraform and Azure.

## 🚀 Quick Start

This repository contains the complete Azure infrastructure setup for the Campus Study Buddy platform.

### Architecture

- **Azure Container Apps** - API backend hosting
- **Azure Static Web Apps** - Frontend hosting  
- **Azure PostgreSQL Flexible Server** - Data storage
- **Azure Web PubSub** - Real-time chat
- **Azure Key Vault** - Secrets management
- **Azure Storage** - File storage
- **Azure Virtual Network** - Network isolation and security

## 📋 Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.5.0
- Azure subscription with Contributor access
- GitHub repository with production environment configured
- GitHub branch protection rules enabled on `master` branch

## 🔧 Local Development

```bash
# Navigate to terraform directory
cd infra/terraform

# Initialize Terraform
terraform init -backend-config="environments/prod/-backend-config"

# Plan deployment (validation only)
terraform plan -var-file="environments/prod/terraform.tfvars"

# Format and validate code
terraform fmt -recursive
terraform validate
```

## 🎯 Production Deployment

**Production deployments happen via GitHub Actions only with branch protection!**

### Decoupled CI/CD Workflow:

1. **Create feature branch** from `master`
   ```bash
   git checkout -b feature/infrastructure-update
   ```

2. **Make infrastructure changes** and commit
   ```bash
   git add .
   git commit -m "feat: update infrastructure configuration"
   ```

3. **Push branch** → Triggers `terraform-plan.yml` workflow ✅
   ```bash
   git push origin feature/infrastructure-update
   ```

4. **Verify plan passes** in GitHub Actions
   - Check **Actions** → **Terraform Plan** workflow
   - Ensure terraform validation succeeds
   - Review planned infrastructure changes

5. **Create Pull Request** to `master`
   ```bash
   gh pr create --title "Infrastructure update" --body "Description of changes"
   ```

6. **Get team review** and approval on PR
   - Code review process
   - Team reviews infrastructure changes
   - All checks must pass

7. **Merge PR** → Triggers `terraform-apply.yml` workflow with **manual approval**
   ```bash
   gh pr merge --merge
   ```

8. **Manual approval process**:
   - GitHub pauses deployment for approval
   - Review terraform plan output
   - Click **"Review deployments"** → **"Approve and deploy"**
   - Infrastructure deployed to Azure ✅

### Workflow Architecture:
- 🔄 **terraform-plan.yml** - Validation on feature branch push
- 🚀 **terraform-apply.yml** - Deployment on PR merge (with approval)
- 💥 **terraform-destroy.yml** - Emergency cleanup (manual only)

### Key Features:
- ✅ **Branch protection** - No direct pushes to master allowed
- ✅ **Decoupled workflows** - Each workflow has single responsibility
- ✅ **PR merge trigger** - Apply only runs when PR is merged to master
- ✅ **Manual approval gate** - Human confirmation before deployment
- ✅ **Environment secrets** - All credentials in production environment

## 📁 Structure

```
infra/
├── terraform/
│   ├── environments/
│   │   └── prod/
│   │       ├── terraform.tfvars     # Non-sensitive configuration
│   │       └── -backend-config      # Terraform backend settings
│   ├── modules/
│   │   ├── core/          # Storage, Database, Key Vault
│   │   ├── compute/       # Container Apps, Static Web Apps
│   │   ├── network/       # VNet, Subnets, NSGs
│   │   ├── communication/ # Web PubSub, Notifications
│   │   ├── identity/      # Azure AD, Service Principals
│   │   └── automation/    # Logic Apps, Queues
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   └── provider.tf        # Azure provider configuration
└── .github/
    └── workflows/
        ├── terraform-plan.yml      # Plan workflow (feature branches)
        ├── terraform-apply.yml     # Apply workflow (PR merge)
        └── terraform-destroy.yml   # Destroy workflow (manual)
```

## 🤝 Contributing

### Standard Development Flow:

1. **Create feature branch** from `master`
2. **Make infrastructure changes** 
3. **Push branch** → **terraform-plan.yml** validates changes
4. **Verify plan succeeds** ✅ in GitHub Actions
5. **Create Pull Request** for team review
6. **Team approves PR** and merges to master
7. **PR merge triggers terraform-apply.yml** → Manual approval required
8. **Approve deployment** → Infrastructure deployed to Azure

### Manual Operations:

**Destroy Infrastructure** (Emergency Only):
- Go to **Actions** → **Terraform Destroy** → **Run workflow**
- Type `destroy` to confirm
- Requires manual approval before execution
- ⚠️ **WARNING**: This will destroy ALL Azure resources

## 🔐 Security & Environment Setup

### GitHub Environment Configuration:
All secrets are stored in the **production environment**:

**Required Secrets:**
- `AZURE_CLIENT_ID` - Service Principal Client ID
- `AZURE_CLIENT_SECRET` - Service Principal Secret
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
- `AZURE_TENANT_ID` - Azure Tenant ID
- `TF_VAR_database_admin_password` - Database admin password

**Environment Protection:**
- **Required reviewers** - Manual approval for deployments
- **Branch protection** - Master branch protected from direct pushes
- **Environment-only secrets** - No repository-level secrets

### Branch Protection Rules:
- ✅ **Require pull request reviews** before merging
- ✅ **Require status checks** to pass (terraform-plan)
- ✅ **Require branches to be up to date** before merging
- ✅ **Restrict pushes** to master branch

## 🔍 Workflow Details

### terraform-plan.yml
- **Trigger**: Push to any branch except `master`
- **Purpose**: Validate terraform configuration
- **Environment**: Uses production environment secrets
- **Approval**: None required (validation only)

### terraform-apply.yml
- **Trigger**: Pull request merged to `master`
- **Purpose**: Deploy infrastructure to Azure
- **Environment**: Uses production environment secrets
- **Approval**: Manual approval required before apply

### terraform-destroy.yml
- **Trigger**: Manual workflow dispatch only
- **Purpose**: Emergency infrastructure cleanup
- **Environment**: Uses production environment secrets
- **Approval**: Manual approval + confirmation required

## 🚨 Important Notes

### The Decoupled Rules:
1. **Push feature branch** → terraform-plan validates
2. **Merge PR to master** → terraform-apply waits for approval
3. **Manual destroy only** → Emergency cleanup via workflow dispatch

### DO NOT:
- ❌ Deploy production infrastructure locally
- ❌ Store secrets at repository level (use environment only)
- ❌ Bypass the GitHub Actions workflows
- ❌ Push directly to `master` branch (protected)
- ❌ Skip the manual approval process

### DO:
- ✅ Use separate workflows for different operations
- ✅ Test infrastructure changes in feature branches
- ✅ Create PRs for all infrastructure changes
- ✅ Review plan output before approving deployment
- ✅ Use production environment for all secrets
- ✅ Follow branch protection and approval processes