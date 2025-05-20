export PROJECT ?= $(shell basename $(shell pwd))
TRONADOR_AUTO_INIT := true

GITVERSION ?= $(INSTALL_PATH)/gitversion
GH ?= $(INSTALL_PATH)/gh
YQ ?= $(INSTALL_PATH)/yq

-include $(shell curl -sSL -o .tronador "https://cowk.io/acc"; echo .tronador)

## Version Bump and creates VERSION File - Uses always the FullSemVer from GitVersion (no need to prepend the 'v').
version: packages/install/gitversion packages/install/yq
	$(call assert-set,GITVERSION)
	$(call assert-set,YQ)
ifeq ($(GIT_IS_TAG),1)
	@echo "$(GIT_TAG)" | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+((-alpha|-beta).[0-9]?)?)(\+deploy-.*)?$$/\1/g' > VERSION
	@mvn --batch-mode versions:set -DnewVersion=$(shell echo "$(GIT_TAG)" | sed 's/^v//')
	@$(YQ) eval -i '.Project.PropertyGroup.AssemblyVersion = "$(shell echo "$(GIT_TAG)" | 's/^v([0-9]+\.[0-9]+\.[0-9]+)((-alpha|-beta).[0-9]?)?(\+deploy-.*)?$$/\1/g')"' $(PROJECT).sln
	@$(YQ) eval -i '.Project.PropertyGroup.Version = "$(shell echo "$(GIT_TAG)" | sed 's/^v//')"'
else
	# Translates + in version to - for helm/docker compatibility
	@echo "$(shell $(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-')" > VERSION
endif

# Modify pom.xml to change the project name with the $(PROJECT) variable
## Code Initialization for Node Project
code/init: packages/install/gitversion packages/install/gh packages/install/yq
	$(call assert-set,GITVERSION)
	$(call assert-set,GH)
	$(call assert-set,YQ)
	$(eval $@_OWNER := $(shell $(GH) repo view --json 'name,owner' -q '.owner.login'))
	@mv HelloWorldApi.sln $(PROJECT).sln
	@mv HelloWorldApi $(PROJECT)
	@mv HelloWorldApi.Test $(PROJECT).Test
	@mv HelloWorldApi.Test.Integration $(PROJECT).Test.Integration
	@mv $(PROJECT)/HelloWorldApi.csproj $(PROJECT)/$(PROJECT).csproj
	@mv $(PROJECT).Test/HelloWorldApi.Test.csproj $(PROJECT).Test/$(PROJECT).Test.csproj
	@mv $(PROJECT).Test.Integration/HelloWorldApi.Test.Integration.csproj $(PROJECT).Test.Integration/$(PROJECT).Test.Integration.csproj
	@$(YQ) eval -i '.dotnet.project_path = "$(PROJECT)"' .github/vars/inputs-global.yaml
	@$(YQ) eval -i '.Project.PropertyGroup.AssemblyName = "$(PROJECT)"' $(PROJECT)/$(PROJECT).csproj
	@$(YQ) eval -i '.Project.PropertyGroup.AssemblyName = "$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch | tr '+' '-')"' $(PROJECT)/$(PROJECT).csproj
ifeq ($(OS),darwin)
    @sed -i '' "s/HelloWorldApi/$(PROJECT)/g" $(PROJECT).sln
else
    @sed -i "s/HelloWorldApi/$(PROJECT)/g" $(PROJECT).sln
endif