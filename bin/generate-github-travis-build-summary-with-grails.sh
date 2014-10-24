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

MAVEN_REPO_URL='http://ala-wonder.it.csiro.au/nexus/content/repositories'

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
	TRAVIS_BADGE="[![BuildStatus](https://travis-ci.org/$GITHUB_USER_ORG/$repo.svg?branch=master)](https://travis-ci.org/$GITHUB_USER_ORG/$repo)"
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

    ARTIFACT_VERSION_NUMBER_PATH="N/A"

    if [ "$ARTIFACT_VERSION_NUMBER" != "" ]; then

	# default to "releases"; and reset to "snapshots" if the jar/war is a -SNAPSHOT
	SNAPSHOT_OR_RELEASE="releases"

	if [[ $ARTIFACT_VERSION_NUMBER == *SNAPSHOT* ]]; then
	    SNAPSHOT_OR_RELEASE="snapshots"
	fi

	# TODO: for now hardoced
	ARTIFACT_GROUP_ID="au/org/ala"

	# TODO: for now simple
	ARTIFACT_ID=$repo

	ARTIFACT_VERSION_NUMBER_PATH="$MAVEN_REPO_URL/$SNAPSHOT_OR_RELEASE/$ARTIFACT_GROUP_ID/$ARTIFACT_ID/$ARTIFACT_VERSION_NUMBER"

	# verify if the generated path/URL to the artifact actually does really exist, if not add a WARNING emoji/icon
	ARTIFACT_MISSING_EMOJI=""

	artifact_path=`curl -s -o /dev/null -w "%{http_code}" $ARTIFACT_VERSION_NUMBER_PATH`

	if [ "$artifact_path" -ge "400" ]; then
	    ARTIFACT_MISSING_EMOJI=":frog:"
	fi

	ARTIFACT_VERSION_NUMBER_MD="[$ARTIFACT_VERSION_NUMBER]($ARTIFACT_VERSION_NUMBER_PATH) $ARTIFACT_MISSING_EMOJI"

    fi

    echo "|[$repo](https://github.com/$GITHUB_USER_ORG/$repo)|$ARTIFACT_VERSION_NUMBER_MD|$TRAVIS_BADGE|$GRAILSVERSION|" >> $SUMMARY

done

cat $SUMMARY
