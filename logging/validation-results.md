# GKE Observability Testing and Validation Report

## 1. Executive Summary

Conducted hands-on observability and reliability testing
for an NGINX application deployed on Google Kubernetes
Engine (GKE) Autopilot.

The validation focused on centralized logging, application
error detection, infrastructure observability, automated
alerting, and application recovery.

## 2. Test Environment

| Component | Configuration |
|---|---|
| Cloud Platform | Google Cloud Platform |
| Kubernetes Platform | GKE Autopilot |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Application | sre-demo-app |
| Container | nginx |
| Baseline Replicas | 2 |
| Monitoring | Google Cloud Monitoring |
| Logging | Google Cloud Logging |
| Test Date | November 24, 2026 |

## 3. Validation Objectives

- Verify centralized Kubernetes application logging.
- Validate application-specific log filtering.
- Reduce routine health check noise during investigation.
- Detect HTTP client and server errors.
- Convert application logs into operational metrics.
- Integrate custom metrics with monitoring dashboards.
- Configure automated alert policies.
- Verify load balancer access logging.
- Validate application health following failure testing.

## 4. Application Logging Validation

Status: PASSED

Application logs were successfully retrieved from
both NGINX application pods using kubectl.

Observed application pods:

- sre-demo-app-c77dd45d9-265sx
- sre-demo-app-c77dd45d9-wcxld

Both pods generated successful HTTP 200 responses
for Google Load Balancer health checks and Kubernetes
health probes.

## 5. Centralized Cloud Logging Validation

Status: PASSED

Application logs were successfully retrieved through
Google Cloud Logs Explorer.

Filtering was implemented using cluster, namespace,
container, and dynamic application pod identifiers.

The implementation supports continued application
visibility when Kubernetes replaces or scales pods.

## 6. Health Check Noise Filtering

Status: PASSED

Routine health check messages were excluded from
application troubleshooting queries.

| Observation | Log Entries |
|---|---|
| Initial Application Log Query | 5529 |
| Filtered Application Log Query | 2031 |
| Approximate Difference | 63.3% |

The observations were collected during different
rolling time windows.

The percentage represents an approximate comparison,
not a controlled measurement of alert noise reduction
or logging ingestion cost savings.

## 7. HTTP 4xx Error Detection

Status: PASSED

Controlled HTTP 404 requests were generated using
a nonexistent application endpoint.

Observed results:

- HTTP 404 responses generated successfully.
- Matching application logs identified.
- Custom HTTP 4xx counter metric created.
- Metric spike observed in Cloud Monitoring.
- Approximate peak rate of 0.33 errors per second.
- Dashboard integration completed.
- Load balancer HTTP 404 logs identified.

## 8. HTTP 5xx Error Detection

Status: TEST PERFORMED - EVIDENCE PARTIAL

A temporary NGINX configuration was introduced
to generate HTTP 500 responses on a separate port.

The test used Kubernetes port forwarding to avoid
changing the primary external application endpoint.

Implementation activities:

- HTTP 5xx log-based metric created.
- HTTP 5xx monitoring widget configured.
- Controlled HTTP 500 testing performed.
- HTTP 5xx alert policy configured.
- Temporary test configuration removed.

Detailed metric spike evidence and alert incident
notification results require final verification.

The test bypassed the external load balancer.

## 9. Load Balancer Access Logging

Status: PASSED

The GKE-managed backend service was inspected
to verify access logging configuration.

| Configuration | Observed Result |
|---|---|
| Logging Enabled | true |
| Sampling Rate | 1.0 |
| Request Sampling | 100% |
| Backend Zones | 2 |
| Backend Zone 1 | us-east4-a |
| Backend Zone 2 | us-east4-c |

Initial observation:

- 90 access log entries within a 15-minute window.
- Successful HTTP requests identified.
- Request latency information available.
- HTTP response status codes available.
- Request and response metadata available.

## 10. Load Balancer HTTP Error Validation

Status: PASSED FOR HTTP 4xx

External HTTP 404 requests were generated through
the application load balancer.

A subsequent Cloud Logging query returned 158
matching HTTP 4xx entries.

This count includes requests within the selected
observation window and is not exclusively associated
with the final controlled test.

Positive load balancer HTTP 5xx and backend
connection failure tests remain outstanding.

## 11. Dashboard Integration

Status: IMPLEMENTED

Dashboard: GKE SRE - Production Overview

Monitoring capabilities include:

- Kubernetes node CPU utilization.
- Kubernetes node memory utilization.
- Kubernetes node storage monitoring.
- Container CPU utilization.
- Container memory utilization.
- Container restart monitoring.
- Application request traffic.
- Application response latency.
- HTTP client and server error monitoring.
- Application uptime monitoring.
- Service-level objective monitoring.
- Error budget monitoring.
- Custom log-based HTTP error metrics.

Final widget organization, metric definitions,
and available replica monitoring require review.

## 12. Automated Alerting Validation

Status: PARTIALLY VALIDATED

| Alert Policy | Implementation Status |
|---|---|
| High HTTP 4xx Error Rate | Created |
| High HTTP 5xx Error Rate | Created |
| Application Down | Created |
| HTTP 4xx Metric Spike | Observed |
| Final Alert Configuration Review | Pending |
| Incident Creation Verification | Pending |
| Email Notification Delivery | Pending |
| Incident Closure Verification | Pending |
| Recovery Notification Delivery | Pending |

Alert policy creation does not independently
establish successful end-to-end notification delivery.

## 13. Application Recovery Validation

Status: PASSED

Following controlled HTTP 500 testing:

- Temporary NGINX test configuration removed.
- NGINX configuration syntax validated.
- NGINX configuration successfully reloaded.
- External application endpoint returned HTTP 200.
- Both application pods remained Running.
- Zero container restarts observed.

Subsequent application logs continued to show
successful Google Load Balancer health checks
and Kubernetes health probe responses.

## 14. Reliability Engineering Validation

Previous reliability testing demonstrated:

- Kubernetes deployment with two baseline replicas.
- Application health probes.
- Automatic Kubernetes pod replacement.
- Application availability during sampled requests.
- Horizontal Pod Autoscaling.
- Automatic scaling from two to four replicas.
- CPU utilization reaching 80% during load testing.
- Post-incident investigation and RCA documentation.

No failed HTTP requests were observed in the
recorded pod replacement test samples.

This does not establish a guarantee of zero downtime.

## 15. Validation Summary

| Validation Area | Status |
|---|---|
| Kubernetes Application Logging | Passed |
| Centralized Cloud Logging | Passed |
| Dynamic Pod Filtering | Passed |
| Health Check Noise Filtering | Passed |
| HTTP 4xx Error Detection | Passed |
| HTTP 5xx Error Testing | Partial Evidence |
| Log-Based Metrics | Implemented |
| Dashboard Integration | Implemented |
| Load Balancer Access Logging | Passed |
| Load Balancer HTTP 4xx Detection | Passed |
| Load Balancer HTTP 5xx Detection | Pending |
| Automated Alert Policies | Implemented |
| End-to-End Notifications | Pending |
| Application Recovery | Passed |
| Pod Replacement | Passed |
| Horizontal Pod Autoscaling | Passed |

## 16. Outstanding Acceptance Checks

- Verify final HTTP 4xx alert aggregation and severity.
- Capture detailed HTTP 5xx metric validation evidence.
- Verify alert incident creation.
- Verify email notification delivery.
- Verify incident closure and recovery notifications.
- Validate load balancer HTTP 5xx monitoring.
- Validate backend connection failure monitoring.
- Review available replica dashboard metrics.
- Verify SLO metric filtering and error budget units.
- Capture supporting screenshots for the portfolio.

## 17. Production Readiness Recommendations

- Implement secure HTTPS communication.
- Apply least-privilege IAM permissions.
- Manage observability through infrastructure as code.
- Implement structured application logging.
- Establish appropriate log retention policies.
- Implement SLO-based burn-rate alerting.
- Establish application ownership and escalation paths.
- Integrate enterprise incident management platforms.
- Periodically validate failure and recovery scenarios.
- Monitor infrastructure and observability costs.

## 18. Engineering Outcome

The project demonstrates hands-on experience with
Google Kubernetes Engine, centralized Cloud Logging,
custom log-based metrics, Cloud Monitoring dashboards,
automated alert policies, load balancer observability,
incident investigation, and application recovery.

The implementation provides a practical foundation
for cloud-native Site Reliability Engineering and
production-oriented observability practices.

This environment is a demonstration project and
should not be represented as a fully validated
enterprise production environment.
