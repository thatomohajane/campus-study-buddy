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
- GitHub repository with branch protection rules enabled

## 🔧 Local Development

```bash
# Navigate to terraform directory
cd infra/terraform

# Initialize Terraform
terraform init -backend-config="environments/prod/-backend-config"

# Plan deployment (validation only)
terraform plan -var-file="environments/prod/terraform.tfvars" -var="database_admin_password=YOUR_PASSWORD"

# Format and validate code
terraform fmt -recursive
terraform validate
```

## 🎯 Production Deployment

**Production deployments happen via GitHub Actions only!**

### Modern CI/CD Workflow:

1. **Create feature branch** from `master`
   ```bash
   git checkout -b feature/infrastructure-update
   ```

2. **Make infrastructure changes** and commit
   ```bash
   git add .
   git commit -m "feat: update infrastructure configuration"
   ```

3. **Push branch** → Automatically triggers `terraform plan`
   ```bash
   git push origin feature/infrastructure-update
   ```

4. **Check GitHub Actions** - Plan must pass ✅ before proceeding
   - View results in GitHub Actions tab
   - Plan validates configuration and shows changes

5. **Create Pull Request** → Shows plan results in PR comments
   - Plan results are automatically posted to PR
   - Team can review proposed infrastructure changes

6. **Merge after approval** → Automatically triggers `terraform apply`
   - Only possible if plan validation passed
   - Deploys changes to production Azure environment

### Safety Features:
- ✅ **Branch protection** - Plan failures block merge
- ✅ **Automated validation** - No manual plan/apply steps
- ✅ **Plan visibility** - Results shown in PR comments
- ✅ **Environment protection** - Production environment approval required
- ✅ **Audit trail** - All changes tracked in Git history

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
4. **Verify plan passes** ✅ in GitHub Actions
5. **Create Pull Request**
6. **Review plan output** in PR comments
7. **Request team approval**
8. **Merge after approval** → `terraform apply` runs automatically

### Emergency Operations:

**Destroy Infrastructure** (Emergency Only):
- Go to **Actions** → **Infrastructure Deployment** → **Run workflow**
- Select action: `destroy`
- Requires production environment approval
- ⚠️ **WARNING**: This will destroy ALL Azure resources

## 🔐 Security & Best Practices

### Secrets Management:
- **Sensitive values** → GitHub Secrets (never in code)
- **Non-sensitive config** → `terraform.tfvars` (committed to repo)
- **Azure authentication** → Service Principal with least privilege
- **Key Vault integration** → Application secrets stored securely

### Network Security:
- **Private endpoints** for database and storage
- **VNet integration** for Container Apps
- **Network Security Groups** for traffic control
- **Least privilege access** with managed identities

### Cost Optimization:
- **Free tier services** where possible (Web PubSub, Static Web Apps)
- **Flexible server** for PostgreSQL (cost-effective)
- **Local redundant storage** to minimize costs
- **Auto-scaling** with minimum 0 replicas

## 🚨 Important Notes

### DO NOT:
- ❌ Deploy production infrastructure locally
- ❌ Commit sensitive values to repository
- ❌ Bypass the GitHub Actions workflow
- ❌ Push directly to `master` branch
- ❌ Run manual `terraform apply` in production

### DO:
- ✅ Use the GitHub Actions workflow for all deployments
- ✅ Test infrastructure changes in feature branches
- ✅ Review plan output before merging
- ✅ Use Azure Key Vault for application secrets
- ✅ Follow the branch protection workflow

**Questions?** Check the GitHub Actions logs or create an issue in this repository.