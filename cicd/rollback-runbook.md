# Kubernetes Application Rollback Runbook

## 1. Purpose

This runbook provides operational procedures for
identifying deployment failures, restoring previous
application versions, and validating application
recovery on Google Kubernetes Engine.

## 2. Application Information

| Component | Configuration |
|---|---|
| Platform | Google Kubernetes Engine |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Deployment | sre-demo-app |
| Container | nginx |
| Container Registry | Google Artifact Registry |
| Baseline Replicas | 2 |
| Deployment Strategy | RollingUpdate |

## 3. Rollback Triggers

A rollback should be considered when a new release
introduces significant application reliability issues.

Potential rollback triggers include:

- Application availability degradation.
- Increased HTTP 5xx error rates.
- Failed application health checks.
- Increased application response latency.
- CrashLoopBackOff errors.
- ImagePullBackOff errors.
- Failed Kubernetes rolling updates.
- Significant SLO degradation.
- Application functionality failures.

The decision should consider customer impact,
incident severity, and recovery options.

## 4. Initial Incident Assessment

Before performing a rollback:

1. Identify the affected application.
2. Review the latest deployment.
3. Assess application availability.
4. Review monitoring dashboards.
5. Inspect application logs.
6. Identify the previous stable release.
7. Coordinate with relevant engineering teams.

## 5. Check Deployment Health

    kubectl get deployment sre-demo-app -n default

Check application pods:

    kubectl get pods -n default -l app=sre-demo-app

Inspect deployment configuration:

    kubectl describe deployment sre-demo-app -n default

Review recent Kubernetes events:

    kubectl get events -n default \
      --sort-by=.lastTimestamp

## 6. Identify Current Container Image

    kubectl get deployment sre-demo-app -n default \
      -o=jsonpath='{.spec.template.spec.containers[*].image}'

Record the current container image before
performing any deployment changes.

## 7. Review Deployment History

    kubectl rollout history deployment/sre-demo-app \
      -n default

Inspect the current and previous revisions.

    kubectl rollout history deployment/sre-demo-app \
      -n default --revision=REVISION_NUMBER

Confirm that the selected rollback revision
contains a previously validated container image.

Revision numbers change over time and should
not be assumed without verification.

## 8. Execute Rollback

After identifying the previous stable revision,
execute the following command:

    kubectl rollout undo deployment/sre-demo-app \
      -n default --to-revision=REVISION_NUMBER

Replace REVISION_NUMBER with the verified
previous stable deployment revision.

This operation changes the running application.

## 9. Monitor Rollback Progress

    kubectl rollout status deployment/sre-demo-app \
      -n default --timeout=300s

Expected successful result:

    deployment "sre-demo-app" successfully rolled out

Messages indicating that old replicas are pending
termination can occur during normal rolling updates.

If the rollback fails or exceeds the timeout,
inspect pod status, deployment events, and logs.

## 10. Validate Application Recovery

Check deployment availability:

    kubectl get deployment sre-demo-app -n default

Check application pods:

    kubectl get pods -n default -l app=sre-demo-app

Verify the restored image:

    kubectl get deployment sre-demo-app -n default \
      -o=jsonpath='{.spec.template.spec.containers[*].image}'

Verify application HTTP response:

    curl -I http://APPLICATION_ENDPOINT

Verify application content:

    curl -s http://APPLICATION_ENDPOINT \
      | grep "Application Status"

Confirm that the restored application version
matches the expected previous release.

## 11. Monitoring and Observability

Following a rollback, review:

- Application availability.
- HTTP request traffic.
- HTTP 4xx and 5xx error rates.
- Application response latency.
- Container CPU utilization.
- Container memory utilization.
- Container restart counts.
- Kubernetes replica availability.
- Application logs.
- Load balancer backend health.
- SLO compliance and error budget.

Continue monitoring until application stability
has been established.

## 12. Controlled Rollback Simulation

A controlled rollback simulation was performed
as part of the GKE SRE monitoring project.

The test did not involve an actual production
application failure.

Initial release:

    Version 1
    Git commit: a5ea553

New release:

    Version 2
    Git commit: 2c80e41

Both releases were successfully deployed
using the automated GitHub Actions pipeline.

## 13. Verified Deployment Revisions

During the controlled rollback test:

| Revision | Application Version | Git Commit |
|---|---|---|
| 5 | Version 1 | a5ea553 |
| 6 | Version 2 | 2c80e41 |

The container images associated with both
revisions were verified before rollback.

These revision numbers are historical test
values and may differ during future releases.

## 14. Executed Rollback Command

The following command was used during the test:

    kubectl rollout undo deployment/sre-demo-app \
      -n default --to-revision=5

Kubernetes successfully restored Version 1.

The previous container image was reused
without rebuilding the application.

## 15. Rollback Validation Results

| Validation | Observed Result |
|---|---|
| Kubernetes rollout | Successful |
| Restored application | Version 1 |
| Restored image tag | a5ea553 |
| Ready application pods | 2/2 |
| Pod status | Running |
| Container restarts | 0 |
| Application content | Healthy |

The external application returned:

    Application Status: Healthy

This confirmed that the previous application
version was successfully restored.

## 16. Latest Version Restoration

After completing rollback validation,
Version 2 was restored using kubectl set image.

The full Version 2 image tag was:

    2c80e41fefb674acbb6732222ebbc77f3e23966e

The application subsequently returned:

    Application Status: Healthy - Version 2

Final deployment validation:

| Metric | Result |
|---|---|
| Ready Replicas | 2/2 |
| Up-to-date Replicas | 2 |
| Available Replicas | 2 |
| Application Version | Version 2 |
| Application Status | Healthy |

## 17. Source Code and Deployment Consistency

A manual Kubernetes rollback does not revert
the application source code in GitHub.

Subsequent eligible GitHub Actions executions
can redeploy the latest source code.

During an actual incident, engineering teams
should coordinate deployment controls and
source code changes to prevent unintended
redeployment of a faulty release.

A Git revert followed by a validated pipeline
execution may be appropriate for a persistent
source-level rollback.

## 18. Incident Communication

Recommended operational communication includes:

- Application name and affected environment.
- Incident severity and customer impact.
- Current and previous release identifiers.
- Rollback decision and justification.
- Recovery actions performed.
- Application validation results.
- Current monitoring status.
- Follow-up engineering actions.

## 19. Post-Incident Activities

Following an actual deployment incident:

1. Document the incident timeline.
2. Identify the root cause.
3. Record recovery actions.
4. Measure recovery duration.
5. Review monitoring and alerting effectiveness.
6. Identify preventive engineering improvements.
7. Update operational runbooks.
8. Conduct a blameless post-incident review.

## 20. Test Limitations

The rollback was a controlled simulation.

Continuous application availability was not
measured throughout the rollback.

An exact recovery duration was not recorded.

Therefore, the test does not establish
zero downtime or a measured MTTR improvement.

Automatic rollback is not currently implemented
in the GitHub Actions deployment workflow.

## 21. Future Improvements

- Automated rollback on deployment failure.
- Continuous synthetic availability testing.
- Deployment-specific monitoring dashboards.
- Automated release health evaluation.
- Canary deployment strategies.
- Automated incident notifications.
- Deployment approval controls.
- Release-specific application health checks.

## 22. Conclusion

The controlled rollback test successfully
demonstrated Kubernetes deployment recovery,
previous image restoration, application health
validation, and latest release restoration.

The runbook provides a repeatable operational
procedure for application release recovery
and Site Reliability Engineering activities.
