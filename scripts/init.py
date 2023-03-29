#!/usr/bin/env python3
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
import os
import functools

from shutil import which
from pathlib import Path


REPO_ROOT_DIR = Path(os.path.dirname(os.path.abspath(__file__)), "..")


def log(string: str):
    def decorator(function):
        @functools.wraps(function)
        def wrapper():
            print(f"{string}...", end="")
            function()
            print("done")

        return wrapper

    return decorator


@log("Checking dependencies")
def check_dependiences() -> None:
    for cli in ("az", "terraform"):
        if which(cli) is None:
            exit(f"Dependency missing: {cli}")


def create_config_file() -> None:
    def _processed(_line: str) -> str:
        if "=" not in line:  # Any non key-value pairs are ignored
            return line.strip("\n")

        line_no_comment = line if "#" not in line else line.split("#")[0]
        key, default_value = line_no_comment.split("=")
        key = key.strip()
        default_value = default_value.replace('"', "").strip()
        default_prompt = "" if default_value == "__CHANGE_ME__" else f"[Default: {default_value}]"

        value = input(f"Please enter a value for {key}: {default_prompt} ") or default_value
        assert value != "__CHANGE_ME__", f"Value of {key} must be defined"

        return f'{key:40s} = "{value}"'

    with open(Path(REPO_ROOT_DIR, "config.tfvars"), "w") as config_file:
        for line in open(Path(REPO_ROOT_DIR, "config.sample.tfvars"), "r"):
            print(_processed(line), file=config_file)


@log("Modifying .gitignore to allow checkin config and state")
def modify_gitignore_file() -> None:
    checked_in_filenames = ("config.tfvars", "terraform.tfstate")
    gitignore_path = Path(REPO_ROOT_DIR, ".gitignore")

    gitignore_lines = open(gitignore_path, "r").readlines()

    with open(gitignore_path, "w") as gitignore_file:
        for line in gitignore_lines:
            if any(filename == line.strip() for filename in checked_in_filenames):
                line = f"!{line}"
            print(line, file=gitignore_file, end="")


if __name__ == "__main__":
    print("Running setup for Azure-Bootstrap")
    check_dependiences()
    create_config_file()
    modify_gitignore_file()
