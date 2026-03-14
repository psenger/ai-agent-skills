# IaC & Deployment Patterns Reference

Infrastructure as Code patterns by tool, with CI/CD pipeline patterns and
environment promotion strategies.

---

## Table of Contents

1. [Terraform / OpenTofu](#1-terraform--opentofu)
2. [Pulumi](#2-pulumi)
3. [AWS CDK](#3-aws-cdk)
4. [AWS CloudFormation](#4-aws-cloudformation)
5. [Azure Bicep](#5-azure-bicep)
6. [Helm / Kubernetes](#6-helm--kubernetes)
7. [Ansible](#7-ansible)
8. [Multi-Tool Projects](#8-multi-tool-projects)
9. [CI/CD Pipeline Patterns](#9-cicd-pipeline-patterns)
10. [Environment Promotion Strategy](#10-environment-promotion-strategy)

---

## 1. Terraform / OpenTofu

```
iac/
├── README.md
├── modules/                        # Reusable Terraform modules
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md              # Always document modules
│   ├── compute/
│   ├── database/
│   └── security/
├── environments/                   # Root modules per environment
│   ├── dev/
│   │   ├── main.tf                 # Calls modules with dev params
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars        # Dev-specific values
│   │   └── backend.tf              # Remote state config (S3, GCS, Azure Blob)
│   ├── staging/
│   │   └── (same structure)
│   └── prod/
│       └── (same structure)
└── shared/
    ├── dns/                        # Shared DNS zone
    ├── networking/                 # Shared VPC / VNet
    └── secrets/                    # Secrets manager bootstrap
```

**Agent-OS standard to add** (`agent-os/standards/backend/terraform.md`):
```markdown
# Terraform Standards
- All modules MUST have a README.md with required variables
- Remote state in: <S3 bucket / GCS bucket / Terraform Cloud>
- State locking: DynamoDB / GCS native locking
- Never store secrets in .tfvars — use Secrets Manager / Vault references
- Module versioning: pin to SHA or tag, never use `latest`
- `terraform fmt` run on all .tf files before commit
```

---

## 2. Pulumi

```
iac/
├── README.md
├── Pulumi.yaml                     # Project config
├── src/ OR index.ts / __main__.py  # IaC source (language-specific)
│   ├── components/                 # Reusable Pulumi ComponentResources
│   │   ├── network.ts
│   │   ├── compute.ts
│   │   └── database.ts
│   ├── environments/
│   │   ├── dev.ts
│   │   ├── staging.ts
│   │   └── prod.ts
│   └── index.ts                    # Entry point
├── Pulumi.dev.yaml                 # Stack config (dev)
├── Pulumi.staging.yaml
├── Pulumi.prod.yaml
└── package.json OR pyproject.toml  # IaC dependencies
```

**Key commands for deploy scripts:**
```bash
pulumi stack select dev
pulumi up --yes
pulumi stack select prod
pulumi up --yes --config-passphrase-file=.passphrase
```

---

## 3. AWS CDK

```
iac/
├── README.md
├── bin/
│   └── app.ts                      # CDK App entry point
├── lib/
│   ├── constructs/                 # Reusable L3 constructs
│   │   ├── network-construct.ts
│   │   ├── rds-construct.ts
│   │   └── ecs-construct.ts
│   ├── stacks/                     # CDK Stacks per environment/domain
│   │   ├── network-stack.ts
│   │   ├── app-stack.ts
│   │   └── data-stack.ts
│   └── config/
│       ├── dev.ts
│       ├── staging.ts
│       └── prod.ts
├── cdk.json
├── cdk.out/                        # Synthesized CloudFormation (gitignored)
└── package.json
```

**.gitignore addition:**
```
cdk.out/
*.js
*.d.ts
!jest.config.js
```

---

## 4. AWS CloudFormation

```
iac/
├── README.md
├── templates/                      # CloudFormation templates
│   ├── network.yaml                # VPC, subnets, security groups
│   ├── compute.yaml                # EC2, ECS, Lambda
│   ├── database.yaml               # RDS, DynamoDB
│   ├── storage.yaml                # S3, EFS
│   └── iam.yaml                    # IAM roles and policies
├── nested-stacks/                  # Reusable nested stack templates
│   ├── vpc-stack.yaml
│   └── ecs-cluster-stack.yaml
├── parameters/                     # Per-environment parameter files
│   ├── dev.json
│   ├── staging.json
│   └── prod.json
└── scripts/
    ├── deploy-stack.sh             # aws cloudformation deploy wrapper
    ├── validate.sh                 # aws cloudformation validate-template
    └── package.sh                  # aws cloudformation package (for nested stacks)
```

**Key commands for deploy scripts:**
```bash
# Validate template
aws cloudformation validate-template --template-body file://templates/network.yaml

# Deploy with parameters
aws cloudformation deploy \
  --template-file templates/network.yaml \
  --stack-name my-app-network-dev \
  --parameter-overrides file://parameters/dev.json \
  --capabilities CAPABILITY_IAM \
  --tags Environment=dev Project=my-app

# Package nested stacks (uploads to S3)
aws cloudformation package \
  --template-file templates/main.yaml \
  --s3-bucket my-cfn-artifacts \
  --output-template-file packaged.yaml
```

---

## 5. Azure Bicep

```
iac/
├── README.md
├── modules/                        # Reusable Bicep modules
│   ├── networking.bicep
│   ├── appservice.bicep
│   └── database.bicep
├── environments/
│   ├── dev/
│   │   ├── main.bicep              # Entry point
│   │   └── main.bicepparam         # Parameter file
│   ├── staging/
│   └── prod/
└── shared/
    └── monitoring.bicep            # Shared Log Analytics, App Insights
```

---

## 6. Helm / Kubernetes

```
iac/
├── README.md
└── helm/
    ├── <app-name>/                 # One chart per service
    │   ├── Chart.yaml
    │   ├── values.yaml             # Default values
    │   ├── values-dev.yaml         # Dev overrides
    │   ├── values-staging.yaml
    │   ├── values-prod.yaml
    │   └── templates/
    │       ├── deployment.yaml
    │       ├── service.yaml
    │       ├── ingress.yaml
    │       ├── configmap.yaml
    │       └── hpa.yaml            # Horizontal Pod Autoscaler
    └── charts/                     # Shared chart dependencies
```

**For GitOps (ArgoCD / Flux):**
```
deploy/
└── gitops/
    ├── applications/               # ArgoCD Application manifests
    │   ├── dev/
    │   ├── staging/
    │   └── prod/
    └── overlays/                   # Kustomize overlays (alternative to Helm values)
        ├── dev/
        ├── staging/
        └── prod/
```

---

## 7. Ansible

```
iac/
├── README.md
├── ansible/
│   ├── ansible.cfg                 # Ansible configuration
│   ├── playbooks/                  # Task orchestration
│   │   ├── site.yml                # Main playbook (imports all roles)
│   │   ├── webservers.yml          # Web server provisioning
│   │   ├── databases.yml           # Database provisioning
│   │   └── deploy.yml              # Application deployment
│   ├── roles/                      # Reusable roles
│   │   ├── common/                 # Base OS config (users, packages, firewall)
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   ├── handlers/
│   │   │   │   └── main.yml
│   │   │   ├── templates/
│   │   │   ├── files/
│   │   │   └── defaults/
│   │   │       └── main.yml
│   │   ├── nginx/
│   │   ├── postgres/
│   │   └── app/
│   ├── inventory/                  # Host inventories per environment
│   │   ├── dev/
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/
│   │   │       └── all.yml
│   │   ├── staging/
│   │   └── prod/
│   └── group_vars/                 # Shared variables across environments
│       └── all.yml
```

**Key commands:**
```bash
# Run playbook against dev inventory
ansible-playbook -i inventory/dev playbooks/site.yml

# Deploy app only
ansible-playbook -i inventory/staging playbooks/deploy.yml

# Dry run
ansible-playbook -i inventory/prod playbooks/site.yml --check --diff
```

---

## 8. Multi-Tool Projects

Many projects use multiple IaC tools (e.g., Terraform for cloud infra + Helm for k8s apps).

```
iac/
├── README.md                       # Explains which tool handles what
├── terraform/                      # Cloud infrastructure layer
│   ├── modules/
│   └── environments/
├── helm/                           # Application deployment layer
│   └── <charts>/
├── ansible/                        # Configuration management (if used)
│   ├── playbooks/
│   ├── roles/
│   └── inventory/
└── scripts/
    ├── bootstrap.sh                # First-time infra setup
    └── full-deploy.sh              # Orchestrates all tools in order
```

**Agent-OS standard:** Add `agent-os/standards/backend/iac-tool-map.md` explaining:
- What each tool is responsible for
- The order of operations for a full deploy
- Which environments each tool's state is stored in

---

## 9. CI/CD Pipeline Patterns

### GitHub Actions

```
.github/
└── workflows/
    ├── ci.yml                      # Lint, test, build (all branches)
    ├── deploy-dev.yml              # Auto-deploy on push to develop
    ├── deploy-staging.yml          # Deploy on PR merge to main (or manual)
    ├── deploy-prod.yml             # Manual approval + deploy to prod
    ├── iac-plan.yml                # Terraform/Pulumi plan on PR
    └── iac-apply.yml               # Terraform/Pulumi apply on merge
```

**Standard pipeline stages:**
```
PR opened → ci.yml:
  1. Lint
  2. Unit tests
  3. Build
  4. iac-plan.yml (IaC drift check)

Merge to develop → deploy-dev.yml:
  1. Build + push image
  2. Run IaC apply (dev)
  3. Deploy app (dev)
  4. Run smoke tests

Merge to main → deploy-staging.yml:
  1. Build + push image
  2. Run IaC apply (staging)
  3. Deploy app (staging)
  4. Run integration + e2e tests
  5. Notify team

Manual trigger / tag → deploy-prod.yml:
  1. Require human approval
  2. Run IaC apply (prod) — dry run first
  3. Require second approval
  4. Deploy app (prod)
  5. Run healthchecks
  6. Notify team
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test
  - build
  - iac-plan
  - iac-apply
  - deploy
  - healthcheck

lint:
  stage: lint
  script: [<lint command>]

test:
  stage: test
  script: [<test command>]

build:
  stage: build
  script: [<build command>]

deploy-dev:
  stage: deploy
  environment: dev
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

deploy-staging:
  stage: deploy
  environment: staging
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

deploy-prod:
  stage: deploy
  environment: prod
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

Use environment-scoped variables in GitLab for secrets per environment.

---

## 10. Environment Promotion Strategy

Use **three environments minimum** for any production system:

| Environment | Purpose | Promotion | Approval |
|-------------|---------|-----------|----------|
| **dev** | Active development | Auto on push | None |
| **staging** | Pre-prod validation | Auto on merge | None (or 1-person) |
| **prod** | Live traffic | Manual trigger | Required (2-person or change board) |

### State Management per Environment

Each environment has **isolated state**:

```
# Terraform: separate state files
s3://my-tfstate/dev/terraform.tfstate
s3://my-tfstate/staging/terraform.tfstate
s3://my-tfstate/prod/terraform.tfstate

# Pulumi: separate stacks
pulumi stack select myproject/dev
pulumi stack select myproject/staging
pulumi stack select myproject/prod
```

**Golden rule:** Prod must NEVER share state, credentials, or networking with dev/staging.

### deploy/scripts/ Standard Scripts

Include these in every project:

```bash
deploy/scripts/
├── deploy.sh          # Main deploy: args: --env=<dev|staging|prod> --service=<name>
├── rollback.sh        # Rollback to previous version: args: --env= --service= --version=
├── healthcheck.sh     # Post-deploy health verification
├── seed.sh            # Seed test data (dev/staging ONLY — guard against prod)
└── db-migrate.sh      # Run database migrations safely
```

**Agent-OS standard:** Add `agent-os/standards/backend/deploy-process.md` to document
deploy procedures, rollback steps, and environment access controls.
