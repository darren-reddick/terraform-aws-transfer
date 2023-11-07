ifndef PR_NUMBER
$(error PR_NUMBER is not set)
else
ENVIRONMENT = "$(PR_NUMBER)-tfaws"
endif

ifndef TERRAFORM_STATE_BUCKET
$(error TERRAFORM_STATE_BUCKET is not set)
endif

.PHONY: test
test: init plan apply e2e

.PHONY: init
init:
	@terraform init -reconfigure -backend-config="key=$(PR_NUMBER)/terraform.state" -backend-config="bucket=$(TERRAFORM_STATE_BUCKET)" \
		-backend-config="region=eu-west-1" -no-color
	@terraform validate -no-color

.PHONY: plan
plan:
	@echo Building terraform plan
	@terraform plan -var "stage=$(ENVIRONMENT)" -refresh=true -out=plan.out

.PHONY: apply
apply:
	@echo Deploying test infrastructure to ephemeral environment $(ENVIRONMENT) 
	@terraform apply -no-color -auto-approve plan.out

.PHONY: destroy
destroy:
	@echo Destroying environment
	@terraform destroy -var "stage=pr${PR_NUMBER}-tfaws" -auto-approve

.PHONY: e2e
e2e:
	@echo "Running e2e tests"
	$(SHELL) /tmp/e2e-tests.sh

