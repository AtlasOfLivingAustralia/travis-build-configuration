#!/bin/bash

# we need at least two args: gihub user/organization AND at least one repo name
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 [github user/organization] repo0 repo1 repo2 ... repoN"
    exit 1;
fi

GITHUB_USER_ORG=$1

# args 2, 3, 4 ... N are repo names, so skip arg1 required/positional args to adjust $@
shift 1
GITHUB_REPOS="$@"

temp=`basename $0`
SUMMARY=`mktemp /tmp/${temp}.XXXXXX` || exit 1

# create .md table header
echo "|repo|version|travis build status|grails|" >> $SUMMARY
echo "|:---|:------|:------------------|:-----|" >> $SUMMARY

for repo in $GITHUB_REPOS
do
    # default to N/A, not available, no travi-ci.org build status badge
    TRAVIS_BADGE="N/A"

    # use curl to check if the repo does have a .travis.yml file
    http_status=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/.travis.yml`

    if [ "$http_status" -eq "200" ]
    then
	TRAVIS_BADGE="[![Build Status](https://travis-ci.org/$GITHUB_USER_ORG/$repo.svg?branch=master)](https://travis-ci.org/$GITHUB_USER_ORG/$repo)"
    else
	# this is not a travis project
	continue
    fi

    # default to N/A, not a grails project
    GRAILSVERSION="N/A"

    # jar/war version number
    ARTIFACT_VERSION_NUMBER="N/A"

    # use curl to check if the repo does have an application.properties file, and if yes extract the grails version number
    application_properties=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties`

    # use curl to check if the repo does have an application.properties file
    pom_xml=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml`

    if [ "$application_properties" -eq "200" ]; then
	GRAILSVERSION=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties | grep '^\s*app.grails.version' | sed -e 's/^\s*app\.grails\.version=//g' | tr -d "\r"`

	ARTIFACT_VERSION_NUMBER=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties | grep '^\s*app.version' | sed -e 's/^\s*app\.version=//g' | tr -d "\r"`

    elif [ "$pom_xml" -eq "200" ]; then
	ARTIFACT_VERSION_NUMBER=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | grep -m 1 '^\s*<version>' | sed -e 's/^.*<version>//g' -e 's/<\/.*$//g' | tr -d "\r"`

    fi

    echo "|[$repo](https://github.com/$GITHUB_USER_ORG/$repo)|$ARTIFACT_VERSION_NUMBER|$TRAVIS_BADGE|$GRAILSVERSION|" >> $SUMMARY

done

cat $SUMMARY
