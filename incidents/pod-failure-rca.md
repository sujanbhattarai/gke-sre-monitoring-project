# GKE SRE Incident Report

## Incident
Kubernetes Pod Failure Simulation

## Environment
- Platform: Google Cloud Platform
- Service: Google Kubernetes Engine
- Application: sre-demo-app

## Incident Description
A Kubernetes application pod was intentionally
deleted to test automated workload recovery.

## Root Cause
Controlled deletion of a Kubernetes pod
during an SRE reliability test.

## Recovery
The Kubernetes Deployment controller created
a replacement pod to maintain the desired
replica count.

## Validation
- Verified pod status using kubectl
- Reviewed Kubernetes events
- Confirmed desired replica count

## Lessons Learned
- Kubernetes supports automatic pod replacement.
- Monitoring helps detect workload failures.
- Incident documentation improves operational readiness.
