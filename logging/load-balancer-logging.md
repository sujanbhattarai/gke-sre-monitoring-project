# GKE Load Balancer Access Logging and Observability

## 1. Executive Summary

Implemented and validated infrastructure-level request
observability using Google Cloud Application Load Balancer
access logs for an NGINX application deployed on Google
Kubernetes Engine (GKE).

The implementation provides visibility into external
HTTP requests, response status codes, request latency,
backend connectivity, and application availability.

## 2. Infrastructure Configuration

| Component | Configuration |
|---|---|
| Cloud Platform | Google Cloud Platform |
| Kubernetes Platform | GKE Autopilot |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Application | sre-demo-app |
| Ingress | sre-demo-ingress |
| Load Balancer | Google Cloud Application Load Balancer |
| Protocol | HTTP |
| Port | 80 |
| Backend Type | Network Endpoint Groups |
| Logging | Google Cloud Logging |
| Logging Status | Enabled |
| Sampling Rate | 100% |

## 3. Infrastructure Architecture

External Users
    |
Google Cloud Application Load Balancer
    |
Backend Service
    |
Network Endpoint Groups
    |
NGINX Application Pods

Observability Sources:

- Load balancer access logs.
- Kubernetes application logs.
- Cloud Monitoring infrastructure metrics.
- Custom application log-based metrics.
- Automated alert policies.

## 4. Multi-Zone Backend Architecture

The backend service uses Network Endpoint Groups
distributed across two availability zones.

| Backend Zone | Region |
|---|---|
| us-east4-a | us-east4 |
| us-east4-c | us-east4 |

This architecture supports traffic distribution
across application endpoints in multiple zones.

Multi-zone configuration alone does not establish
complete resilience against every zonal failure.

## 5. Backend Service Identification

Backend service:

    k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5

Infrastructure discovery commands:

    kubectl get ingress -n default

    kubectl describe ingress sre-demo-ingress -n default

    gcloud compute backend-services list --global

These commands provide visibility into ingress routing,
backend configuration, and infrastructure dependencies.

## 6. Access Logging Configuration

The existing GKE-managed backend service was inspected
to verify its logging configuration.

Observed configuration:

    logConfig:
      enable: true
      optionalMode: EXCLUDE_ALL_OPTIONAL
      sampleRate: 1.0

Logging was already enabled with 100% sampling.

No manual backend configuration changes were required.

For persistent configuration changes, a Kubernetes
BackendConfig should be considered instead of directly
modifying GKE-managed backend resources.

## 7. Centralized Load Balancer Log Query

The following Cloud Logging query isolates requests
associated with the application backend service.

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"

This filter provides application-specific visibility
into external requests processed by the load balancer.

## 8. HTTP Request Observability

| Log Field | Operational Purpose |
|---|---|
| httpRequest.status | HTTP response classification |
| httpRequest.latency | Request latency analysis |
| httpRequest.requestUrl | Affected request endpoint |
| httpRequest.requestMethod | HTTP request method |
| httpRequest.remoteIp | Request source identification |
| httpRequest.responseSize | Response payload size |
| jsonPayload.statusDetails | Request outcome analysis |

These fields support incident investigation,
performance troubleshooting, and request analysis.

## 9. HTTP Success Monitoring

Successful HTTP requests are identified using:

    httpRequest.status>=200
    httpRequest.status<300

Successful requests provide evidence of application
availability for the observed request samples.

## 10. HTTP Client Error Monitoring

HTTP client errors are identified using:

    httpRequest.status>=400
    httpRequest.status<500

This query supports investigation of invalid URLs,
authorization failures, routing issues, and rate limiting.

## 11. HTTP Server Error Monitoring

HTTP server errors are identified using:

    httpRequest.status>=500
    httpRequest.status<600

This query supports investigation of application
failures, unavailable backends, and gateway errors.

Positive load balancer HTTP 5xx validation remains
an outstanding acceptance check.

## 12. High-Latency Request Analysis

Requests exceeding the demonstration latency
threshold are identified using:

    httpRequest.latency>"0.2s"

The 200 millisecond threshold was selected for
demonstration and troubleshooting purposes.

Production latency thresholds should be established
using application requirements and historical data.

## 13. Backend Connectivity Troubleshooting

Backend connection failures can be investigated using:

    jsonPayload.statusDetails="failed_to_connect_to_backend"

Additional investigation should include:

- Kubernetes pod availability.
- Application readiness probes.
- Service endpoint configuration.
- Network Endpoint Group health.
- Backend service health checks.
- Recent deployment changes.
- Application and infrastructure dependencies.

## 14. Controlled HTTP Error Validation

External HTTP 404 errors were generated by requesting
a nonexistent application endpoint through the
Google Cloud Application Load Balancer.

The resulting requests were investigated through:

- Load balancer access logs.
- NGINX application logs.
- HTTP 4xx log-based metrics.
- Cloud Monitoring dashboards.

This demonstrated visibility at both infrastructure
and application layers.

## 15. Observed Validation Results

| Validation | Observed Result |
|---|---|
| Access Logging | Enabled |
| Request Sampling | 100% |
| Backend Zones | 2 |
| Initial Access Log Results | 90 entries |
| Initial Observation Window | 15 minutes |
| Matching HTTP 4xx Logs | 158 entries |
| Observed HTTP Error | 404 Not Found |
| Application Health After Cleanup | HTTP 200 OK |
| Application Pods After Cleanup | 2 Running |
| Container Restarts After Cleanup | 0 |

The 158 matching HTTP 4xx entries include requests
within the selected observation window and should
not be attributed solely to the final test execution.

## 16. Incident Investigation Runbook

1. Identify the affected application and endpoint.
2. Review load balancer HTTP response codes.
3. Determine whether failures are isolated or widespread.
4. Inspect request latency and status details.
5. Verify backend service and NEG health.
6. Review Kubernetes deployment availability.
7. Correlate findings with application logs.
8. Investigate recent deployments and changes.
9. Implement appropriate mitigation.
10. Validate successful external requests.
11. Confirm monitoring and incident recovery.
12. Document findings and corrective actions.

## 17. Application Versus Infrastructure Logging

| Application Logging | Load Balancer Logging |
|---|---|
| Container-level visibility | External request visibility |
| NGINX application errors | Routing and backend errors |
| Application HTTP responses | Load balancer HTTP responses |
| Pod-specific investigation | Infrastructure investigation |
| Application processing details | Request latency and status details |

Both logging sources provide complementary
observability for incident investigation.

## 18. Operational Limitations

- Port-forwarded HTTP 500 tests bypass the load balancer.
- Application logs may not capture load balancer failures.
- Log ingestion can introduce processing delays.
- Sampling configuration affects request visibility.
- High logging volume can increase operational costs.
- Individual successful requests do not prove continuous uptime.
- Backend connection failure simulation remains unverified.

## 19. Production Recommendations

- Establish appropriate access log sampling policies.
- Configure latency and availability SLOs.
- Monitor HTTP error ratios relative to traffic volume.
- Implement secure HTTPS communication.
- Protect sensitive request information.
- Configure appropriate log retention policies.
- Establish application and infrastructure ownership.
- Implement SLO-based alerting.
- Manage backend logging through version-controlled configuration.
- Periodically validate backend failure and recovery scenarios.

## 20. Engineering Outcome

Established infrastructure-level request observability
through Google Cloud Application Load Balancer access
logging and centralized Cloud Logging.

The implementation supports end-to-end troubleshooting,
application availability analysis, HTTP error detection,
performance investigation, and proactive reliability
engineering across Kubernetes and cloud infrastructure.
