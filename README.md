Eloquent AI - DevOps Technical Challenge
1. Architecture Overview
This project deploys a scalable Python FastAPI application to AWS using Infrastructure as Code (Terraform). The architecture follows a secure 2-tier design pattern to ensure isolation of compute resources.

Key Components:
Compute: AWS ECS (Elastic Container Service) using the Fargate launch type.

Decision: Fargate was chosen for its serverless nature, reducing operational overhead (OS patching, server management) compared to EC2 or EKS.

Networking:

Application Load Balancer (ALB): Placed in Public Subnets to handle incoming traffic.

ECS Tasks: Placed in Private Subnets for security. Containers have no direct internet access and can only be reached via the ALB.

NAT Gateways: Used to allow private containers to pull images from ECR and install updates.

Scaling: Configured with AWS Auto Scaling.

Policy: Scale out when average CPU utilization exceeds 70%.

Database: Not currently required.

Design Note: If a database were needed, it would be placed in a separate, isolated subnet tier with restricted Security Group rules allowing access only from the ECS Security Group.

flowchart TD
    %% Main Infrastructure Flow
    CI_CD["GitHub Actions (CI/CD)"] -->|Terraform Apply| INFRA["AWS Infrastructure Managed via TF"]
    INFRA --> VPC["Secure VPC"]

    subgraph "Public Subnets (Tier 1)"
        ALB["Application Load Balancer"]
        NAT["NAT Gateways"]
    end

    subgraph "Private Subnets (Tier 2)"
        ECS["ECS Fargate Cluster"]
        TASKS["ECS Tasks (FastAPI App)"]
        ASG["ECS Auto Scaling (CPU > 70%)"]
    end

    %% Networking & App Flow
    VPC --> Public_Subnets
    Public_Subnets --> Private_Subnets
    INTERNET((Internet)) -->|HTTPS Traffic| ALB
    ALB -->|Routing| TASKS
    ECS -->|Manages| TASKS
    TASKS -->|Triggers| ASG
    TASKS -.->|Outbound Traffic (e.g. Updates)| NAT

    %% Deployment & Controls Flow
    subgraph Controls & Artifacts
        OIDC["AWS OIDC Identity Provider"] -->|Auth Token| CI_CD
        STATE["S3 (TF State) + DynamoDB (Locking)"] <-->|Read/Write| CI_CD
        TESTS["Linting (Flake8) + Unit Tests (Pytest)"] -->|Gate| CI_CD
        ECR["Amazon ECR Container Registry"]
    end

    %% Pipeline Actions
    CI_CD -->|Docker Build & Push| ECR
    ECR -.->|Pull Image| TASKS
    CI_CD -->|Update Service / Rollback| ECS

    %% Styling similar to example
    style CI_CD fill:#f9f,stroke:#333,stroke-width:2px
    style ECS fill:#E6F2FF,stroke:#333,stroke-width:2px
    style ALB fill:#FFE6CC,stroke:#333,stroke-width:2px
    style ECR fill:#D9EAD3,stroke:#333,stroke-width:2px
    style Controls & Artifacts fill:#f4f4f4,stroke:#666,stroke-width:2px,stroke-dasharray: 5 5

2. Prerequisites
Before running the pipeline or local terraform, ensure you have the following configured:

Tools
Terraform (v1.5+)

Docker

AWS CLI

AWS Setup (Bootstrap)
To maintain state security, this project uses a Remote Backend. You must manually create the following resources once (or use a bootstrap script):

S3 Bucket: To store the terraform.tfstate file.

Production Note: Ensure Versioning and Delete Protection are enabled.

DynamoDB Table: To handle state locking and prevent race conditions.

Partition Key: LockID (String).

OIDC Provider: Configured for GitHub Actions to allow passwordless authentication to AWS.

3. CI/CD Pipeline
The automation is handled via GitHub Actions. The pipeline is designed to be fail-fast and secure.

Workflow Steps:
CI (Pull Requests & Main):

Installs Python dependencies.

Runs Flake8 linting to ensure code quality.

Runs Pytest unit tests.

Infrastructure Planning:

On Pull Requests: Runs terraform plan and outputs the changes to the PR comments.

On Merge to Main: Runs terraform apply.

Delivery (CD):

Builds the Docker image.

Tags image with the Git SHA (for immutability).

Pushes image to Amazon ECR.

Deployment:

Updates the ECS Task Definition with the new image ID.

Forces a new deployment in the ECS Service.

Rollback: Uses wait-for-service-stability. If the new container fails health checks, the deployment fails, and ECS automatically keeps the old version running.

4. Deployment Instructions
A. Local Development / First Run
Clone the repository:

Bash

git clone https://github.com/your-username/eloquent-assignment.git
cd eloquent-assignment
Navigate to Terraform directory and initialize:

Bash

cd terraform
terraform init \
  -backend-config="bucket=YOUR_S3_BUCKET_NAME" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=YOUR_DYNAMODB_TABLE"
Review and Apply Infrastructure:

Bash

terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
B. Triggering the Pipeline
Simply push changes to the main branch.

Bash

git add .
git commit -m "feat: update api logic"
git push origin main
Check the Actions tab in GitHub to watch the deployment proceed.

5. Design Decisions & Trade-offs
Fargate vs. EC2/EKS
Decision: We used Fargate.

Reasoning: It abstracts the underlying infrastructure. We don't need to manage cluster nodes or optimize bin-packing.

Trade-off: Fargate is generally more expensive per vCPU/hour than managing your own EC2 Spot instances or Reserved Instances. However, for a team with limited DevOps resources, the saved engineering time outweighs the compute cost.

Security Considerations
Current State: The application runs on HTTP (Port 80) behind the ALB.

Production Requirement: In a real production environment, we would attach an ACM Certificate to the Load Balancer and force an HTTPS listener (443) with a redirect from HTTP.

IAM: We adhere to Least Privilege. The ECS Task Role has access only to the specific resources it needs (e.g., CloudWatch Logs, ECR Pull).

Terraform Structure
We utilized for_each loops for Subnets and Route Tables to ensure scalability.

If we need to add a 3rd Availability Zone, we simply add "us-east-1c" to the variable list, and Terraform automatically provisions the new Subnet, NAT Gateway (if HA), and Route associations.
