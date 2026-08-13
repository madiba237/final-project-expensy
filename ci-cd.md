```mermaid
flowchart TD
    %% Stylisation des blocs
    classDef git fill:#2088FF,stroke:#fff,stroke-width:2px,color:white;
    classDef job fill:#24292E,stroke:#0366D6,stroke-width:2px,color:white;
    classDef step fill:#1F2328,stroke:#30363D,stroke-width:1px,color:white;
    classDef deploy fill:#FF9900,stroke:#fff,stroke-width:2px,color:white;

    Trigger([⚡ Event: Git Push / PR on main]):::git --> Runner[🖥️ Runner: ubuntu-latest]

    subgraph Workflow ["🚀 GitHub Actions Workflow (.github/workflows/ci-cd.yaml)"]
        
        subgraph Job_CI ["Job 1: Build & Test"]
            Runner --> Checkout[1. actions/checkout@v4]:::step
            Checkout --> SetupNode[2. actions/setup-node@v4]:::step 
            SetupNode --> Install[3. npm ci]:::step
            Install --> Test[4. npm test / lint]:::step
        end

        subgraph Job_Docker ["Job 2: Containerization"]
            Test --> DockerLogin[1. docker/login-action@v3]:::step
            DockerLogin --> BuildPush[2. docker/build-push-action@v5]:::step
            BuildPush --> DockerHub[(🐳 Docker Hub Registry)]:::git
        end

        subgraph Job_CD ["Job 3: Deploy to EKS"]
            DockerHub --> AWSAuth[1. aws-actions/configure-aws-credentials@v4]:::step
            AWSAuth --> KubeConfig[2. aws eks update-kubeconfig]:::step
            KubeConfig --> Rollout[3. kubectl apply / rollout restart]:::step
        end
    end

    Rollout -->|Rolling Update| EKSCluster[📦 AWS EKS Cluster: eks-alain]:::deploy
