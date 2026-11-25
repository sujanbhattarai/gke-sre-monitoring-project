# Automated CI/CD Pipeline for Google Kubernetes Engine

## 1. Project Overview

This project demonstrates an automated CI/CD pipeline
for deploying a containerized application to Google
Kubernetes Engine (GKE) using GitHub Actions.

The pipeline automates application validation, Docker
image creation, Artifact Registry publishing, Kubernetes
deployment, and post-deployment health verification.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| GitHub | Source code management |
| GitHub Actions | CI/CD automation |
| Docker | Application containerization |
| Artifact Registry | Container image storage |
| Google Kubernetes Engine | Container orchestration |
| Workload Identity Federation | Keyless authentication |
| Kubernetes RBAC | Deployment authorization |
| Google Cloud Load Balancer | External application access |
| Cloud Monitoring | Infrastructure and application monitoring |
| Cloud Logging | Centralized logging |

## 3. CI/CD Architecture

    Developer
        |
        v
    GitHub Repository
        |
        v
    GitHub Actions
        |
        v
    Kubernetes YAML Validation
        |
        v
    Workload Identity Federation
        |
        v
    Docker Build and Git SHA Tagging
        |
        v
    Google Artifact Registry
        |
        v
    GKE Rolling Deployment
        |
        v
    Rollout and Application Health Validation

## 4. Continuous Integration

The CI stage performs the following operations:

- Checks out the GitHub repository.
- Installs the YAML validation utility.
- Validates Kubernetes configuration files.
- Prevents deployment when validation fails.
- Supports validation for pull requests.

## 5. Continuous Delivery

The deployment stage performs the following operations:

- Authenticates to Google Cloud using Workload Identity Federation.
- Configures Docker authentication.
- Builds the application container image.
- Tags the image using the Git commit SHA.
- Publishes the image to Artifact Registry.
- Connects to the GKE cluster.
- Updates the Kubernetes deployment.
- Monitors the rolling update.
- Validates application accessibility through HTTP.

## 6. Security Implementation

The pipeline implements keyless authentication and
least-privilege access controls.

- GitHub OpenID Connect authentication.
- Workload Identity Federation.
- Repository-specific identity restriction.
- Dedicated GitHub deployment service account.
- Repository-level Artifact Registry Writer permission.
- Repository-level Artifact Registry Reader permission
  for the GKE node service account.
- Namespace-level Kubernetes RBAC.
- No long-lived service account JSON keys.

## 7. Deployment Strategy

The application uses Kubernetes rolling updates.

Configuration:

- Desired baseline replicas: 2
- Maximum surge: 1
- Maximum unavailable: 0
- Readiness probes enabled
- Liveness probes enabled
- Horizontal Pod Autoscaling enabled

The deployment workflow updates the container image
without directly resetting the HPA-managed replica count.

## 8. Container Image Versioning

Container images are tagged using Git commit SHAs.

This provides traceability between application source
code, pipeline execution, and deployed container images.

Validated release versions:

| Release | Git Commit | Pipeline Duration |
|---|---|---|
| Version 1 | a5ea553 | 1 minute 36 seconds |
| Version 2 | 2c80e41 | 1 minute 39 seconds |

## 9. Rollback and Recovery Testing

A controlled Kubernetes rollback simulation was performed.

Test sequence:

1. Deploy Version 1 using GitHub Actions.
2. Update application source code.
3. Automatically deploy Version 2.
4. Identify the previous Kubernetes deployment revision.
5. Roll back to Version 1.
6. Verify application content and pod health.
7. Restore Version 2.
8. Verify deployment availability.

The rollback successfully restored the previous
application version without rebuilding the container image.

## 10. Validation Results

| Validation | Result |
|---|---|
| Docker image build | Passed |
| Local container testing | Passed |
| Artifact Registry publishing | Passed |
| Workload Identity Federation | Passed |
| Kubernetes RBAC | Passed |
| GitHub Actions pipeline | Passed |
| Automated GKE deployment | Passed |
| Git SHA image versioning | Passed |
| HTTP 200 validation | Passed |
| Version 2 automated release | Passed |
| Kubernetes rollback | Passed |
| Latest version restoration | Passed |
| Final ready replicas | 2/2 |
| Final available replicas | 2 |

## 11. SRE and DevOps Capabilities

This implementation demonstrates:

- CI/CD pipeline engineering
- Cloud-native application deployment
- Container lifecycle management
- Secure cloud authentication
- Infrastructure access management
- Kubernetes deployment strategies
- Application reliability validation
- Release management
- Rollback and recovery procedures
- Operational troubleshooting

## 12. Project Limitations

This implementation is a production-inspired SRE lab.

The rollback was a controlled simulation rather than
recovery from an actual production outage.

Continuous availability during the rollback was not
measured.

The pipeline assumes that the Kubernetes deployment
and supporting infrastructure already exist.

The Kubernetes manifest contains a baseline image,
while automated releases use Git SHA image tags.

Future improvements include automated rollback,
container vulnerability scanning, immutable image
digests, HTTPS, and additional integration testing.

## 13. Conclusion

The project successfully demonstrates an automated
application delivery lifecycle using GitHub Actions,
Docker, Artifact Registry, and Google Kubernetes Engine.

Secure authentication, versioned deployments, health
validation, and rollback testing demonstrate practical
Site Reliability Engineering and DevOps capabilities.
