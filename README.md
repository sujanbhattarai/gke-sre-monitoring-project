# GCP/GKE Site Reliability Engineering Project

## Project Overview

A hands-on Site Reliability Engineering project
demonstrating cloud infrastructure, Kubernetes,
observability, CI/CD automation, and application
reliability using Google Cloud Platform.

## Technology Stack

| Category | Technologies |
|---|---|
| Cloud | Google Cloud Platform |
| Infrastructure | GKE Autopilot, Terraform |
| Containerization | Docker, Kubernetes, NGINX |
| Monitoring | Google Cloud Monitoring |
| Logging | Google Cloud Logging |
| CI/CD | GitHub Actions, Artifact Registry |
| Security | IAM, Workload Identity Federation, RBAC |
| Networking | Ingress, Application Load Balancer |

## Architecture

    GitHub Repository
           |
    GitHub Actions
           |
    Workload Identity Federation
           |
    Docker Build
           |
    Artifact Registry
           |
    GKE Cluster
           |
    Kubernetes Application

    External Users
           |
    Application Load Balancer
           |
    Application Pods

    Observability:
    Cloud Monitoring + Cloud Logging

## Key Implementations

- Deployed a containerized application on GKE.
- Configured Kubernetes health probes and resource limits.
- Implemented CPU-based Horizontal Pod Autoscaling.
- Configured infrastructure and application dashboards.
- Created log-based metrics and alerting policies.
- Configured application availability SLOs.
- Developed Terraform infrastructure configurations.
- Automated Docker builds and GKE deployments.
- Implemented keyless CI/CD authentication.
- Validated Kubernetes rollback and application recovery.
- Created incident reports and operational runbooks.

## Validated Results

| Test | Result |
|---|---|
| Application Deployment | Successful |
| Application Availability Check | HTTP 200 |
| Horizontal Autoscaling | 2 to 4 replicas |
| CPU During Load Testing | 80% |
| Availability SLO Target | 99.9% |
| Automated CI/CD Release | 1m 39s |
| Kubernetes Rollback | Successful |
| Final Application Replicas | 2/2 Ready |

## Project Documentation

- [System Architecture Diagram](architecture/README.md)

- [CI/CD Implementation](cicd/README.md)
- [Pipeline Architecture](cicd/pipeline-architecture.md)
- [Security and Authentication](cicd/workload-identity-federation.md)
- [Artifact Registry](cicd/artifact-registry.md)
- [Deployment Strategy](cicd/deployment-strategy.md)
- [Rollback Runbook](cicd/rollback-runbook.md)
- [Validation Results](cicd/validation-results.md)
- [Incident Recovery and RCA](incidents/pod-failure-recovery.md)
- [Terraform Configuration](terraform/)
- [Kubernetes Configuration](kubernetes/)

## Project Limitations

This is a production-inspired SRE lab.

Terraform provisioning, alert notification verification,
and additional security hardening remain future work.

Rollback testing was a controlled simulation.
Continuous availability during rollback was not measured.

## Conclusion

This project demonstrates practical experience in
cloud-native infrastructure, observability, automation,
incident management, and application reliability.
