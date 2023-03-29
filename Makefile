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
MAKEFILE_FULLPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_FULLPATH))

all: deploy

deploy: az-login  ## Deploy all bootstrap resources
	${MAKEFILE_DIR}/scripts/modify_ip_exceptions.sh add \
	&& cd ${MAKEFILE_DIR}/deployment \
	&& terraform init \
	&& terraform apply -var-file="../config.tfvars" -auto-approve \
	&& ${MAKEFILE_DIR}/scripts/modify_ip_exceptions.sh remove \
	&& ${MAKEFILE_DIR}/scripts/clean_terraform_state.sh

destroy: az-login ## Destroy all bootstrap resources
	${MAKEFILE_DIR}/scripts/modify_ip_exceptions.sh add \
	&& cd ${MAKEFILE_DIR}/deployment \
	&& terraform destroy -var-file="../config.tfvars" -auto-approve

az-login:
	${MAKEFILE_DIR}/scripts/az_login.sh
