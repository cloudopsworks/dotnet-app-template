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

---

## Upgrading from the Template

Repositories derived from this template stay in sync with upstream releases using the
`make repos/upgrade*` targets. An agent asked to "upgrade", "update from template",
"sync with template", "apply template changes", or "bump template version" should use
these targets — never fetch or apply template changes manually.

### Available upgrade targets

| Target | When to use |
|---|---|
| `make repos/upgrade` | **Default — patch upgrade.** Pulls the latest patch within the **same minor version**. No breaking changes. Use for routine maintenance. |
| `make repos/upgrade/major` | Pulls the latest release within the **same major version**. May include workflow-level changes. |
| `make repos/upgrade/master` | Pulls from the template's `master` branch tip. Use only when explicitly asked to track the latest unreleased template state. |
| `make repos/upgrade/dev` | Pulls from the template's `develop` branch. Use only for pre-release or preview upgrades. |
| `make repos/available` | Lists the latest available patch and major versions without modifying anything. Run this first to see what is available. |

### Upgrade workflow for agents

1. Run `make repos/available` to see the current and latest available versions.
2. Choose the appropriate target (default: `make repos/upgrade` for a routine patch upgrade).
3. Review the diff — the upgrade overwrites `.github/workflows/` and selected `.cloudopsworks/` metadata; application source files are never touched.
4. Commit the result with: `chore: upgrade from <template-name> <old-version> → <new-version> +semver: patch`
5. Use `/cw-release` to create and merge the hotfix PR (see [Release Workflow — use `cw-release`](#release-workflow--use-cw-release)).

> **Note:** `Makefile`, `.github/`, `.cloudopsworks/labeler.yml`, `.cloudopsworks/Makefile`,
> and `.cloudopsworks/LICENSE` are owned by the template and will be overwritten on every upgrade.
> Do not edit these files manually in derived repositories.

---

## AI-assisted upgrade of `.cloudopsworks/vars` configuration files

This section is a machine-readable protocol for AI agents performing a seamless, non-destructive upgrade of all configuration files under `.cloudopsworks/vars/` when a new template version is released. Follow the steps below in order.

### Upgrade overview

The template version locked into this repository is recorded in `.cloudopsworks/_VERSION`. The canonical upstream source is the GitHub repository `cloudopsworks/dotnet-app-template`, pinned to the tag that matches the content of `_VERSION`.

An upgrade merges new keys, updated comments, and structural changes from the upstream template into local files **without overwriting values the operator has already set**.

---

### Step 1 — determine current and target versions

1. Read `.cloudopsworks/_VERSION` to get the **current locked version** (e.g., `v1.4.15`).
2. The **target version** is either supplied by the operator or is the latest release tag on `cloudopsworks/dotnet-app-template`.
3. Fetch any upstream file from GitHub using the pattern:
   ```
   https://raw.githubusercontent.com/cloudopsworks/dotnet-app-template/<version>/<path>
   ```
   Example:
   ```
   https://raw.githubusercontent.com/cloudopsworks/dotnet-app-template/v1.4.15/.cloudopsworks/vars/inputs-global.yaml
   ```

---

### Step 2 — identify the deployment type for each environment file

Each `inputs-<name>.yaml` file under `.cloudopsworks/vars/` maps to a specific upstream template. Determine the type using the following priority order:

**Priority 1 — `Agents:` header comment**

If the file contains an `# Agents:` line in its header block, read `cloud` and `cloud_type` directly from it:

```yaml
# Agents: cloud=aws ; cloud_type=lambda
```

Multiple valid combinations may be listed separated by `|`:

```yaml
# Agents: cloud=aws|gcp|azure ; cloud_type=kubernetes
```

**Priority 2 — fallback to `inputs-global.yaml`**

If no `# Agents:` line is present, read the active `cloud` and `cloud_type` values from `.cloudopsworks/vars/inputs-global.yaml` and apply the mapping table below.

**`cloud` / `cloud_type` → upstream template file:**

| `cloud`                  | `cloud_type`                   | Upstream template file         |
|--------------------------|--------------------------------|--------------------------------|
| `aws`                    | `eks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `azure`                  | `aks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `gcp`                    | `gke` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `aws`                    | `lambda`                       | `inputs-LAMBDA-ENV.yaml`       |
| `aws`                    | `beanstalk`                    | `inputs-BEANSTALK-ENV.yaml`    |
| `gcp`                    | `appengine`                    | `inputs-APPENGINE.yaml`        |
| `gcp`                    | `cloudrun`                     | `inputs-CLOUDRUN.yaml`         |
| `aws` / `gcp` / `azure`  | `none` or library mode         | `inputs-LIB-ENV.yaml`          |

`inputs-global.yaml` always maps to the upstream `inputs-global.yaml` regardless of cloud type.

---

### Step 3 — upgrade deployment target files

The deployment target files identified by the Step 2 mapping table — such as `inputs-KUBERNETES-ENV.yaml`, `inputs-LAMBDA-ENV.yaml`, `inputs-BEANSTALK-ENV.yaml`, `inputs-APPENGINE.yaml`, `inputs-CLOUDRUN.yaml`, `inputs-LIB-ENV.yaml`, and mobile equivalents such as `inputs-ANDROID-ENV.yaml` and `inputs-XCODE-ENV.yaml` — are **scaffolding templates**. They provide placeholder structures and documented examples, not finalized operator configuration.

**Do not merge these files. Overwrite them.**

Upgrade procedure for each deployment target file:

1. **Before overwriting** — inspect the local file and record any operator-configured values (keys that have been uncommented and set to non-placeholder values).
2. **Replace the file** — overwrite the local file entirely with the upstream template version.
3. **Re-apply operator values** — after overwriting, set each previously recorded operator-configured value at its corresponding key in the new file.
4. **Copy in absent files** — if a deployment target file is present in the upstream template but absent locally, copy it in from the upstream template as a new file.

---

### Step 4 — merge `inputs-global.yaml`

`inputs-global.yaml` requires special handling because it contains mandatory operator identity fields alongside a large body of optional commented-out sections.

Merge procedure:

1. **Retain the four mandatory identity fields** verbatim at the top of the file:
   ```yaml
   organization_name: "..."
   organization_unit: "..."
   environment_name: "..."
   repository_owner: "..."
   ```
2. **Retain `cloud` and `cloud_type`** exactly as the operator set them.
3. **For every optional commented-out section** in the upstream template, check the local file:
   - If the operator **has uncommented and configured it** — keep the operator's values; update only surrounding comment text if it changed upstream.
   - If the section **is still fully commented out locally** — replace the entire commented block with the upstream version, capturing any new fields or updated documentation within it.
4. **Append new optional sections** that appear in the upstream template but are entirely absent locally, in fully commented-out form, preserving their upstream position and comments.

---

### Step 5 — upgrade subdirectory files

Apply the merge rules from Step 4 to every file in the following subdirectories, matching each local file to its corresponding upstream file at the same relative path:

- `.cloudopsworks/vars/preview/inputs.yaml`
- `.cloudopsworks/vars/preview/values.yaml`
- `.cloudopsworks/vars/apigw/apis-global.yaml`
- `.cloudopsworks/vars/apigw/apis-dev.yaml`
- `.cloudopsworks/vars/apigw/apis-uat.yaml`
- `.cloudopsworks/vars/apigw/apis-prod.yaml`
- `.cloudopsworks/vars/helm/values-dev.yaml`
- `.cloudopsworks/vars/helm/values-uat.yaml`
- `.cloudopsworks/vars/helm/values-prod.yaml`

---

### Step 6 — update `_VERSION`

After all merges are verified correct, write the target version string (e.g., `v1.4.16`) to `.cloudopsworks/_VERSION`. This is the final step.

---

### Upgrade invariants

An agent performing this upgrade must **never**:

- Overwrite a field the operator has explicitly set to a non-placeholder value.
- Remove a commented-out operator value without first reporting it.
- Change the YAML structure of any active (uncommented) operator section.
- Alter a file's opening description comment (`# This file contains...`) unless the upstream version changed it.
- Modify `.cloudopsworks/cloudopsworks-ci.yaml`, `gitversion_*.yaml`, or any file under `.github/workflows/` as part of a vars upgrade — those follow their own upgrade path.
- Update `_VERSION` before all file merges are complete.

---

### Conflict resolution

When a merge cannot be resolved automatically (for example, the upstream template restructured a section that the operator has customized):

1. Emit a diff showing both the upstream template block and the local operator block side by side.
2. Pause and present the conflict to the operator, asking which version to keep or whether a manual merge is needed.
3. Never silently choose one side.

---

## Release Workflow — use `cw-release`

All releases **must** be performed using the `cw-release` skill from the CloudOps Works skill set. Do **not** create release branches, hotfix branches, version tags, or release PRs manually — the skill owns the full GitFlow-aware release lifecycle for this repository.

### When to invoke `cw-release`

Use it whenever you are asked to:
- Release, ship, or publish a new version (patch, minor, or major)
- Create a hotfix or patch release
- Create a release branch or feature-merge PR
- Tag and publish a version

### How to run it

In Claude Code (CLI, IDE extension, or web):

```
/cw-release
```

### What the skill does

1. Detects the GitVersion flow in use (`gitversion_gitflow.yaml` or `gitversion_githubflow.yaml`).
2. Reads the repo-local release policy from `.cloudopsworks/cloudopsworks-ci.yaml`.
3. Drives the shared tronador `make` / `gh` release path end-to-end.
4. Creates the correct branch, PR, tag, and GitHub Release in the right sequence.

> **Do not** run `git tag`, `gh release create`, or `make release` directly. Always let `cw-release` orchestrate these steps to keep version history and CI consistent.
