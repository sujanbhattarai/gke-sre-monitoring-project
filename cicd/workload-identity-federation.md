# Workload Identity Federation and CI/CD Security

## 1. Overview

This project implements secure authentication between
GitHub Actions and Google Cloud using Workload Identity
Federation.

The implementation eliminates the need to store
long-lived Google Cloud service account JSON keys
in GitHub.

## 2. Security Objectives

- Implement keyless cloud authentication.
- Use temporary authentication credentials.
- Restrict access to the authorized GitHub repository.
- Implement least-privilege IAM permissions.
- Restrict Kubernetes deployment permissions.
- Separate container publishing and image pull access.

## 3. Workload Identity Configuration

| Component | Configuration |
|---|---|
| Identity Pool | github-pool |
| Identity Provider | github-provider |
| Identity Provider Type | OpenID Connect |
| Provider Status | Active |
| OIDC Issuer | token.actions.githubusercontent.com |
| Service Account | github-gke-deployer |
| Authorized Repository | sujanbhattarai/gke-sre-monitoring-project |

## 4. Authentication Flow

1. GitHub Actions requests an OIDC identity token.
2. Google Cloud validates the token through the
   configured Workload Identity Provider.
3. The repository identity is evaluated.
4. The authorized workload impersonates the
   dedicated deployment service account.
5. Temporary credentials are issued.
6. The workflow accesses authorized Google Cloud
   resources.

## 5. Attribute Mapping

The identity provider maps GitHub token attributes
to Google Cloud identity attributes.

Configured mappings include:

    google.subject = assertion.sub
    attribute.repository = assertion.repository

The provider uses a repository-specific attribute
condition to restrict authentication.

    assertion.repository ==
    'sujanbhattarai/gke-sre-monitoring-project'

This condition restricts authentication to the
configured GitHub repository.

The provider condition does not independently
restrict authentication to the main branch.

## 6. Service Account Configuration

A dedicated service account is used for automated
application deployment.

Service account name:

    github-gke-deployer

The service account is separate from the default
GKE node service account.

This separation improves access management and
reduces unnecessary permissions.

## 7. IAM Permission Model

| Identity | IAM Role | Scope |
|---|---|---|
| Authorized GitHub workload | roles/iam.workloadIdentityUser | Deployment service account |
| GitHub deployment service account | roles/container.clusterViewer | Google Cloud project |
| GitHub deployment service account | roles/artifactregistry.writer | Artifact Registry repository |
| GKE node service account | roles/artifactregistry.reader | Artifact Registry repository |

The GitHub deployment identity can publish container
images and retrieve GKE cluster information.

The GKE node identity can retrieve container images
from Artifact Registry.

## 8. Kubernetes RBAC

Google Cloud IAM authentication is combined with
Kubernetes Role-Based Access Control.

RBAC configuration file:

    kubernetes/github-deployer-rbac.yaml

The implementation uses a namespace-level Role
and RoleBinding.

The deployment identity is authorized to perform
the Kubernetes operations required by the pipeline.

Deployment patch authorization was explicitly
validated using kubectl auth can-i.

## 9. GitHub Actions Permissions

The deployment job uses the following GitHub
Actions permissions:

    permissions:
      contents: read
      id-token: write

The contents permission allows repository checkout.

The id-token permission allows GitHub Actions
to request an OIDC identity token.

The deployment job runs on eligible main-branch
workflow executions.

Pull requests execute YAML validation without
running the deployment job.

## 10. Authentication Implementation

The workflow uses the Google Cloud authentication
and SDK setup actions:

    google-github-actions/auth@v2
    google-github-actions/setup-gcloud@v2

The authentication action receives the Workload
Identity Provider resource and deployment
service account identity.

The workflow then configures Docker authentication
and obtains GKE cluster credentials.

## 11. Security Validation

| Validation | Result |
|---|---|
| Workload Identity Pool active | Passed |
| Workload Identity Provider active | Passed |
| Repository attribute restriction | Configured |
| Service account impersonation | Passed |
| Artifact Registry write access | Passed |
| GKE image pull access | Passed |
| Kubernetes deployment patch access | Passed |
| Automated GKE deployment | Passed |
| Keyless pipeline authentication | Passed |

Successful GitHub Actions deployments demonstrate
that the configured authentication and authorization
mechanisms support the required deployment operations.

## 12. Operational Troubleshooting

Authentication failures should be investigated by
checking:

- Workload Identity Pool status.
- Workload Identity Provider status.
- GitHub repository attribute conditions.
- Service account IAM bindings.
- GitHub Actions OIDC permissions.
- Artifact Registry repository permissions.
- GKE cluster access permissions.
- Kubernetes Role and RoleBinding configuration.

Authentication and authorization should be
troubleshot separately.

Successful cloud authentication does not
automatically grant Kubernetes deployment access.

## 13. Security Benefits

- No long-lived service account keys required.
- Temporary cloud authentication credentials.
- Dedicated deployment identity.
- Repository-scoped identity restrictions.
- Repository-level Artifact Registry permissions.
- Namespace-level Kubernetes authorization.
- Separation of image publishing and image pulling.
- Reduced exposure of persistent credentials.

## 14. Future Security Improvements

Recommended improvements include:

- Restrict identity federation using immutable
  GitHub repository and owner identifiers.
- Add branch or deployment environment restrictions
  to the identity provider condition.
- Configure GitHub environment protection rules.
- Require approval for sensitive deployments.
- Pin GitHub Actions to reviewed commit SHAs.
- Enable container vulnerability scanning.
- Deploy images using immutable image digests.
- Review IAM and Kubernetes RBAC permissions regularly.
- Enable additional security auditing.

These improvements are recommendations and are
not represented as completed implementations.

## 15. Conclusion

The project demonstrates keyless CI/CD authentication
using Google Cloud Workload Identity Federation,
dedicated service accounts, IAM permissions, and
Kubernetes RBAC.

The implementation supports automated container
publishing and GKE deployment while avoiding
long-lived service account credentials.
