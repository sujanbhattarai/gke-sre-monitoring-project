# GKE SRE Troubleshooting Query Library

## 1. Executive Summary

Developed a reusable troubleshooting query library
for Google Kubernetes Engine, Google Cloud Logging,
and Google Cloud Application Load Balancer.

The query library supports application monitoring,
incident investigation, HTTP error analysis,
performance troubleshooting, and operational efficiency.

## 2. Environment

| Component | Configuration |
|---|---|
| Platform | Google Cloud Platform |
| Cluster | cluster1 |
| Region | us-east4 |
| Namespace | default |
| Application | sre-demo-app |
| Container | nginx |
| Logging Platform | Google Cloud Logging |

## 3. Application Log Queries

Execute the following queries in Google Cloud
Logs Explorer, not in the Cloud Shell terminal.

### Query 01 - All Application Logs

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"

Purpose:

Retrieve application logs across dynamically
created Kubernetes application pods.

### Query 02 - Exclude Routine Health Checks

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"
    NOT textPayload:"GoogleHC"
    NOT textPayload:"kube-probe"
    NOT textPayload:"GoogleStackdriverMonitoring-UptimeChecks"

Purpose:

Reduce routine health check noise during
application incident investigations.

### Query 03 - HTTP 2xx Success Responses

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"
    textPayload=~"\" 2[0-9]{2} "

Purpose:

Identify successful application requests and
support application recovery validation.

### Query 04 - HTTP 4xx Client Errors

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"
    textPayload=~"\" 4[0-9]{2} "

Purpose:

Investigate client errors, invalid endpoints,
authorization failures, and rate limiting.

### Query 05 - HTTP 5xx Server Errors

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.container_name="nginx"
    resource.labels.pod_name=~"^sre-demo-app-.*"
    textPayload=~"\" 5[0-9]{2} "

Purpose:

Investigate application failures and server-side
HTTP errors recorded in NGINX access logs.

### Query 06 - Application Error Severity

    resource.type="k8s_container"
    resource.labels.cluster_name="cluster1"
    resource.labels.namespace_name="default"
    resource.labels.pod_name=~"^sre-demo-app-.*"
    severity>=ERROR

Purpose:

Identify log entries classified as errors.

Note: HTTP errors can appear in INFO-level access
logs. Severity filtering alone is insufficient
for HTTP error detection.

## 4. Load Balancer Log Queries

### Query 07 - All Load Balancer Access Logs

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"

Purpose:

Retrieve external request logs associated with
the application backend service.

### Query 08 - Load Balancer HTTP 2xx

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"
    httpRequest.status>=200
    httpRequest.status<300

Purpose:

Validate successful external application requests.

### Query 09 - Load Balancer HTTP 4xx

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"
    httpRequest.status>=400
    httpRequest.status<500

Purpose:

Investigate external client-side HTTP errors.

### Query 10 - Load Balancer HTTP 5xx

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"
    httpRequest.status>=500
    httpRequest.status<600

Purpose:

Investigate server errors, unavailable backends,
and gateway failures.

### Query 11 - High-Latency Requests

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"
    httpRequest.latency>"0.2s"

Purpose:

Identify requests exceeding the demonstration
latency threshold of 200 milliseconds.

### Query 12 - Backend Connection Failures

    resource.type="http_load_balancer"
    resource.labels.backend_service_name="k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5"
    jsonPayload.statusDetails="failed_to_connect_to_backend"

Purpose:

Investigate load balancer failures associated
with backend connection establishment.

## 5. Kubernetes Diagnostic Command Library

Execute the following commands in Cloud Shell
when performing Kubernetes troubleshooting.

### Pod Health

    kubectl get pods -n default -l app=sre-demo-app

### Deployment Availability

    kubectl get deployment sre-demo-app -n default

### Application Logs

    kubectl logs -n default -l app=sre-demo-app --tail=50 --prefix=true

### Kubernetes Events

    kubectl get events -n default --sort-by=.lastTimestamp

### Container Resource Utilization

    kubectl top pods -n default

### Node Resource Utilization

    kubectl top nodes

### Service Configuration

    kubectl get services -n default

### Ingress Configuration

    kubectl describe ingress sre-demo-ingress -n default

### Horizontal Pod Autoscaling

    kubectl get hpa -n default

### Deployment Rollout History

    kubectl rollout history deployment/sre-demo-app -n default

### Deployment Rollout Status

    kubectl rollout status deployment/sre-demo-app -n default

### Application Availability

    curl -I http://136.82.221.246

The external IP address may change if the
load balancer is recreated.

## 6. Infrastructure Diagnostic Commands

### List Backend Services

    gcloud compute backend-services list --global

### Verify Backend Health

    gcloud compute backend-services get-health k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5 --global

### Verify Access Logging Configuration

    gcloud compute backend-services describe k8s1-e32eaeeb-default-sre-demo-app-80-6b2f8bb5 --global --format="yaml(name,logConfig)"

## 7. Incident Troubleshooting Matrix

| Symptom | Investigation |
|---|---|
| High HTTP 4xx | Application and load balancer 4xx logs |
| High HTTP 5xx | Application logs and backend health |
| High Latency | Load balancer latency and resource metrics |
| Pod Unavailable | Pod status, events, and deployment |
| Container Restarts | Pod description and previous logs |
| High CPU | Pod metrics, node metrics, and HPA |
| Backend Unhealthy | NEG health, readiness, and service endpoints |
| Deployment Failure | Rollout status, events, and logs |
| Application Down | Uptime checks, ingress, and backend health |

## 8. Recommended Incident Workflow

1. Review the alert and identify the affected service.
2. Determine the incident start time and scope.
3. Review application and infrastructure dashboards.
4. Investigate relevant Cloud Logging queries.
5. Verify Kubernetes workload health.
6. Review resource utilization and scaling behavior.
7. Investigate recent deployments and changes.
8. Identify potential root causes.
9. Implement appropriate mitigation.
10. Validate application recovery.
11. Confirm monitoring and incident closure.
12. Document findings and preventive actions.

## 9. Query Validation Status

Application logs, health check filtering, HTTP 4xx
detection, and load balancer access logging were
validated during the project.

Positive load balancer HTTP 5xx and backend connection
failure scenarios require additional validation.

The diagnostic command library includes recommended
commands for future incident investigations and does
not imply that every command was executed.

## 10. Production Recommendations

- Maintain a centralized troubleshooting query library.
- Standardize application and infrastructure labels.
- Implement structured application logging.
- Introduce request correlation identifiers.
- Maintain service-specific operational runbooks.
- Integrate troubleshooting links into alert policies.
- Review query effectiveness after incidents.
- Protect sensitive information in operational logs.

## 11. Engineering Outcome

Established a reusable troubleshooting knowledge base
supporting application observability, incident triage,
infrastructure diagnostics, root cause analysis,
and operational reliability across GKE workloads.
