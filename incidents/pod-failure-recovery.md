# Post-Incident Review (PIR) and Root Cause Analysis (RCA)
## Kubernetes Pod Failure and Automated Recovery

## 1. Incident Overview

| Field | Details |
|---|---|
| Incident ID | INC-GKE-001 |
| Incident Date | November 24, 2026 |
| Environment | GKE Demo Environment |
| Cloud Provider | Google Cloud Platform (GCP) |
| Cluster | cluster1 |
| Namespace | default |
| Application | sre-demo-app |
| Incident Type | Controlled Failure Simulation |
| Category | Kubernetes Reliability and Availability |
| Status | Resolved |
| Recovery Method | Automated Kubernetes Self-Healing |

## 2. Executive Summary

A controlled pod failure simulation was conducted within
Google Kubernetes Engine (GKE) to evaluate application
resilience, workload availability, and automated recovery
capabilities.

The exercise involved intentionally deleting application
pods individually while validating the Kubernetes
Deployment controller's ability to maintain the desired
number of replicas.

Kubernetes successfully created replacement pods without
requiring manual recovery. Continuous HTTP monitoring
through the external Application Load Balancer recorded
successful HTTP 200 responses throughout the observed
sampling period.

The deployment returned to its desired state with two
healthy and available replicas.

## 3. System Architecture

The application is hosted on Google Kubernetes Engine
and uses the following components:

- Google Kubernetes Engine (GKE)
- Kubernetes Deployment
- Kubernetes ReplicaSet
- NGINX application containers
- Kubernetes ClusterIP Service
- Kubernetes Ingress
- Google Cloud External Application Load Balancer
- Horizontal Pod Autoscaler (HPA)
- Google Cloud Monitoring
- Application uptime checks
- Service Level Objectives (SLOs)
- Error budget monitoring

Application traffic flow:

External Client
    |
Google Cloud Application Load Balancer
    |
Kubernetes Ingress Configuration
    |
Kubernetes Service / Backend Endpoints
    |
Application Pods

## 4. Objectives

The primary objectives of this reliability exercise were:

- Validate Kubernetes self-healing capabilities.
- Verify automatic replacement of deleted pods.
- Confirm Deployment and ReplicaSet reconciliation.
- Evaluate application resilience during pod termination.
- Monitor HTTP responses during the failure simulation.
- Verify restoration of the desired replica count.
- Assess the effectiveness of redundant application replicas.
- Document incident findings and operational improvements.

## 5. Pre-Incident System Health

Before initiating the failure simulation, the application
was operating with two healthy Kubernetes pods.

| Health Indicator | Initial Status |
|---|---|
| Desired Replicas | 2 |
| Ready Replicas | 2 |
| Available Replicas | 2 |
| Container Restarts | 0 |
| Application Status | Healthy |
| HTTP Response | 200 OK |
| Availability SLO Target | 99.9% |
| Observed SLO Compliance | 100% |
| Error Budget Remaining | 100% |

The application was accessible through the external
Application Load Balancer.

## 6. Incident Simulation

Two controlled pod deletion tests were performed.

### Test 1: Kubernetes Self-Healing

The first application pod was intentionally deleted:

sre-demo-app-c77dd45d9-dk2rb

Kubernetes automatically created the following replacement:

sre-demo-app-c77dd45d9-265sx

The replacement pod was observed in Running and Ready
status at eight seconds of pod age.

The exact end-to-end recovery duration was not measured.

### Test 2: Application Availability During Pod Failure

Continuous HTTP monitoring was initiated against the
external Application Load Balancer.

A second application pod was intentionally deleted:

sre-demo-app-c77dd45d9-h4tbk

Kubernetes automatically created the following replacement:

sre-demo-app-c77dd45d9-wcxld

HTTP responses were monitored during the exercise to
identify potential service interruptions.

All 28 visible HTTP response samples returned HTTP 200 OK.

## 7. Incident Timeline

All times are in UTC.

| Time | Event |
|---|---|
| Approximately 18:41 | First controlled pod deletion |
| Approximately 18:41 | Replacement pod observed Running |
| 18:41:54 | Application returned HTTP 200 OK |
| 18:43:02 | Start of visible continuous HTTP samples |
| Approximately 18:43 | Second controlled pod deletion |
| 18:43:30 | End of visible successful HTTP samples |
| Post-test | Both replacement pods verified Running |
| Post-test | Deployment confirmed 2/2 Ready |

Exact pod deletion and recovery timestamps were not
independently captured.

## 8. Root Cause Analysis

### Immediate Cause

Application pods were intentionally deleted as part of
a controlled reliability and failure simulation.

### Technical Analysis

Deleting an application pod caused the number of running
replicas to temporarily differ from the desired state
defined by the Kubernetes Deployment.

The ReplicaSet controller detected the missing replica
and initiated the creation of a replacement pod.

The Kubernetes scheduler assigned the replacement pod
to an available node, where the container was initialized
and evaluated by its configured health probes.

Once the replacement pod became ready, it was eligible
to receive application traffic.

### Contributing Factors to Successful Recovery

- Multiple application replicas
- Kubernetes Deployment and ReplicaSet controllers
- Automated workload scheduling
- Configured readiness and liveness probes
- Kubernetes service discovery
- External Application Load Balancer

No underlying infrastructure defect or application
software failure was identified during this exercise.

## 9. Impact Assessment

| Impact Category | Result |
|---|---|
| Application Accessibility | Available in observed samples |
| Observed HTTP Success Rate | 100% |
| Visible Successful HTTP Samples | 28 |
| Observed Failed HTTP Requests | 0 |
| Observed HTTP 5xx Errors | 0 |
| Observed Downtime | None |
| Final Deployment Availability | 2/2 |
| Manual Recovery Required | No |

No service interruption was observed in the collected
HTTP samples.

However, periodic HTTP sampling cannot guarantee that
no brief interruption occurred between requests.

This exercise was performed in a demo environment
and does not represent an actual customer-impacting
production incident.

## 10. Detection and Monitoring

The following monitoring capabilities were configured
within Google Cloud Monitoring:

- Kubernetes node CPU utilization
- Kubernetes node memory utilization
- Kubernetes container CPU usage
- Kubernetes container memory usage
- Container restart monitoring
- Application request traffic
- HTTP error monitoring
- Application uptime monitoring
- SLO compliance monitoring
- Error budget monitoring
- SLO burn rate alerting

Cloud Shell and kubectl were used to validate workload
health and application accessibility.

The Available Replicas dashboard metric did not return
data during configuration. Replica availability was
therefore verified directly using kubectl.

SLO alert notification delivery was not validated
as part of this exercise.

## 11. Recovery and Remediation

Kubernetes automatically performed the following
recovery operations:

1. Detected the missing application replica.
2. Initiated replacement pod creation.
3. Scheduled the replacement workload.
4. Started the application container.
5. Evaluated application readiness.
6. Restored the desired replica count.

No manual application restart, infrastructure restart,
or deployment rollback was required.

## 12. Post-Incident Validation

The following commands were used to verify application
health and successful recovery:

    kubectl get pods -n default -l app=sre-demo-app

    kubectl get deployment sre-demo-app -n default

### Final Pod Status

| Pod | Ready | Status | Restarts |
|---|---|---|---|
| sre-demo-app-c77dd45d9-265sx | 1/1 | Running | 0 |
| sre-demo-app-c77dd45d9-wcxld | 1/1 | Running | 0 |

### Final Deployment Status

| Metric | Result |
|---|---|
| Desired Replicas | 2 |
| Ready Replicas | 2/2 |
| Available Replicas | 2 |
| Up-to-Date Replicas | 2 |
| Container Restarts | 0 |
| Recovery Status | Successful |

## 13. What Went Well

- Kubernetes automatically replaced both deleted pods.
- The application returned to its desired state.
- No manual recovery intervention was required.
- All visible HTTP monitoring samples were successful.
- Multiple replicas supported application resilience.
- Monitoring and Kubernetes commands provided
  visibility into application and workload health.

## 14. Areas for Improvement

- Capture exact failure and recovery timestamps.
- Automate the collection of incident evidence.
- Resolve the Available Replicas dashboard metric.
- Validate SLO burn rate alert notifications.
- Conduct longer-duration availability testing.
- Implement automated log-based incident detection.
- Test resilience under increased application traffic.
- Evaluate application behavior during node failure.

## 15. Preventive Actions and Recommendations

| Action Item | Priority | Status |
|---|---|---|
| Maintain multiple application replicas | High | Implemented |
| Configure readiness and liveness probes | High | Implemented |
| Implement application uptime monitoring | High | Implemented |
| Configure SLO and error budget monitoring | High | Implemented |
| Configure SLO burn rate alerting | High | Configured |
| Validate alert notification delivery | High | Pending |
| Resolve replica availability dashboard metric | Medium | Pending |
| Automate recovery time measurement | Medium | Planned |
| Evaluate Pod Disruption Budget | Medium | Planned |
| Implement log-based alerting | Medium | Planned |
| Conduct additional resilience testing | Medium | Planned |

## 16. Lessons Learned

- Kubernetes controllers continuously reconcile
  workloads toward their desired state.
- Multiple replicas reduce the risk of service
  interruption during individual pod failures.
- Readiness probes help prevent traffic from reaching
  application containers that are not ready.
- Infrastructure health and application availability
  should be monitored independently.
- Successful pod recovery does not automatically
  guarantee uninterrupted application availability.
- SLOs and error budgets provide measurable
  reliability objectives.
- Controlled failure simulations help identify
  monitoring gaps and operational weaknesses.
- Blameless post-incident reviews support continuous
  reliability improvement.

## 17. Conclusion

The controlled failure simulation successfully
demonstrated Kubernetes self-healing, automated
pod replacement, workload reconciliation, and
application resilience within Google Kubernetes Engine.

Both deleted application pods were automatically
replaced, and the deployment returned to its desired
state with two healthy and available replicas.

All visible HTTP monitoring samples returned HTTP 200 OK,
with no observed failed requests during the sampled
period.

This exercise demonstrates practical Site Reliability
Engineering capabilities in cloud-native infrastructure,
Kubernetes operations, observability, incident management,
reliability validation, and post-incident documentation.

The findings will support future improvements in
automated monitoring, alerting, failure detection,
and operational resilience.
