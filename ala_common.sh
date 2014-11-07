#!/bin/bash

# all ALA projects should use/source this value from this script
export ALA_MAVEN_REPO_URL="http://nexus.ala.org.au/content/repositories"

# we do not need this, if a custom <id> is NOT set (NOT used), and therefore NOT passed to maven deploy:deploy-file mojo in repositoryID
# maven will look for the "default" <id>remote-repository</id> in ~/.m2/settings.xml
export ALA_MAVEN_REPO_ID="ala-repo"

# deafult groupId for ALA projects
export ALA_MAVEN_GROUP_ID="au.org.ala"
