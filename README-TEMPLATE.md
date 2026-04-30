<!--
  Template documentation for CloudOpsWorks .NET application repositories.
  Replace placeholders (ORG_NAME, ENV_NAME, PROJECT_NAME, URLs, account IDs, etc.)
  before publishing the generated repository README.
-->

# CloudOpsWorks .NET Application Template

This repository is a starter template for .NET applications that are built, scanned, versioned, containerized, and deployed through CloudOpsWorks GitHub Actions blueprints.

Use this file as the base README for repositories created from this template.

## What this template gives you

- A sample ASP.NET Core API (`HelloWorldApi`) with unit and integration tests.
- GitHub Actions workflows for PR validation, release builds, deployments, previews, scans, and repo automation.
- CloudOpsWorks configuration under `.cloudopsworks/` for CI/CD, environment inputs, API Gateway definitions, and Helm overrides.
- Make targets to initialize the template for a real project and to materialize build versions.
- GitVersion configuration for both GitFlow and GitHub Flow release strategies.

## Repository structure

- `HelloWorldApi/` – sample application to replace or adapt.
- `HelloWorldApi.Tests/` – unit tests.
- `HelloWorldApi.Tests.Integration/` – integration tests.
- `.github/workflows/` – CI/CD pipelines driven by CloudOpsWorks blueprints.
- `.cloudopsworks/cloudopsworks-ci.yaml` – repository policy and deployment mapping.
- `.cloudopsworks/vars/` – global and per-target deployment inputs.
- `.cloudopsworks/vars/apigw/` – API Gateway definitions.
- `.cloudopsworks/vars/helm/` – Helm values per environment.
- `.cloudopsworks/vars/preview/` – preview-environment configuration.
- `.cloudopsworks/gitversion_gitflow.yaml` – GitVersion strategy for GitFlow repositories.
- `.cloudopsworks/gitversion_githubflow.yaml` – GitVersion strategy for GitHub Flow repositories.
- `Makefile` – template bootstrap and version helper targets.

## Quick start

### 1. Create your repository from the template

After creating the new repository:

1. Clone it locally.
2. Replace this `README-TEMPLATE.md` content into your final `README.md`.
3. Replace placeholders such as `ORG_NAME`, `ENV_NAME`, `REGISTRY`, `AWS_REGION`, `GCP_PROJECT`, and `DOMAIN_NAME`.

### 2. Initialize the .NET project naming

Run:

```bash
make code/init
```

This target renames the sample solution and projects from `HelloWorldApi` to the repository-derived project name, updates project references, and refreshes .NET assembly metadata.

### 3. Configure global application settings

Edit `.cloudopsworks/vars/inputs-global.yaml` first.

Required baseline values:

- `organization_name`
- `organization_unit`
- `environment_name`
- `repository_owner`
- `cloud`
- `cloud_type`

Common optional values to review immediately:

- `dotnet.project_path`
- `dotnet.version`
- `dotnet.configuration`
- `preview.enabled`
- `apis.enabled`
- `observability.enabled`
- `snyk.enabled`
- `semgrep.enabled`
- `trivy.enabled`
- `sonarqube.enabled`
- `dependencyTrack.enabled`

## Choose the deployment target

Each environment should use the input file that matches the actual runtime target.

### AWS Elastic Beanstalk

File: `.cloudopsworks/vars/inputs-BEANSTALK-ENV.yaml`

Use when deploying a traditional web workload to Elastic Beanstalk.
Review:

- `versions_bucket`
- `container_registry`
- `aws.region`
- DNS and alarms blocks
- `beanstalk.application`
- instance sizing, subnets, load balancer, and `port_mappings`
- optional `blue_green`

### AWS Lambda

File: `.cloudopsworks/vars/inputs-LAMBDA-ENV.yaml`

Use for serverless function deployments. Review runtime, handler, IAM, layers, triggers, concurrency, schedule, VPC, and logging settings.

### Generic Kubernetes / Helm

File: `.cloudopsworks/vars/inputs-KUBERNETES-ENV.yaml`

Use for Kubernetes-style targets such as generic clusters where Helm is the deployment mechanism. Review:

- `container_registry`
- `cluster_name`
- `namespace`
- `helm_repo_url`, `helm_chart_name`, or `helm_chart_path`
- secret/config map mounting
- cloud secret sync / external secret integration

### GCP Cloud Run

File: `.cloudopsworks/vars/inputs-CLOUDRUN.yaml`

Use for Cloud Run services, jobs, or worker pools. Review:

- `container_registry`
- `gcp.region`
- `gcp.project_id`
- `cloudrun.type`
- scaling, resources, env vars, secrets, probes, VPC connectivity, and triggers

### GCP App Engine

File: `.cloudopsworks/vars/inputs-APPENGINE.yaml`

Use for App Engine standard or flexible deployments. Review:

- `versions_bucket`
- `container_registry`
- `gcp.region`
- `gcp.project_id`
- `appengine.runtime`
- `appengine.type`
- `appengine.entrypoint_shell` (set this to the actual startup command for your app)
- scaling and instance settings

### Library / no deployment

File: `.cloudopsworks/vars/inputs-LIB-ENV.yaml`

Use when the repository produces a package or artifact but does not deploy an application runtime.

## Configure API Gateway support

If `apis.enabled: true` in `inputs-global.yaml`, complete the files under `.cloudopsworks/vars/apigw/`:

- `apis-global.yaml`
- `apis-dev.yaml`
- `apis-uat.yaml`
- `apis-prod.yaml`

These files define API names, mappings, stage behavior, gateway type, backend routing, and optional authorizers.

Sample API definitions live in `apifiles/`.

## Configure Helm overrides

For Kubernetes-style deployments, adjust:

- `.cloudopsworks/vars/helm/values-dev.yaml`
- `.cloudopsworks/vars/helm/values-uat.yaml`
- `.cloudopsworks/vars/helm/values-prod.yaml`

Typical edits:

- image repository/tag overrides
- ingress hosts and annotations
- ports and health probes
- replica count / autoscaling
- environment variables and mounted volumes
- service account, affinity, tolerations, and KEDA/HPA settings

## Preview environments

Preview environments are controlled by:

- `preview.enabled` in `.cloudopsworks/vars/inputs-global.yaml`
- `.cloudopsworks/vars/preview/inputs.yaml`
- `.cloudopsworks/vars/preview/values.yaml`

Enable previews when pull requests should deploy temporary environments for validation.

## CI/CD workflows

The repository ships with these main workflows:

- `pr-build.yml` – validates pull requests and can deploy previews.
- `main-build.yml` – builds release branches, mainline pushes, and tags.
- `deploy-container.yml` – publishes container images.
- `deploy.yml` – standard deployment path.
- `deploy-blue-green.yml` – blue/green deployment path.
- `environment-destroy.yml` / `environment-unlock.yml` – environment lifecycle utilities.
- `scan.yml` – security and static analysis orchestration.
- `process-owners.yml`, `automerge.yml`, slash-command workflows – repo automation.

All of them rely on `cloudopsworks/blueprints` actions referenced through `./bp/...`.

## Branching, versioning, and releases

### Branch model

Repository behavior is driven by `.cloudopsworks/cloudopsworks-ci.yaml`.
By default it enables GitFlow-style promotion:

- `develop` → `dev`
- `release/**` → `prod`
- release test path → `uat`
- prerelease tags → `demo`
- `hotfix/**` → `hotfix`

Support-branch mapping can also be defined there.

### GitVersion configuration

Two GitVersion templates are included:

- `.cloudopsworks/gitversion_gitflow.yaml`
- `.cloudopsworks/gitversion_githubflow.yaml`

Use the one that matches your repository branching strategy. They define how `+semver:` annotations are translated into version bumps for release automation.

Supported annotations include:

- `+semver: patch`
- `+semver: fix`
- `+semver: minor`
- `+semver: feature`
- `+semver: major`
- `+semver: breaking`
- `+semver: none`

### Local version materialization

Run:

```bash
make version
```

This writes the resolved semantic version into `VERSION` and updates the project file version metadata using GitVersion output.

## Local development

Typical local loop:

```bash
dotnet restore
dotnet build
dotnet test
```

The sample app exposes:

- `GET /health`
- `GET /hello`

Replace the sample implementation with your service logic once the template has been initialized.

## Repository configuration checklist

Before opening the first release PR, verify:

- [ ] `make code/init` was run.
- [ ] `README.md` was replaced with project-specific documentation.
- [ ] `.cloudopsworks/vars/inputs-global.yaml` is fully updated.
- [ ] The correct `inputs-*.yaml` target file is configured for each environment.
- [ ] Required GitHub repository variables and secrets exist.
- [ ] API Gateway files are complete if `apis.enabled` is true.
- [ ] Helm values are updated if deploying to Kubernetes.
- [ ] Preview settings are configured if PR previews are required.
- [ ] Observability and security tool toggles match the team's standards.
- [ ] Branch protection/reviewer settings in `.cloudopsworks/cloudopsworks-ci.yaml` are correct.

## Required GitHub secrets and variables

The exact set depends on the target cloud and enabled integrations, but most repositories will need some of the following:

- `BOT_TOKEN`
- cloud credentials for build/deploy
- registry credentials
- SonarQube token and URL
- Snyk token
- Semgrep token
- DependencyTrack token and URL
- preview-environment variables
- runner-set variables for self-hosted execution

Document the final expected secret/variable set in your repository after choosing the deployment target.

## Notes for maintainers of this template

When updating the template itself:

- keep sample application code buildable and testable;
- keep `README-TEMPLATE.md` aligned with actual files in `.cloudopsworks/vars/` and `.github/workflows/`;
- update the GitVersion documentation when `.cloudopsworks/gitversion_*.yaml` changes;
- prefer documenting real template behavior over blueprint internals not visible in this repository.
