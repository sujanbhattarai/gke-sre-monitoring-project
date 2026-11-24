# Kubernetes Pod Failure and Recovery

## Incident Summary
- Date: November 24, 2026
- Environment: Google Kubernetes Engine
- Cluster: cluster1
- Namespace: default
- Application: sre-demo-app
- Incident Type: Controlled Failure Simulation

## Objective
Validate Kubernetes self-healing, automatic
pod replacement, and application availability.

## Root Cause
Application pods were intentionally deleted
to simulate workload failure.

## Recovery Process
- ReplicaSet detected the missing replicas.
- Kubernetes automatically created replacement pods.
- The deployment returned to its desired state.
- HTTP monitoring verified application accessibility.

## Results
- Ready replicas: 2/2
- Available replicas: 2
- Container restarts: 0
- Observed HTTP success rate: 100%
- Observed failed requests: 0
- Manual recovery required: No

## Lessons Learned
- Multiple replicas improve application resilience.
- Kubernetes automatically replaces deleted pods.
- Continuous HTTP monitoring helps validate availability.
- Periodic sampling cannot rule out brief interruptions.

## Conclusion
Successfully validated Kubernetes self-healing
and workload resilience through controlled
pod failure simulations.
