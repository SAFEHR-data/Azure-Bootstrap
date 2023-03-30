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

terraform {
  before_hook "add_ip_exceptions" {
    commands     = ["apply"]
    execute      = ["${get_repo_root()}/scripts/modify_ip_exceptions.sh", "add"]
  }

  extra_arguments "auto_approve" {
    commands  = ["apply"]
    arguments = ["-auto-approve"]
  }

  after_hook "remove_ip_exceptions" {
    commands     = ["apply", "destroy"]
    execute      = ["${get_repo_root()}/scripts/modify_ip_exceptions.sh", "remove"]
    run_on_error = true
  }

  after_hook "clean_secrets_from_state" {
    commands     = ["apply"]
    execute      = ["${get_repo_root()}/scripts/clean_terraform_state.sh"]
    run_on_error = true
  }
}

# Generate Terraform variables from config.yaml file
inputs = merge(yamldecode(file("${get_repo_root()}/config.yaml")), {
  github_runner_token = get_env("GITHUB_RUNNER_PAT")
})
