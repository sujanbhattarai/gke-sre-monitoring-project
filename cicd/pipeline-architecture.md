# CI/CD Pipeline Architecture

## 1. Architecture Overview

The CI/CD pipeline automates the delivery of a
containerized NGINX application to Google Kubernetes
Engine using GitHub Actions.

The architecture separates configuration validation,
cloud authentication, container image management,
application deployment, and health verification.

## 2. Infrastructure Components

| Component | Configuration |
|---|---|
| Source Control | GitHub |
| CI/CD Platform | GitHub Actions |
| Container Runtime | Docker |
| Container Registry | Google Artifact Registry |
| Registry Repository | sre-docker-repo |
| Kubernetes Platform | GKE Autopilot |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Deployment | sre-demo-app |
| Application | NGINX |
| Baseline Replicas | 2 |

## 3. Pipeline Architecture

    GitHub Repository
           |
           v
    GitHub Actions Workflow
           |
           v
    Kubernetes YAML Validation
           |
           v
    Workload Identity Federation
           |
           v
    Google Cloud Service Account
           |
           v
    Docker Image Build
           |
           v
    Git SHA Image Tagging
           |
           v
    Google Artifact Registry
           |
           v
    GKE Deployment Update
           |
           v
    Kubernetes Rolling Update
           |
           v
    Application Health Verification

## 4. Workflow Configuration

Workflow location:

    .github/workflows/ci-cd.yaml

The workflow supports:

- Push events to the main branch.
- Pull requests targeting the main branch.
- Manual workflow execution.

Pull requests execute configuration validation.
Deployment is restricted to eligible main-branch runs.

## 5. Continuous Integration Stage

The validation job performs:

1. Repository checkout.
2. YAML validator installation.
3. Kubernetes YAML validation.
4. Configuration syntax verification.

The deployment job depends on successful completion
of the validation job.

YAML linting validates syntax and formatting but does
not replace application integration testing.

## 6. Cloud Authentication

GitHub Actions authenticates to Google Cloud using
OpenID Connect and Workload Identity Federation.

Authentication flow:

    GitHub Actions OIDC Token
                |
                v
    Workload Identity Provider
                |
                v
    Google Cloud Service Account
                |
                v
    Temporary Cloud Credentials

This design avoids storing long-lived Google Cloud
service account keys in GitHub.

## 7. Container Build Architecture

The pipeline builds the application using Docker.

Dockerfile location:

    app/app/Dockerfile

Application source:

    app/index.html

The container uses an NGINX Alpine-based image and
includes the custom application HTML.

Each automated build receives a Git commit SHA tag,
providing traceability to the source code.

## 8. Artifact Registry Integration

The pipeline publishes container images to Google
Artifact Registry in the us-east4 region.

Image naming convention:

    REGION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE:GIT_SHA

The GitHub deployment service account has repository
write access.

The GKE node service account has repository read access.

## 9. Kubernetes Deployment

The workflow connects to the existing GKE cluster
and updates the application container image.

Deployment command:

    kubectl set image deployment/sre-demo-app \
      nginx=IMAGE_URI -n default

This approach updates the container image without
directly resetting the HPA-managed replica count.

The deployment uses Kubernetes rolling updates
with readiness and liveness probes.

## 10. Application Traffic Architecture

    External Client
           |
           v
    Google Cloud Application Load Balancer
           |
           v
    GKE Ingress
           |
           v
    Kubernetes Service
           |
           v
    Network Endpoint Group
           |
           v
    Application Pods

The Ingress configuration provisions the external
load balancer and associated backend resources.

## 11. Post-Deployment Verification

The pipeline validates deployment health using:

- Kubernetes rollout status.
- Application pod status inspection.
- External HTTP application verification.
- Expected application content validation.

The workflow fails if rollout verification or
the HTTP content check fails.

## 12. Deployment Concurrency

The workflow uses a deployment concurrency group
to prevent overlapping deployment jobs.

Deployment jobs have a maximum execution time
of 20 minutes.

Kubernetes rollout verification has a timeout
of 300 seconds.

## 13. Release Traceability

| Release | Git Commit | Result |
|---|---|---|
| Version 1 | a5ea553 | Successful |
| Version 2 | 2c80e41 | Successful |
| Rollback to Version 1 | a5ea553 | Successful |
| Restore Version 2 | 2c80e41 | Successful |

The release lifecycle was validated using GitHub
Actions, Artifact Registry, Kubernetes deployment
history, and external application responses.

## 14. Architecture Benefits

- Automated application delivery.
- Keyless cloud authentication.
- Versioned container images.
- Repeatable deployment procedures.
- Controlled rolling updates.
- Application health verification.
- Deployment traceability.
- Kubernetes rollback capability.

## 15. Architecture Limitations

This is a production-inspired demonstration environment.

The pipeline assumes existing Kubernetes infrastructure.

The health check validates expected application content
but does not verify the exact Git SHA being served.

Automatic rollback is not implemented.

Container vulnerability scanning is not enabled.

Documentation-only commits currently trigger deployments.

Future enhancements include path-based workflow triggers,
immutable image digests, automated rollback, HTTPS,
integration testing, and additional security hardening.
