TF_DIR ?= environments/dev

.PHONY: init fmt validate lint plan apply destroy test

init:
	cd $(TF_DIR) && terraform init

fmt:
	terraform fmt -recursive

validate:
	cd $(TF_DIR) && terraform validate

lint:
	tflint --init
	tflint --recursive

plan:
	cd $(TF_DIR) && terraform plan -out=tfplan

apply:
	cd $(TF_DIR) && terraform apply tfplan

destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve

test:
	cd tests/go && go test -v ./...
