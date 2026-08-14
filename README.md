💰 Expensy - Full-Stack Microservices Application on AWS EKS
This project documents the cloud-native deployment, CI/CD automation, Kubernetes orchestration, and full observability stack setup for Expensy (an expense tracking application).

🏗️ Architecture & Project Components
The application is built on a containerized microservices architecture deployed on a managed AWS EKS cluster:

Frontend: Web application built with Next.js / React.

Backend: REST API built with Node.js / Express.

Database & Cache: MongoDB for data persistence and Redis for caching.

Infrastructure as Code (IaC): AWS infrastructure provisioning (VPC, Subnets, EKS Cluster, EC2 Node Groups) using Terraform.

Containerization & Orchestration: Optimized Dockerfiles, Kubernetes manifests (Deployments, Services, Ingress/ELB), and release management via Helm.

CI/CD Pipeline: GitHub Actions workflows for automated building, pushing Docker images to Docker Hub, and continuous deployment to the EKS cluster.

Observability & Monitoring:

Prometheus & Grafana: Application and infrastructure metrics collection and visualization using the kube-prometheus-stack Helm chart.

AWS CloudWatch & Fluent Bit: Real-time application log aggregation via aws-for-fluent-bit configured with IRSA (IAM Roles for Service Accounts).

🛠️ Summary of Technical Achievements
1. Infrastructure Provisioning (Terraform & AWS)
Deployed a dedicated VPC on AWS (us-east-1) with public and private subnets.

Created an AWS EKS cluster (eks-alain) with an EC2 NodeGroup.

Configured IAM / OIDC integration to allow Kubernetes pods to securely interact with AWS services without static hardcoded credentials.

2. Containerization & Kubernetes Deployment
Authored multi-stage build Dockerfiles for both frontend and backend services.

Validated local deployments using Docker Compose.

Organized the EKS cluster using distinct Namespaces:

expensy: Application pods (Frontend, Backend, MongoDB, Redis).

monitoring: Prometheus stack and Grafana dashboards.

logging: Fluent Bit DaemonSet.

Exposed services publicly via AWS Classic Load Balancers (ELB) configured as internet-facing.

3. CI/CD & Automation (GitHub Actions)
Automated pipeline triggering on every push to the main branch:

Unit testing and code linting.

Building application Docker images.

Publishing tagged images (latest / versions) to Docker Hub.

Automated deployment (kubectl apply / rollout) to the EKS cluster using secure secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, DOCKERHUB_TOKEN).

4. Observability & Monitoring
Grafana: Built custom dashboards to monitor pod CPU/RAM usage in real time.



CloudWatch Logs: Deployed Fluent Bit attached to a dedicated IAM role (FluentBitCloudWatchRole) via IRSA to centralize all logs under /aws/containerinsights/eks-alain/application.