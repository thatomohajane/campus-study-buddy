# Campus Study Buddy - Infrastructure

🏗️ **Infrastructure as Code** for the Campus Study Buddy platform using Terraform and Azure.

## 🚀 Quick Start

This repository contains the complete Azure infrastructure setup for the Campus Study Buddy platform.

### Architecture

- **Azure Container Apps** - API backend hosting
- **Azure Static Web Apps** - Frontend hosting  
- **Azure SQL Database** - Data storage
- **Azure Web PubSub** - Real-time chat
- **Azure Key Vault** - Secrets management
- **Azure Storage** - File storage

## 📋 Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.5.0
- Azure subscription with Contributor access

## 🔧 Local Development

```bash
# Navigate to terraform directory
cd infra/terraform

# Initialize Terraform
terraform init -backend-config="environments/prod/-backend-config"

# Plan deployment
terraform plan -var-file="environments/prod/terraform.tfvars" -var="database_admin_password=YOUR_PASSWORD"

# Apply changes (local testing only)
terraform apply
```

## 🎯 Production Deployment

**Production deployments happen via GitHub Actions only!**

### Workflow:
1. Create feature branch from `main`
2. Make infrastructure changes
3. Create PR → Triggers `terraform plan`
4. Review plan output in GitHub Actions
5. Merge after approval → Triggers `terraform apply`
6. Manual operations available via "Run workflow" button


## 📁 Structure

```
infra/
├── terraform/
│   ├── environments/
│   │   └── prod/
│   │       └── terraform.tfvars
│   ├── modules/
│   │   ├── core/          # Storage, Database, Key Vault
│   │   ├── compute/       # Container Apps, Static Web Apps
│   │   ├── network/       # VNet, Subnets, NSGs
│   │   ├── communication/ # Web PubSub, Notifications
│   │   ├── identity/      # Azure AD, Service Principals
│   │   └── automation/    # Logic Apps, Queues
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── .github/
    └── workflows/
        └── infrastructure.yml
```

## 🤝 Contributing

1. Create feature branch from `main`
2. Make infrastructure changes
3. Test locally if needed (optional)
4. Create PR → Triggers `terraform plan` automatically
5. Review plan output in GitHub Actions tab
6. Request approval from team members
7. Merge after approval → Triggers `terraform apply`

### Manual Operations
- Go to Actions → Infrastructure → "Run workflow"
- Choose action: `plan`, `apply`, or `destroy`
- Requires production environment approval

---

**⚠️ Important:** Never deploy production infrastructure locally. Always use the GitHub Actions workflow.