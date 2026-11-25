# Google Artifact Registry and Container Image Management

## 1. Overview

This project uses Google Artifact Registry to store
and distribute Docker container images for an
application deployed on Google Kubernetes Engine.

Artifact Registry is integrated with GitHub Actions
to automate container image publishing and deployment.

## 2. Repository Configuration

| Component | Configuration |
|---|---|
| Registry Platform | Google Artifact Registry |
| Repository | sre-docker-repo |
| Repository Format | Docker |
| Region | us-east4 |
| Application Image | sre-demo-app |
| Kubernetes Cluster | cluster1 |
| Namespace | default |

## 3. Container Architecture

The application is containerized using Docker
and an NGINX Alpine-based image.

Dockerfile location:

    app/app/Dockerfile

Application source:

    app/index.html

Dockerfile configuration:

    FROM nginx:stable-alpine
    COPY index.html /usr/share/nginx/html/index.html
    EXPOSE 80

The Docker image packages the application HTML
with the NGINX web server.

## 4. Local Docker Build

The initial container image was built manually
to validate the Dockerfile and application.

Build command:

    docker build -t sre-demo-app:v1 \
      -f app/app/Dockerfile app/

The image was successfully built and tested
before publishing to Artifact Registry.

## 5. Local Container Validation

The application container was started locally
using the following command:

    docker run -d --name sre-demo-local \
      -p 127.0.0.1:8080:80 sre-demo-app:v1

Application validation:

    curl -I http://localhost:8080

The application returned HTTP 200 OK.

Container logs were inspected to confirm
successful NGINX startup and HTTP requests.

## 6. Artifact Registry Authentication

Docker authentication was configured using
the Google Cloud CLI.

    gcloud auth configure-docker \
      us-east4-docker.pkg.dev --quiet

The automated pipeline uses temporary Google
Cloud credentials obtained through Workload
Identity Federation.

No long-lived service account JSON keys are
required by the deployment workflow.

## 7. IAM Access Management

| Identity | Permission | Scope |
|---|---|---|
| GitHub deployment service account | Artifact Registry Writer | Repository |
| GKE node service account | Artifact Registry Reader | Repository |

The GitHub deployment identity publishes images.

The GKE node identity retrieves images required
by Kubernetes workloads.

This separates image publishing permissions
from image consumption permissions.

## 8. Container Image Naming

The container image naming convention is:

    REGION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE:TAG

The initial manual image used the v1 tag.

Automated releases use the full Git commit SHA
as the container image tag.

## 9. Automated Container Publishing

GitHub Actions automates the following steps:

1. Authenticate to Google Cloud.
2. Configure Docker authentication.
3. Build the application image.
4. Tag the image using the Git commit SHA.
5. Push the image to Artifact Registry.
6. Connect to the GKE cluster.
7. Update the Kubernetes deployment.
8. Validate the application rollout.

This eliminates the need for manual Docker builds
and image publishing during normal releases.

## 10. Git SHA Image Versioning

The automated pipeline uses the Git commit SHA
to identify application builds.

| Release | Image Tag | Result |
|---|---|---|
| Initial manual build | v1 | Successful |
| Automated Version 1 | a5ea553 | Successful |
| Automated Version 2 | 2c80e41 | Successful |

The abbreviated commit identifiers above are
used for documentation readability.

The actual container image tags contain the
full Git commit SHA.

Git SHA tagging improves release traceability
but does not independently enforce tag immutability.

## 11. Container Deployment

The pipeline updates the Kubernetes deployment
using the newly published image.

    kubectl set image deployment/sre-demo-app \
      nginx=IMAGE_URI -n default

Kubernetes retrieves the specified image from
Artifact Registry and performs a rolling update.

The deployment is validated using:

    kubectl rollout status deployment/sre-demo-app \
      -n default --timeout=300s

## 12. Image Verification

The deployed container image can be verified using:

    kubectl get deployment sre-demo-app -n default \
      -o=jsonpath='{.spec.template.spec.containers[*].image}'

Artifact Registry images can be inspected using:

    gcloud artifacts docker images list \
      us-east4-docker.pkg.dev/$(gcloud config get-value project)/sre-docker-repo \
      --include-tags

These commands help correlate deployed images
with published application releases.

## 13. Rollback and Image Recovery

Previous application images are retained in
Artifact Registry to support release recovery.

A controlled rollback test successfully restored
Version 1 after deploying Version 2.

The previous container image was reused without
rebuilding the application.

Version 2 was subsequently restored and validated.

Image retention policies should preserve images
required for operational rollback procedures.

## 14. Operational Troubleshooting

Common container image issues include:

- ImagePullBackOff
- ErrImagePull
- Incorrect image tags
- Missing container images
- Artifact Registry authentication failures
- Insufficient IAM permissions
- Incorrect repository or region configuration

Recommended troubleshooting commands:

    kubectl get pods -n default

    kubectl describe pod POD_NAME -n default

    kubectl get events -n default \
      --sort-by=.lastTimestamp

    gcloud artifacts repositories describe \
      sre-docker-repo --location=us-east4

Review Kubernetes events and IAM permissions
before modifying deployment configuration.

## 15. Validation Results

| Validation | Result |
|---|---|
| Artifact Registry repository creation | Passed |
| Local Docker image build | Passed |
| Local HTTP application testing | Passed |
| Manual image publishing | Passed |
| Automated image publishing | Passed |
| Repository-level IAM configuration | Passed |
| GKE container image retrieval | Passed |
| Git SHA image versioning | Passed |
| Version 2 automated deployment | Passed |
| Previous image rollback | Passed |
| Latest image restoration | Passed |

## 16. Security and Operational Improvements

Recommended future enhancements include:

- Enable container vulnerability scanning.
- Configure immutable image tags.
- Deploy images using SHA256 image digests.
- Implement container image signing.
- Generate software bills of materials.
- Configure Artifact Registry cleanup policies.
- Preserve images required for rollback.
- Pin the NGINX base image to a reviewed digest.
- Monitor container storage and operational costs.

These improvements are recommendations rather
than completed implementations.

Container vulnerability scanning was not enabled
during the validated project implementation.

## 17. Conclusion

Google Artifact Registry provides centralized
container image management for the GKE application.

Integration with Docker, GitHub Actions, IAM,
and Kubernetes supports automated publishing,
versioned deployments, and application rollback.

The implementation demonstrates practical
container lifecycle management and cloud-native
Site Reliability Engineering capabilities.
