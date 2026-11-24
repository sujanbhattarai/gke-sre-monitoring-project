# Automated Alerting and Incident Response

## 1. Executive Summary

Implemented application-level alert policies using
Google Cloud Monitoring and custom log-based metrics
to support proactive incident detection, operational
visibility, and service reliability.

## 2. Alerting Architecture

NGINX Application Pods
    -> Google Cloud Logging
    -> Log-Based Metrics
    -> Cloud Monitoring Alert Policies
    -> Incident Creation
    -> Notification Channels
    -> Incident Investigation and Recovery

## 3. Alert Policy Inventory

| Alert Policy | Target Severity | Demo Threshold |
|---|---|---|
| GKE Application - High HTTP 4xx Error Rate | Warning | 0.2 errors/sec |
| GKE Application - High HTTP 5xx Error Rate | Error | 0.1 errors/sec |

## 4. HTTP 4xx Alert Configuration

Policy Name: GKE Application - High HTTP 4xx Error Rate

Metric: gke_application_http_4xx_count

Purpose: Detect elevated client-side HTTP errors.

Target configuration:

- Resource type: Kubernetes Container
- Rolling window: 1 minute
- Alignment function: Rate
- Cross-series aggregation: Sum
- Group by: None
- Threshold position: Above threshold
- Threshold value: 0.2 errors per second
- Retest window: 1 minute
- Severity: Warning

Final aggregation, severity, and notification settings
require configuration verification.

## 5. HTTP 5xx Alert Configuration

Policy Name: GKE Application - High HTTP 5xx Error Rate

Metric: gke_application_http_5xx_count

Purpose: Detect elevated server-side HTTP errors.

Configured design:

- Resource type: Kubernetes Container
- Rolling window: 1 minute
- Alignment function: Rate
- Cross-series aggregation: Sum
- Group by: None
- Threshold position: Above threshold
- Threshold value: 0.1 errors per second
- Retest window: 1 minute
- Severity: Error

## 6. Alert Threshold Strategy

The HTTP 4xx threshold represents approximately
12 errors per minute.

The HTTP 5xx threshold represents approximately
6 errors per minute.

These thresholds were selected for controlled
demonstration and alert validation.

Production thresholds should be established using
historical traffic, business impact, error ratios,
service-level objectives, and error budget consumption.

## 7. Notification Strategy

The notification design includes:

- Email notification channels.
- Incident opening notifications.
- Incident closure notifications.
- Descriptive notification subject lines.
- Alert severity classification.
- Application ownership metadata.
- Operational troubleshooting documentation.

End-to-end email delivery and recovery notifications
require final verification.

## 8. Alert Policy Metadata

Recommended policy labels:

| Key | Value |
|---|---|
| environment | demo |
| application | sre-demo-app |
| team | sre |
| platform | gke |
| category | application |
| component | nginx |
| cluster | cluster1 |
| namespace | default |
| managed_by | sre |

Policy labels support alert organization,
ownership identification, and incident routing.

## 9. Incident Management Lifecycle

1. Application errors are generated.
2. Cloud Logging captures matching log entries.
3. Log-based metrics record error events.
4. Cloud Monitoring evaluates alert conditions.
5. An incident opens when conditions are satisfied.
6. Configured notification channels notify responders.
7. SRE investigates the affected application.
8. Mitigation or corrective action is implemented.
9. Application recovery is validated.
10. Incident closure is confirmed.
11. Root cause and corrective actions are documented.

## 10. HTTP 4xx Troubleshooting Runbook

### Potential Causes

- Invalid application URLs.
- Authentication failures.
- Authorization failures.
- Incorrect client requests.
- Rate limiting.
- Application routing configuration.

### Investigation Procedure

1. Review HTTP 4xx logs in Cloud Logging.
2. Identify affected request URLs and status codes.
3. Determine whether errors are isolated or widespread.
4. Review application and load balancer logs.
5. Check recent application configuration changes.
6. Determine whether escalation is necessary.
7. Validate successful requests after mitigation.

Routine client errors should not automatically
trigger critical production incident escalation.

## 11. HTTP 5xx Troubleshooting Runbook

### Potential Causes

- Application processing failures.
- Backend service unavailability.
- Resource exhaustion.
- Application configuration errors.
- Deployment failures.
- Dependency connectivity issues.

### Investigation Procedure

1. Review HTTP 5xx logs in Cloud Logging.
2. Identify affected pods and request endpoints.
3. Verify Kubernetes deployment availability.
4. Review pod restart counts and resource utilization.
5. Inspect recent deployment and configuration changes.
6. Check load balancer backend health.
7. Investigate application dependencies.
8. Implement mitigation or rollback if required.
9. Validate application availability.
10. Confirm incident recovery.

### Kubernetes Diagnostic Commands

    kubectl get pods -n default -l app=sre-demo-app

    kubectl get deployment sre-demo-app -n default

    kubectl logs -n default -l app=sre-demo-app --tail=50

    kubectl get events -n default --sort-by=.lastTimestamp

    kubectl top pods -n default

    kubectl get ingress -n default

## 12. Escalation Strategy

Escalate application processing failures to the
application engineering team.

Escalate Kubernetes infrastructure, networking,
or backend connectivity failures to the platform team.

Coordinate major incident response when widespread
service degradation or business impact is identified.

Maintain clear communication regarding incident
impact, investigation progress, mitigation, and recovery.

## 13. Recovery Criteria

- Application health checks are successful.
- Kubernetes deployment replicas are available.
- HTTP error rates return to acceptable levels.
- Application endpoints return successful responses.
- Monitoring dashboards indicate recovery.
- Alert incident closure is confirmed.
- Recovery notifications are verified.

Missing metric data must not automatically be
interpreted as successful application recovery.

## 14. Validation Evidence

- HTTP 4xx log-based metric created.
- HTTP 5xx log-based metric created.
- Application error alert policies created.
- HTTP 404 metric spike observed.
- Controlled HTTP 500 testing performed.
- Temporary NGINX test configuration removed.
- NGINX configuration validation successful.
- External application returned HTTP 200 OK.
- Both application pods remained Running.
- Zero container restarts observed after cleanup.

## 15. Outstanding Acceptance Checks

- Verify final HTTP 4xx alert configuration.
- Confirm incident creation for both alert policies.
- Confirm email notification delivery.
- Confirm automatic incident closure.
- Confirm recovery notification delivery.

## 16. Production Recommendations

- Implement SLO-based alerting.
- Configure multi-window error budget burn-rate alerts.
- Integrate PagerDuty or enterprise incident platforms.
- Establish application ownership and escalation policies.
- Reduce unnecessary alert noise.
- Implement actionable alert documentation.
- Manage alert policies through infrastructure as code.
- Periodically validate notification channels.
- Review alert effectiveness after production incidents.

## 17. Engineering Outcome

Established application-level automated alerting
and documented operational response procedures
to support proactive incident detection, effective
troubleshooting, and reliable service operations.
