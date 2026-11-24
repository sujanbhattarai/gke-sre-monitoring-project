# Centralized Kubernetes Application Logging

## Executive Summary

Implemented centralized application logging for an NGINX
workload deployed on Google Kubernetes Engine (GKE)
Autopilot, enabling proactive error detection, application
observability, and operational troubleshooting.

## Environment Configuration

| Component | Configuration |
|---|---|
| Platform | Google Cloud Platform |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Deployment | sre-demo-app |
| Container | nginx |
| Replicas | 2 |
| Logging | Google Cloud Logging |

## Observability Architecture

NGINX Pods → GKE Logging Collection → Cloud Logging
→ Log-Based Metrics → Cloud Monitoring → Alert Policies

## Implementation

- Centralized Kubernetes container logs.
- Configured dynamic application pod filtering.
- Implemented health check noise filtering.
- Classified HTTP success and error responses.
- Integrated application logs with custom metrics.
- Configured automated error monitoring.
- Performed controlled application failure testing.

## Application Log Filter

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"

## Health Check Noise Filtering

    NOT textPayload:"GoogleHC"
    NOT textPayload:"kube-probe"
    NOT textPayload:"GoogleStackdriverMonitoring-UptimeChecks"

These filters improve troubleshooting visibility without
changing log ingestion or retention.

## Operational Troubleshooting

1. Verify Kubernetes pod health and availability.
2. Review container logs and HTTP response codes.
3. Filter application logs in Cloud Logging.
4. Identify recurring errors and abnormal behavior.
5. Correlate findings with monitoring dashboards.
6. Investigate deployment and configuration changes.
7. Validate application recovery.

## Validation Evidence

- Both application pods generated NGINX access logs.
- Google Load Balancer health checks returned HTTP 200.
- Kubernetes health probes returned HTTP 200.
- HTTP 4xx metric spikes were observed.
- HTTP 5xx monitoring and controlled testing were performed.
- Temporary failure configuration was removed successfully.
- Both pods remained Running with zero container restarts.
- Application availability was verified after cleanup.

## Production Recommendations

- Implement structured JSON logging.
- Establish appropriate log retention policies.
- Enforce least-privilege IAM access.
- Protect sensitive information in application logs.
- Implement request correlation identifiers.
- Monitor logging ingestion and retention costs.
- Manage observability configurations through version control.

## Engineering Outcome

Established centralized application observability to
support proactive monitoring, incident investigation,
service reliability, and operational troubleshooting.
