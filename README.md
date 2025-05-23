# dotnet-app-template
.Net Application Template with Github Action Gitops

## Build Targets

### code/init

Initializes a new .NET project by:

- Renames solution and project files from HelloWorldApi to the target project name
- Updates project references in solution and test projects
- Updates assembly names and versions in project files
- Configures GitHub workflow variables

### version

Manages version numbering by:

- Creates/updates VERSION file with semantic version
- Updates AssemblyVersion and Version in project files
- Handles both tagged versions and GitVersion-generated versions
- Converts '+' to '-' in versions for helm/docker compatibility

