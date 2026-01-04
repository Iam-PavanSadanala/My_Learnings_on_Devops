# Jenkins Pipelines with Kubernetes Agents (Interview Preparation)

This document summarizes my hands-on understanding of **Jenkins Pipelines**, **Kubernetes-based agents**, **Job DSL**, and **enterprise CI/CD patterns**. It is intended for **interview preparation** and as a **reference guide**.

---

## 1. Jenkins Jobs – Basics

A **Jenkins job** is a unit of work executed by Jenkins. Common job types:

- Freestyle Job
- Pipeline Job
- Multibranch Pipeline
- Folder / Organization Folder

Traditionally, jobs were created manually via UI. This does not scale in large environments.

---

## 2. Job as Code – Job DSL & Seed Jobs

### Job DSL

- Jenkins jobs are defined using **Groovy DSL**
- Stored in Git
- Version controlled
- Generated automatically

This follows the principle: **Job as Code**.

### Seed Job

A **Seed Job** is a Jenkins job whose purpose is to:

- Read Job DSL scripts from a Git repository
- Create / update / delete Jenkins jobs automatically

Seed jobs do **not** build applications.

Flow:

```
Seed Job
  → Reads DSL scripts
  → Creates Jenkins jobs
  → Generated jobs run pipelines
```

---

## 3. Why Kubernetes Agents in Jenkins

Instead of running builds on the Jenkins controller or static nodes, Jenkins can dynamically create **Kubernetes Pods** for each build.

Benefits:

- Clean, isolated build environments
- No dependency installation on Jenkins controller
- Horizontal scaling
- One pod per build
- Automatic cleanup

---

## 4. Kubernetes Agent – Jenkinsfile Configuration

Example agent block:

```groovy
agent {
    kubernetes {
        inheritFrom "${params.inheritFrom}"
        defaultContainer 'builder'
    }
}
```

### What this means

- Jenkins will create a **dynamic Kubernetes Pod** for this build
- The pod definition is inherited from a **predefined Pod Template**
- All pipeline steps run inside the `builder` container by default

---

## 5. `inheritFrom` – Pod Template Selection

The `inheritFrom` value refers to a **Kubernetes Pod Template** configured in Jenkins UI.

Example Job DSL parameter:

```groovy
stringParam('inheritFrom', 'cd-k8s-1-33-builder', 'Inherit from')
```

This creates a job parameter that allows selecting which pod template to use at runtime.

Flow:

```
Job DSL Parameter
  → params.inheritFrom
  → agent { kubernetes { inheritFrom } }
  → Pod Template selected
  → Kubernetes Pod created
```

---

## 6. Pod Template – What It Defines

A pod template typically includes:

- One or more containers (builder, jnlp, sidecars)
- Container images
- CPU and memory requests / limits
- ServiceAccount name
- Volumes and mounts
- Security context
- Node selectors

This allows central governance and reuse.

---

## 7. Containers in a Jenkins Kubernetes Agent Pod

### jnlp container

- Mandatory container
- Connects the pod back to Jenkins controller
- Uses a short-lived secret generated per build

### builder container

- Default execution container
- Contains tools like:
  - kubectl
  - shell
  - deployment utilities

The `defaultContainer 'builder'` ensures pipeline steps do not run inside the jnlp container.

---

## 8. Workspace Handling

- Workspace is provided using an `emptyDir` volume
- Shared across containers in the same pod
- Deleted when the pod terminates
- Ensures clean builds with no leftover state

---

## 9. Authentication & Access Tokens

### GitHub Access Tokens

- Stored in Jenkins Credentials Manager
- Injected dynamically during checkout
- Used for non-interactive Git operations
- Scoped and revocable

### SSH Keys

- Often used for Jenkins shared libraries
- Managed via Jenkins credentials

### Kubernetes Access

- Provided via ServiceAccount + RBAC
- Jenkins agent pod uses a dedicated ServiceAccount
- kubectl commands execute using cluster permissions

---

## 10. Jenkins Pipeline Execution Flow (Kubernetes)

```
Jenkins Controller
  ├─ Checkout Jenkinsfile (GitHub Token)
  ├─ Load Shared Library (SSH Key)
  ├─ Resolve pod template (inheritFrom)
  ├─ Create Kubernetes Pod
  │    ├─ jnlp container connects to Jenkins
  │    └─ builder container runs pipeline steps
  ├─ Execute stages (kubectl, scripts, etc.)
  └─ Pod deleted after completion
```

---

## 11. Blue/Green Scaling via Jenkins

Typical pattern used in production:

- Determine active deployment (blue or green)
- Scale only the active deployment
- Skip standby deployment
- Use kubectl commands inside Kubernetes agent

This enables zero-downtime operations.

---

## 12. Common Warnings & Best Practices

### Groovy variable scope warning

If variables are not declared using `def`, Jenkins may log warnings and risk memory leaks.

Correct usage:

```groovy
def CURRENT_LIVE_TARGET = 'blue'
def STANDBY_TARGET = 'green'
```

### Best Practices

- Avoid inline pod YAML in Jenkinsfile
- Use `inheritFrom` for standardization
- Never hardcode secrets
- Use least-privilege RBAC
- Destroy pods after each build

---

## 13. Interview-Ready Summary

> We use Jenkins with Kubernetes agents to dynamically provision build environments. Jobs are generated using Job DSL via seed jobs. The Jenkinsfile selects a predefined Kubernetes pod template using the `inheritFrom` parameter, ensuring standardized tooling, security, and RBAC. Each build runs in an isolated pod with a builder container for execution and a jnlp container for Jenkins connectivity.

---

## 14. Advanced Interview Q&A (Jenkins + Kubernetes)

### Q1. Why use Kubernetes agents instead of static Jenkins nodes?

**Answer:**
Kubernetes agents allow Jenkins to provision build environments dynamically. Each build runs in its own pod, ensuring isolation, scalability, and clean environments. This removes dependency management from the Jenkins controller and enables cloud-native CI/CD.

---

### Q2. What is the purpose of the `jnlp` container?

**Answer:**
The `jnlp` container is mandatory for Kubernetes-based Jenkins agents. It establishes a secure outbound connection from the pod to the Jenkins controller using a short-lived secret and the Jenkins remoting protocol. Pipeline steps should not run inside this container.

---

### Q3. Why do we use `defaultContainer`?

**Answer:**
By default, Jenkins executes steps in the `jnlp` container, which usually lacks build tools. Setting `defaultContainer` ensures that all pipeline steps run inside a purpose-built container (for example, `builder`) that contains tools like kubectl, Maven, or shell utilities.

---

### Q4. What is `inheritFrom` in Kubernetes agents?

**Answer:**
`inheritFrom` allows the Jenkinsfile to reuse a predefined Kubernetes pod template configured in Jenkins. This centralizes configuration for images, RBAC, resource limits, and security, and avoids duplicating pod YAML across pipelines.

---

## 15. STAR-Format Explanation (Interview Ready)

**Situation:**
Our organization runs multiple production workloads on Kubernetes and needed a scalable CI/CD solution.

**Task:**
Design Jenkins pipelines that are secure, scalable, and easy to maintain across environments.

**Action:**
We implemented Jenkins Kubernetes agents using predefined pod templates. Jobs are generated via Job DSL using a seed job. The Jenkinsfile dynamically selects the appropriate pod template using the `inheritFrom` parameter, and pipeline steps run inside a dedicated builder container.

**Result:**
We achieved isolated builds, faster onboarding, centralized governance, and consistent deployments across environments.

---

## 16. Sample Repository Structure (Recommended)

```
repo-root/
├── Jenkinsfile
├── job-dsl/
│   ├── seed-job.groovy
│   └── app-pipeline.groovy
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── README.md
```

---

## 17. Common Troubleshooting Scenarios

### Pod stuck in Pending
- Check node capacity
- Verify image pull permissions
- Inspect admission controllers or sidecars

### Jenkins agent goes offline
- Validate JNLP connectivity
- Check serviceAccount RBAC
- Verify Jenkins URL and tunnel settings

### kubectl permission errors
- Review ServiceAccount permissions
- Confirm namespace access
- Check kubeconfig or IRSA setup

---

## 18. Topics to Revise Further

- Jenkins Configuration as Code (JCasC)
- Jenkins RBAC & Security
- IRSA for EKS
- Multibranch Pipelines
- PR validation pipelines
- Jenkins shared libraries

---

✅ This document now supports **deep technical interviews**, **hands-on discussions**, and **architecture-level questions**.
