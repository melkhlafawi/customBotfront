#!/usr/bin/env bash

# This script takes the version from botfront/package.json and copies it to cli/package.json and cli/package-lock.json
# It is intented to be used in the "prerelease" hook of standard-version

PACKAGE_VERSION=$(cat ../botfront/package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g')

function set_version_package_files {
	search='("version":[[:space:]]*").+(")'
	replace="\1${2}\2"
	sed -i ".tmp" -E "s/${search}/${replace}/g" "$1"
	rm "$1.tmp"
}

function set_version_in_communico_yaml {
	search='(\/communico:v).+'
	replace="\1${2}"
	sed -i ".tmp" -E "s/${search}/${replace}/g" "$1"
	rm "$1.tmp"
}

set_version_package_files "../cli/package.json" $PACKAGE_VERSION
echo "Version $PACKAGE_VERSION set in cli/package.json"

# npm install will sync the version in the cli/package-lock.json
npm --prefix ../cli/ install --ignore-scripts

# Set Communico image version in the project template
set_version_in_communico_yaml '../cli/project-template/.communico/communico.yml' $PACKAGE_VERSION
echo "Version $PACKAGE_VERSION set in communico.yml"

# Copy the changelog at the root level
cp ../botfront/CHANGELOG.md ../
echo "Copy of CHANGELOG at the root of the project"
# Copy the main readme to the CLI so it is shown in npmjs.com
cp ../README.md ../cli/.
echo "Copy of README in the CLI project"

# Amend release commit with new and changed files
git add ../CHANGELOG.md
git add ../cli/README.md
git add ../cli/project-template/.communico/communico.yml
git add ../cli/package.json
git add ../cli/package-lock.json

git commit --amend --no-edit

