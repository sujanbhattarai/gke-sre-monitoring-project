# Kubernetes Deployment Strategy and Application Reliability

## 1. Overview

This project implements a Kubernetes rolling update
deployment strategy on Google Kubernetes Engine.

The deployment architecture combines automated
application delivery, health probes, resource
management, autoscaling, and rollback capabilities.

## 2. Deployment Configuration

| Component | Configuration |
|---|---|
| Kubernetes Platform | GKE Autopilot |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Deployment | sre-demo-app |
| Container | nginx |
| Baseline Replicas | 2 |
| Deployment Strategy | RollingUpdate |
| Maximum Surge | 1 |
| Maximum Unavailable | 0 |
| Container Port | 80 |

## 3. Rolling Update Strategy

The application uses Kubernetes rolling updates
to gradually replace existing application pods
with pods running the new container image.

Deployment strategy:

    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxSurge: 1
        maxUnavailable: 0

The maximum surge configuration permits one
additional pod during a deployment.

The maximum unavailable configuration is
designed to maintain the desired number of
available replicas during rolling updates.

This configuration reduces deployment-related
availability risks but does not guarantee
zero downtime under all conditions.

## 4. Rolling Update Lifecycle

1. A new application image is published.
2. The Kubernetes deployment image is updated.
3. Kubernetes creates a new ReplicaSet.
4. New application pods are created.
5. Readiness probes evaluate application health.
6. Ready pods become eligible to receive traffic.
7. Previous application pods are terminated.
8. Kubernetes completes the rollout.

## 5. Readiness Probes

Readiness probes determine whether an application
container is ready to receive network traffic.

The application uses an HTTP readiness probe
against the root application endpoint.

Probe configuration:

    readinessProbe:
      httpGet:
        path: /
        port: 80

Unready pods are excluded from eligible Service
endpoints until readiness checks succeed.

## 6. Liveness Probes

Liveness probes detect unhealthy application
containers that may require a restart.

The application uses an HTTP liveness probe.

Probe configuration:

    livenessProbe:
      httpGet:
        path: /
        port: 80

Repeated liveness probe failures can cause
Kubernetes to restart the affected container.

Liveness and readiness probes serve different
operational purposes.

## 7. Resource Management

The application uses Kubernetes resource
requests and limits.

| Resource | Request | Limit |
|---|---|---|
| CPU | 100m | 250m |
| Memory | 103Mi | 128Mi |
| Ephemeral Storage | 1Gi | 1Gi |

These values reflect the observed deployment
configuration after GKE Autopilot adjustments.

Resource requests support scheduling and
autoscaling decisions.

Resource limits control container resource usage.

## 8. Horizontal Pod Autoscaling

Horizontal Pod Autoscaling is configured to
adjust application capacity based on CPU usage.

| Configuration | Value |
|---|---|
| Minimum Replicas | 2 |
| Maximum Replicas | 5 |
| Target CPU Utilization | 50% |

The autoscaler evaluates CPU utilization
relative to container CPU requests.

When utilization increases above the target,
the autoscaler can increase the replica count.

## 9. Autoscaling Validation

Application load testing was performed using
a Kubernetes-based traffic generator.

Observed results:

| Metric | Observed Result |
|---|---|
| Initial Replicas | 2 |
| Target CPU Utilization | 50% |
| Observed CPU Utilization | 80% |
| Scaled Replicas | 4 |
| Final Baseline Replicas | 2 |

The application successfully demonstrated
horizontal scaling under increased traffic.

The deployment subsequently returned to
its baseline replica count.

## 10. Automated Deployment

GitHub Actions publishes a versioned container
image and updates the Kubernetes deployment.

Deployment command:

    kubectl set image deployment/sre-demo-app \
      nginx=IMAGE_URI -n default

This updates the application image without
directly modifying the HPA-managed replica count.

The pipeline assumes the deployment and
supporting infrastructure already exist.

## 11. Deployment Verification

Monitor the rollout:

    kubectl rollout status deployment/sre-demo-app \
      -n default --timeout=300s

Inspect deployment availability:

    kubectl get deployment sre-demo-app -n default

Inspect application pods:

    kubectl get pods -n default -l app=sre-demo-app

Verify the deployed container image:

    kubectl get deployment sre-demo-app -n default \
      -o=jsonpath='{.spec.template.spec.containers[*].image}'

Verify external application accessibility:

    curl -I http://APPLICATION_ENDPOINT

## 12. Application Traffic Management

External application traffic is delivered
through a Google Cloud Application Load Balancer.

The Kubernetes Ingress and Service configuration
define the application backend.

Network Endpoint Groups provide pod-level
backend connectivity.

Traffic delivery path:

    External Client
           |
           v
    Google Cloud Application Load Balancer
           |
           v
    Network Endpoint Group
           |
           v
    Ready Application Pods

## 13. Deployment Failure Troubleshooting

Common deployment issues include:

- ImagePullBackOff
- ErrImagePull
- CrashLoopBackOff
- Readiness probe failures
- Liveness probe failures
- Insufficient resources
- Pod scheduling failures
- Incorrect container image versions
- Load balancer backend health failures

Recommended investigation commands:

    kubectl get pods -n default

    kubectl describe deployment sre-demo-app -n default

    kubectl describe pod POD_NAME -n default

    kubectl logs POD_NAME -n default

    kubectl logs POD_NAME -n default --previous

    kubectl get events -n default \
      --sort-by=.lastTimestamp

    kubectl get hpa -n default

## 14. Rollback Strategy

Kubernetes deployment history supports
restoration of previous application revisions.

Inspect deployment history:

    kubectl rollout history deployment/sre-demo-app \
      -n default

Inspect a specific revision:

    kubectl rollout history deployment/sre-demo-app \
      -n default --revision=REVISION_NUMBER

Restore a verified previous revision:

    kubectl rollout undo deployment/sre-demo-app \
      -n default --to-revision=REVISION_NUMBER

The previous revision must be verified before
performing a rollback.

## 15. Release Validation Results

| Validation | Result |
|---|---|
| Version 1 automated deployment | Passed |
| Version 2 automated deployment | Passed |
| Rolling update completion | Passed |
| Application content verification | Passed |
| Kubernetes rollback | Passed |
| Previous image restoration | Passed |
| Version 2 restoration | Passed |
| Final Ready Replicas | 2/2 |
| Final Available Replicas | 2 |

## 16. Reliability Benefits

The deployment architecture demonstrates:

- Controlled application releases.
- Health-based traffic eligibility.
- Automated container recovery.
- Dynamic application capacity.
- Versioned container deployments.
- Deployment history management.
- Operational rollback capabilities.
- Post-deployment health verification.

## 17. Operational Limitations

This implementation is a production-inspired
SRE demonstration environment.

Continuous availability during the rollback
was not measured.

The deployment strategy reduces availability
risks but does not independently guarantee
zero-downtime releases.

The current pipeline does not automatically
roll back failed deployments.

Manual Kubernetes rollbacks do not revert
application source code in GitHub.

Subsequent eligible GitHub workflow executions
can redeploy the application from GitHub.

## 18. Future Improvements

- Automated rollback on deployment failure.
- Canary deployment strategies.
- Blue-green deployment strategies.
- Pod Disruption Budgets.
- Continuous synthetic testing during releases.
- Deployment-specific SLO monitoring.
- Automated integration testing.
- Immutable container image digests.
- HTTPS application endpoints.
- Release-specific health verification.

These enhancements are proposed improvements
and have not been validated in this project.

## 19. Conclusion

The project demonstrates Kubernetes deployment
engineering using rolling updates, health probes,
resource management, horizontal autoscaling,
automated CI/CD, and rollback procedures.

These capabilities support reliable application
delivery and practical Site Reliability Engineering.
