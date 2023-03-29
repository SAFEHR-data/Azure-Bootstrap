#  Copyright (c) University College London Hospitals NHS Foundation Trust
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.

SHELL:=/bin/bash

all: deploy

deploy:  ## Deploy all bootstrap resources
	./scripts/modify_storage_ip_exception.sh add \
	cd ./deployment \
	&& terraform init \
	&& terraform apply -var-file="../config.tfvars" -auto-approve \
	&& ./scripts/modify_storage_ip_exception.sh remove \
	&& terraform state rm module.build-agent.random_password.gh_runner_vm

destroy: ## Destroy all bootstrap resources
	./scripts/modify_storage_ip_exception.sh add \
	&& cd ./deployment \
	&& terraform destroy -var-file="../config.tfvars" -auto-approve
