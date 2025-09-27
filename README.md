# Retail Store Sample App - GitOps with GKE autopilot mode
<img width="1326" height="667" alt="Screenshot from 2025-09-27 11-54-01" src="https://github.com/user-attachments/assets/72e36f43-90ac-4ffd-b3c2-707b3aa45de6" />
[▶ Watch demo video](https://drive.google.com/file/d/1NOIha-nAlw0KCfXyhQFetMRnGe-fgj05/view)

## Overview

The Retail Store Sample App demonstrates a modern microservices architecture deployed on GCP GKE using GitOps principles. The application consists of multiple services that work together to provide a complete retail store experience:


- **UI Service**: Java-based frontend
- **Catalog Service**: Go-based product catalog API
- **Cart Service**: Java-based shopping cart API
- **Orders Service**: Java-based order management API
- **Checkout Service**: Node.js-based checkout orchestration API


## Infrastructure Architecture

The Infrastructure Architecture follows cloud-native best practices:

- **Microservices**: Each component is developed and deployed independently
- **Containerization**: All services run as containers on Kubernetes
- **GitOps**: Infrastructure and application deployment managed through Git
- **Infrastructure as Code**: All AWS resources defined using Terraform
- **CI/CD**: Automated build and deployment pipelines with GitHub Actions


