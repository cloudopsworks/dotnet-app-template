<!--
  Template documentation for CloudOpsWorks .NET module.
  Replace placeholders (ORG_NAME, ENV_NAME, etc.) with real values before use.
-->

# CloudOpsWorks .NET Module – README Template

Comprehensive guide to configure and operate this .NET application template using CloudOpsWorks blueprints and GitHub Actions.

## Goal & Scope
- **Goal:** Document how to configure CI/CD, environments, Helm/Kubernetes options, API Gateway, and per-target deployment inputs for this template.
- **Covers:** `.cloudopsworks/vars/*`, GitHub workflows (except labeler), Helm chart options from blueprint, preview disclaimer, and sample .NET app overview.
- **Excludes:** `labeler.yml` and labeler workflow; preview format files are Helm-compatible and already aligned.

## Repository Layout (high level)
- `.cloudopsworks/cloudopsworks-ci.yaml` – global repo/CD settings & deployment map.
- `.cloudopsworks/vars/` – module configuration inputs (global + per environment target).
- `.cloudopsworks/vars/apigw/` – API Gateway definitions per env plus global defaults.
- `.cloudopsworks/vars/helm/` – Helm values overrides per env (dev/uat/prod) to combine with base chart.
- `.cloudopsworks/vars/preview/` – preview inputs/values (Helm-compatible).
- `.github/workflows/` – CI/CD workflows using `cloudopsworks/blueprints` actions (./bp prefixes).
- `HelloWorldApi/` – sample .NET API (demo only).

## CI/CD Workflows (GitHub Actions)
All workflows rely on blueprint actions under `./bp` (resolved from `cloudopsworks/blueprints`). Key workflows:

- **`main-build.yml` (Release Build)**
  - Triggers: pushes to `develop`, `release/**`, `support/**`, tags `v*.*.*`, manual dispatch, and branch creates for release/support.
  - Steps: checkout with blueprint; `./bp/ci/config`; `.NET build/test` (`./bp/ci/dotnet/build`); optional library deploy; artifacts; optional API artifacts; optional container build/push; fan-out to deploy workflows; release job when tag; scan job.
  - Outputs reused by downstream: semver, deployment_name, cloud/cloud_type, environment, runner_set, apis_enabled, container_enabled, blue_green flag, observability flags, project key/owner.

- **`pr-build.yml` (PR Build & Preview)**
  - Triggers: PR open/sync/edit to `hotfix/**`, `feature/**`, `develop`, `release/**`, `support/**`, `master`.
  - Steps: checkout; `./bp/ci/config`; PR checks; .NET build/test; optional library deploy; artifacts; optional container build; optional preview deploy (AWS/Azure/GCP) when preview enabled; scan job (SAST/SCA/DAST) with is_preview flag.

- **`deploy-container.yml`**
  - Called from build workflows to push container to target cloud/registry and prepare deploy artifacts. Uses runner_set and cloud_type to select provider logic.

- **`deploy.yml`**
  - Standard deployment when blue/green is **not** enabled. Applies Terraform/Helm depending on cloud_type. Supports apis_enabled and observability flags.

- **`deploy-blue-green.yml`**
  - Deployment with blue/green enabled (switching traffic after validation). Similar inputs as `deploy.yml` plus blue_green flag.

- **`environment-destroy.yml` / `environment-unlock.yml`**
  - Utility workflows to destroy or unlock environments.

- **`scan.yml`**
  - Consolidated security/static scans (SonarQube, Snyk, Semgrep, DependencyTrack). Invoked from main and PR pipelines.

- **Other utility workflows**
  - `automerge.yml`, `patch-management.yml`, `process-owners.yml`, `jira-integration.yml`, slash command handlers (`slash-commands.yml`, `slash-on-approve.yml`, `slash-on-retry-automerge.yml`), `pr-close.yaml`. Labeler is intentionally ignored per instructions.

## Repository/Branch Configuration – `.cloudopsworks/cloudopsworks-ci.yaml`
- **Packaging:** `zipGlobs` includes `conf/**`; excludes common infra files (Dockerfile, .helmignore/.dockerignore, .git*, OWNER*, README, Jenkins, charts, skafold, Makefile, apifiles, tronador).
- **Repo config**
  - `branchProtection: true` – enable branch protection via API.
  - `gitFlow.enabled: true`, `supportBranches: false` – GitFlow model without support branches by default.
  - `protectedSources`: `*.tf`, `*.tfvars`, OWNERS, Makefile, .github.
  - `requiredReviewers: 1`; `reviewers`, `owners`, `contributors` (admin/triage/pull/push/maintain lists) to be filled per org.
- **CD map (git-flow driven):**
  - `develop -> env: dev`
  - `release/** -> env: prod`
  - `test (for release branches) -> env: uat`
  - `prerelease -> env: demo`
  - `hotfix -> env: hotfix`
  - `support` versions matching patterns -> mapped env/targetName pairs (examples: 1.5.* -> demo, 1.3.* -> demo2)
  - `cd.automatic`: whether lower env merges/deploys are automatic (default false).
  - Optional per-deployment variables, targetName, reviewers, enabled flags shown in comments.

## Module Configuration – `.cloudopsworks/vars`
### 1) Global base – `inputs-global.yaml` (applies to all environments)
- **Org/repo metadata:** `organization_name`, `organization_unit`, `environment_name`, `repository_owner` (required).
- **.NET settings (`dotnet`):** `project_path` (default `HelloWorldApi`); optional `version`, `dist` (aspnet|runtime|sdk), `image_variant` (alpine), `configuration` (e.g., Release), test project paths overrides, build/test/publish options, docker inline/args, custom run command, custom usergroup, api_files_dir.
- **Security/QA toggles:** `snyk.enabled`, `semgrep.enabled`, `sonarqube.*` (fail_on_quality_gate, quality_gate_enabled, sources/binaries/tests paths, exclusions, branch_disabled for community edition), `dependencyTrack.enabled` (default true, type Application).
- **Jira:** enable + project_id/key overrides.
- **Library flag:** `is_library: true` (deprecated alias `isLibrary`).
- **Preview environments:** enable + `kubernetes` flag, `domain`, `azure.resource_group`, `gcp.project_id`.
- **APIs:** `apis.enabled` toggle for API Gateway deployments (definitions under `vars/apigw`).
- **Observability:** `observability.enabled`, `agent` (xray|newrelic|datadog|dynatrace), detailed config for XRAY and DataDog including tracing, sampling, plugins, logs, APM.
- **CD targeting (required for deploy):** `cloud` (aws|azure|gcp), `cloud_type` (beanstalk|eks|lambda|aks|webapp|function|gke|appengine|cloudrun|kubernetes), optional `runner_set` (self-hosted ARC).

### 2) Environment-specific input files (choose one per environment)
Each environment must reference exactly one inputs-***.yaml matching the target deployment type.

- **`inputs-BEANSTALK-ENV.yaml` (AWS Elastic Beanstalk)**
  - `environment` name; optional `runner_set`, `disable_deploy`, `dotnet_configuration` override.
  - `versions_bucket`, optional `logs_bucket`, `blue_green` toggle, `container_registry` (for images if preview=false).
  - `aws.region`, optional STS role per build/deploy.
  - DNS: `enabled`, `private_zone`, `domain_name`, `alias_prefix`.
  - Alarms: `enabled`, `threshold`, `period`, `evaluation_periods`, `destination_topic`.
  - API Gateway: `enabled`, optional VPC link (create/use existing, lb_name, listener_port, health checks, mapping rules).
  - **Beanstalk app config:**
    - `solution_stack` selector (many presets: java, tomcat, node, go, docker, dotnet-{6,8,9}, windows IIS, python variants, etc.; can pin full name).
    - `application` name; optional `wait_for_ready_timeout`.
    - IAM: `instance_profile`, `service_role`.
    - Load balancer: public, ssl cert/policy, alias; shared LB block commented template.
    - Instance: port, spot enable, retention days, volume size/type, key pair, AMI, server_types list, optional pool min/max.
    - Networking: VPC id, private/public subnets.
    - `port_mappings` list with health checks; supports custom backend protocol, matcher, rules.
    - `extra_tags` map; `extra_settings` (sample PORT/ASPNETCORE_URLS/Application Healthcheck URL). `custom_shared_rules` + `rule_mappings` for shared ALB rules.
  - `tags` map for EB env.

- **`inputs-LAMBDA-ENV.yaml` (AWS Lambda)**
  - `environment`, optional `runner_set`, `disable_deploy`, `dotnet_configuration` override.
  - `versions_bucket`, optional `logs_bucket`, `container_registry` (for image-based lambda if used).
  - `aws.region` and optional STS roles per stage.
  - **Lambda block:** `arch` (x86_64|arm64), `runtime` (dotnet9|dotnet8), `handler`, `environment.variables[]`, optional IAM/autogen execRole, policy attachments, statements, layers list, functionUrls list, schedule (single/multiple, flexible windows), VPC config, logging, tracing, ephemeral_storage, EFS, triggers (s3/sqs/dynamodb), alias routing, provisioned concurrency, reserved concurrency, memory/timeout.
  - `tags` map.

- **`inputs-KUBERNETES-ENV.yaml` (Generic K8s/Helm)**
  - `environment`, optional `runner_set`, `disable_deploy`, `dotnet_configuration` override.
  - `container_registry`, `cluster_name`, `namespace`.
  - Secrets/config: `secret_files` (enabled, files_path, mount_point), `config_map` (enabled, files_path, mount_point).
  - Helm: `helm_repo_url`, `helm_chart_name`/`helm_chart_path`, `helm_values_overrides` map (e.g., image.repository override), optional docker_args.
  - Cloud secret sync templates for Azure/AWS/GCP: resource groups or regions, keyvault/secret path filters, external_secrets configuration (create_store, store_name, refresh_interval, on_change), pod identity (managed identity / IAM role / GCP SA name).

- **`inputs-CLOUDRUN.yaml` (GCP Cloud Run)**
  - `environment`, optional `runner_set`, `disable_deploy`.
  - `container_registry` (required), `gcp.region`, `gcp.project_id`, optional impersonation SAs per stage.
  - DNS: enabled/private_zone/domain/alias_prefix. Alarms block similar to others.
  - **cloudrun block:** `type` (service|job|worker_pool); optional ingress, timeout, concurrency, working_dir, default_url_disabled.
    - Limits (cpu/memory/gpu), scaling (min/max/count/mode), environment variables and secrets, ports list, VPC connector + interfaces, volumes (secret, cloudsql, emptydir, gcs, nfs) + mounts, probes (liveness/readiness/startup with HTTP/GRPC/TCP), triggers (pubsub, cloud_storage with filters).

- **`inputs-APPENGINE.yaml` (GCP App Engine)**
  - `environment`, optional `runner_set`, `disable_deploy`.
  - `versions_bucket`, optional `blue_green`, `container_registry`.
  - `gcp.region`, `gcp.project_id`, optional impersonation per stage.
  - DNS/alarms blocks as above.
  - **appengine block:** runtime (dotnet9), `type` (standard|flexible), `entrypoint_shell`, IAM placeholder, instance class, auto/basic/manual scaling knobs, optional serverless connector, `http_handlers` list, `env_variables` map.

- **`inputs-LIB-ENV.yaml` (Library/no deploy)**
  - `environment`, optional `runner_set`, `dotnet_configuration` override.
  - Cloud secret filter stubs for Azure/AWS/GCP (used if publishing library artifacts only; no deploy infra in this template).

### 3) API Gateway definitions – `.cloudopsworks/vars/apigw`
- `apis-global.yaml`: provider (aws) + base API list (name/version).
- Per environment (`apis-dev.yaml`, `apis-uat.yaml`, `apis-prod.yaml`):
  - `environment` value; `apigw_definitions` entries with `name`, `version`, `mapping`, `domain_name`, `file_name`, optional `stage_variables`.
  - `aws` block: `stage`, `stage_only`, optional http_api flag, endpoint_type, VPC endpoints, disable_execute_api_endpoint, compression, xray, cache, vpc_link (rest_vpc_link_name), WAF, logging, publish_bucket backup, custom_parameters, stage_variables for backends, lambda_options (for HTTP APIs), authorizers (lambda-based) with function/role, optional VPC link via ALB (http_vpc_link), fail_on_warnings.

### 4) Helm values overrides – `.cloudopsworks/vars/helm`
- `values-dev.yaml`, `values-uat.yaml`, `values-prod.yaml` share same structure; ingress host differs. Notable keys (all optional unless noted):
  - Workload switches: `statefulset.enabled`, `daemonset.enabled`, `job.enabled`, `cronjob.enabled` (with restartPolicy).
  - Metadata: `annotations`, `podAnnotations`.
  - Scheduling: `affinity`, `tolerations`, `nodeSelector`.
  - Storage/volumes: `additionalVolumes`, `additionalVolumeMounts`.
  - Scaling: `replicaCount` (if Deployment/StatefulSet), `strategy` (RollingUpdate fields), `hpa` block with metrics and external metric example.
  - Env: `env` list, `envFrom`.
  - Probes: `probe.path` (default /health), `startupProbe.enabled`, optional liveness/readiness customizations.
  - Resources block (requests/limits) commented by default.
  - Ingress: `enabled`, `ingressClassName`, `rules` (host/path/backend service/port). Hosts set per env (DEV-URL/UAT-URL/PROD-URL) placeholder; service name `PROJECT_NAME-helm` port 80.
  - ServiceAccount block (create/use existing) commented.
  - KEDA block template for event-driven autoscaling with triggers.

### 5) Preview configs – `.cloudopsworks/vars/preview`
- `inputs.yaml` and `values.yaml` (Helm-compatible) plus placeholder directory. Preview follows same schema as Helm chart; only used when preview enabled in `inputs-global.yaml` and pipeline outputs `has_preview=true`.

## Helm Chart Options (from blueprint `kubernetes/helm/charts/values.yaml`)
Base defaults combined with env overrides above:
- Replica/service: `replicaCount`, `image.repository/tag/pullPolicy`, `strategy.type` (Recreate), service enabled (ClusterIP, externalPort 80, internalPort 8080), ingress disabled by default.
- Env: `env`, `envFrom`, `injectEnvFrom` for secrets/config, `knativeDeploy` flag, `terminationGracePeriodSeconds`.
- Probes: `probe.type/scheme/path` (/healthz), `livenessProbe`, `readinessProbe`, `startupProbe` (disabled by default).
- Resources: default empty.
- Tracing: `tracing.enabled`.
- Workload forms: `statefulset.enabled`, `daemonset.enabled`, `job.enabled`, `cronjob.enabled`.
- Scheduling: `affinity`, `tolerations`, `nodeSelector`.
- Volumes: `additionalVolumeMounts`, `additionalVolumes`, `injectedVolumeMounts`, `injectedVolumes`.
- Ingress: `enabled`, `path`, `pathType`, `ingressClass`, `annotations`, `tls.enabled`.
- Config/secret injection: `configMap.enabled/values`, `secret.enabled/values`.
- ServiceAccount: `enabled`, `create`, annotations/name.
- Autoscaling: `hpa` block (CPU/memory targets, external metric stub); `keda.enabled` with advanced options and `triggers` map (user supplied).
- Canary (Istio/Flagger): `canary.enabled`, analysis intervals/thresholds, metrics (success rate/duration), host placeholder `acme.com`.

## .NET Sample (HelloWorldApi)
Minimal ASP.NET Core API with endpoints:
- `GET /health` returns service health.
- `GET /hello` returns a hello payload (`HelloController`, `HealthController`).
- Tests: unit tests in `HelloWorldApi.Tests`, integration tests in `HelloWorldApi.Tests.Integration` for health endpoint.
This code is illustrative only; replace with real application logic.

## Usage Notes
- Use **one** environment input file per deployed environment; align with `cloud_type` and target cloud.
- Fill required placeholders: registry, regions, project IDs, buckets, VPC/subnets, DNS, IAM roles, certificates.
- Enable security tools (Snyk/Semgrep/Sonar/DependencyTrack) as needed in `inputs-global.yaml`.
- For API Gateway, ensure definitions under `vars/apigw` match `apis.enabled` toggle.
- For Helm/K8s, combine base chart defaults with env-specific overrides under `vars/helm`.
- Blue/green only applies to Beanstalk/AppEngine via `blue_green` in env inputs and is honored by `deploy-blue-green.yml`.

## Quick Start Checklist (fill before running pipelines)
1) Set `repository_owner`, org, env name in `inputs-global.yaml`.
2) Choose cloud & `cloud_type`; set runner_set if using self-hosted.
3) Complete global tooling toggles (security, observability, preview, apis).
4) Pick the correct env input file (Beanstalk/Lambda/Kubernetes/CloudRun/AppEngine/Lib) and fill cloud specifics, DNS, alarms, IAM, registry.
5) If using APIs, complete `apigw` per environment and `apis-global.yaml`.
6) For K8s, adjust Helm overrides in `vars/helm/values-<env>.yaml` and confirm chart values satisfy your app (ports, probes, ingress hosts).
7) Set secrets/vars in GitHub repository/ORG: BOT_TOKEN, registry creds, cloud creds, Sonar/Snyk/Semgrep/DTrack tokens, runner sets, default regions/projects.
8) Trigger `pr-build` for preview/validation; merge to develop/release/support to deploy per `cloudopsworks-ci.yaml` mapping.
