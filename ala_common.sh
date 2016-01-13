#!/bin/bash

export TZ=Australia/Canberra
date

# all ALA projects should use/source this value from this script
export ALA_MAVEN_REPO_URL="http://nexus.ala.org.au/content/repositories"

# we do not need this, if a custom <id> is NOT set (NOT used), and therefore NOT passed to maven deploy:deploy-file mojo in repositoryID
# maven will look for the "default" <id>remote-repository</id> in ~/.m2/settings.xml
export ALA_MAVEN_REPO_ID="ala-repo"

# default groupId for ALA projects
export ALA_MAVEN_GROUP_ID="au.org.ala"

# default to SNAPSHOT maven repo
MAVEN_REPO="ala-repo-snapshot";

function ala_travis_grails_setup_env {
    rm -rf ~/.sdkman
    curl -s http://get.sdkman.io | bash

    echo "sdkman_auto_answer=true" > ~/.sdkman/etc/config
    source ~/.sdkman/bin/sdkman-init.sh

    local grails_version
    grails_version=`grep '^app\.grails\.version=' ./application.properties | sed -e 's/^app\.grails\.version=//g'`
    sdk install grails $grails_version || true

    mkdir -p ~/.grails
    wget -q -O ~/.grails/settings.groovy https://raw.githubusercontent.com/AtlasOfLivingAustralia/travis-build-configuration/master/travis_grails_settings_old.groovy

    # check if this is a grails application OR a plugin
    # - grails plugins are storing their version number in the WhateverGrailsPlugin.groovy file
    # - grails applications in the application.properties file
    local app_version
    if [ -f ./*GrailsPlugin.groovy ]
    then
	app_version=`grep '^\s*def\s*version' *GrailsPlugin.groovy | sed -e 's/^.*= *"//g' | sed -e 's/".*$//g' | tr -d "\r"`
    else
	app_version=`grep '^app\.version=' ./application.properties`
    fi

    echo $app_version | grep -q "\-SNAPSHOT"
    if [ "$?" = "1" ]; then
	MAVEN_REPO="ala-repo-release"
    fi

    # TODO: if we got here and we still do not MAVEN_REPO set we have a problem, report an ERROR
}

function ala_travis_grails_build {
    grails clean && grails refresh-dependencies --non-interactive && grails prod maven-install --non-interactive && travis_retry grails prod maven-deploy --repository=$MAVEN_REPO --non-interactive
}

function ala_travis_grails_test {
    grails test-app --non-interactive
}

function ala_travis_grails_deploy {
    [ "${TRAVIS_PULL_REQUEST}" = "false" ] && travis_retry grails prod maven-deploy --repository=$MAVEN_REPO --non-interactive
}
