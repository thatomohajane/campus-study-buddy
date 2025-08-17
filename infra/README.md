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

**Production deployments happen via GitHub Actions only!**

### Simple CI/CD Workflow:

1. **Create feature branch** from `master`
   ```bash
   git checkout -b feature/infrastructure-update
   ```

2. **Make infrastructure changes** and commit
   ```bash
   git add .
   git commit -m "feat: update infrastructure configuration"
   ```

3. **Push branch** → Automatically triggers `terraform plan` ✅
   ```bash
   git push origin feature/infrastructure-update
   ```

4. **Check GitHub Actions** - Plan validates your changes
   - View results in GitHub Actions tab
   - Plan shows what infrastructure changes will be made

5. **Create Pull Request** and get team review
   - Standard code review process
   - Team reviews proposed infrastructure changes

6. **Merge to master** → Triggers `terraform apply` with **manual approval**
   - GitHub pauses and asks for your approval
   - You review the plan output one final time
   - Click "Approve and deploy" to proceed
   - Infrastructure is deployed to Azure

### Key Features:
- ✅ **Automated validation** - Plan runs on every feature branch push
- ✅ **Manual approval gate** - Human confirmation before any deployment
- ✅ **Environment protection** - All secrets managed in production environment
- ✅ **Emergency destroy** - Manual workflow for infrastructure cleanup

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
        └── infrastructure.yml       # CI/CD pipeline
```

## 🤝 Contributing

### Standard Development Flow:

1. **Create feature branch** from `master`
2. **Make infrastructure changes** 
3. **Push branch** → `terraform plan` runs automatically
4. **Verify plan succeeds** ✅ in GitHub Actions
5. **Create Pull Request** for team review
6. **Merge after approval** → `terraform apply` waits for manual approval
7. **Approve deployment** → Infrastructure deployed to Azure

### Manual Operations:

**Destroy Infrastructure** (Emergency Only):
- Go to **Actions** → **Infrastructure Deployment** → **Run workflow**
- Select action: `destroy`
- Requires manual approval before execution
- ⚠️ **WARNING**: This will destroy ALL Azure resources

## 🚨 Important Notes

### The Simple Rules:
1. **Push feature branch** → Plan validates automatically
2. **Merge to master** → Apply waits for your approval
3. **Manual destroy only** → Via workflow dispatch

### DO NOT:
- ❌ Deploy production infrastructure locally
- ❌ Store secrets in repository (use environment only)
- ❌ Bypass the GitHub Actions workflow
- ❌ Push directly to `master` branch

### DO:
- ✅ Use the GitHub Actions workflow for all deployments
- ✅ Test infrastructure changes in feature branches
- ✅ Review plan output before approving deployment
- ✅ Use production environment for all secrets
- ✅ Follow the manual approval process