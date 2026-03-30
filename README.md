# AWS EKS Project

## Overview

This project was built as part of my DevOps learning path to gain hands-on experience with AWS, Kubernetes, and observability.

It demonstrates an end-to-end Kubernetes platform on AWS using Terraform and Amazon EKS, including infrastructure provisioning, application deployment, autoscaling, monitoring, and real-world failure scenario testing.

The focus was not only to deploy a working system, but to understand how it behaves under load and during common Kubernetes failures.

---

## Architecture

- Terraform-managed AWS infrastructure
- VPC with public and private subnets across 2 AZs
- Amazon EKS cluster
- One managed node group per AZ for deterministic node distribution
- Dockerized Flask application deployed to Kubernetes
- Kubernetes Service with external exposure
- Horizontal Pod Autoscaler
- Prometheus + Grafana monitoring stack

![Architecture](/project_screenshots/architecture.png)

---

## Tech Stack

- Terraform
- AWS
- Amazon EKS
- Docker
- Kubernetes
- Flask
- Prometheus
- Grafana

---

## Application Endpoints

- `/` - basic application response
- `/health` - health check endpoint
- `/metrics` - Prometheus metrics
- `/cpu` - CPU stress testing
- `/memory` - memory stress testing
- `/slow` - delayed response simulation
- `/error` - controlled error response

---

## Terraform Design

The infrastructure uses:
- modular Terraform structure
- remote state in S3
- state locking with S3 lockfile support

During implementation, I noticed that a single managed node group did not reliably distribute nodes across both AZs at low scale. I refactored the cluster to use one managed node group per AZ, which gave deterministic multi-AZ placement.

---

## Kubernetes Features Implemented

- Deployment
- Service
- ConfigMap
- Secret
- readinessProbe
- livenessProbe
- requests / limits
- HPA

---

## Monitoring

The project includes:
- Metrics Server
- Prometheus
- Grafana
- ServiceMonitor for custom application metrics

Observed metrics included:
- pod CPU usage
- pod memory usage
- request count
- request latency
- scaling behavior

![Grafana](/project_screenshots/BEFORE/beforeGrafana.png)
![Grafana2](/project_screenshots/AFTER/afterGrafana.png)

---

## HPA Test

The application was stress-tested using the `/cpu` endpoint.

Observed behavior during load test:
- baseline state: 2 replicas
- under load: HPA scaled up to 5 replicas
- after load stopped: scaled back down to 2 replicas

### Before load
![HPA Before](/project_screenshots/BEFORE/before.png)

### During load
![HPA During](/project_screenshots/DURING/during.png)

### After load
![HPA After](/project_screenshots/AFTER/after.png)

### HPA details
![HPA Details](/project_screenshots/AFTER/describeAfter.png)

---

## Failure Scenarios Tested

### 1. Service selector mismatch
- Symptom: Service existed but had no endpoints
- Cause: selector did not match Pod labels
- Fix: corrected selector

![Failure1](/project_screenshots/Failure1_Labels/Failure1Before.png)
![Failure1_2](/project_screenshots/Failure1_Labels/Failure1After.png)


### 2. Wrong targetPort
- Symptom: endpoints existed but traffic failed
- Cause: Service forwarded traffic to the wrong port
- Fix: corrected `targetPort`

![Failure2](/project_screenshots/Failure2_TargetPort/Failure2Before1.png)
![Failure2_2](/project_screenshots/Failure2_TargetPort/Failure2After.png)

### 3. Readiness probe failure
- Symptom: Pod was running but not Ready
- Cause: invalid readiness endpoint
- Fix: restored correct health path

![Failure3](/project_screenshots/Failure3_ReadinessProbe/Failure3.png)

### 4. Liveness probe failure
- Symptom: container restart loop
- Cause: invalid liveness probe path
- Fix: restored correct health path

![Failure4](/project_screenshots/Failure4_LivenessProbe/Failure4Before.png)
![Failure4_2](/project_screenshots/Failure4_LivenessProbe/Failure4Before2.png)
![Failure4_3](/project_screenshots/Failure4_LivenessProbe/Failure4After.png)

### 5. OOMKilled
- Symptom: container restarted after memory stress
- Cause: memory limit exceeded
- Fix: restored appropriate memory limits

![Failure5](/project_screenshots/Failure5_OOM/Failure5State.png)
![Failure5_1](/project_screenshots/Failure5_OOM/Failure5.png)
![Failure5_2](/project_screenshots/Failure5_OOM/Failure5After.png)

---

## Key Learnings

- Running does not mean Ready — readiness probes control traffic, not container state  
- Liveness probes trigger restarts, not traffic removal  
- HPA scales Pods, not nodes — cluster capacity still matters  
- Incorrect Service configuration can completely break traffic routing  
- Observability (metrics) is essential for understanding system behavior  
- Multi-AZ design at low scale may require separate node groups for predictable placement  

---
