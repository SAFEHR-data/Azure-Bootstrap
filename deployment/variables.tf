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
#  limitations under the License.

variable "suffix" {
  description = "Unique suffix to apply to resource names/ids"
  type        = string

  validation {
    condition     = length(var.suffix) <= 12
    error_message = "Must be 12 chars or less"
  }

  validation {
    condition     = can(regex("^[a-z0-9\\_-]*$", var.suffix))
    error_message = "Cannot contain spaces, uppercase or special characters except '-' and '_'"
  }
}

variable "location" {
  description = "The location to deploy resources"
  type        = string

  validation {
    condition     = can(regex("[a-z]+", var.location))
    error_message = "Only lowercase letters allowed"
  }
}

variable "tags" {
  description = "Map of string to add as resource tags to all deployed resources"
  type        = map(string)
  default     = {}
}
