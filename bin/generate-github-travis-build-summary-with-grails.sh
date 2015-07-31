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

MAVEN_REPO_URL='http://nexus.ala.org.au/content/repositories'

# create .md table header
echo "|repo|version|travis build status|grails|" >> $SUMMARY
echo "|:---|:------|:------------------|:-----|" >> $SUMMARY

for repo in $GITHUB_REPOS
do
    # if we do have a blacklist of repos, check if repo is blacklisted and if yes skip it
    if [ -e "blacklist.out" ]; then
	grep -q -w $repo blacklist.out
	if [ "$?" -eq 0 ]; then
	    continue
	fi
    fi

    # TODO: for now hardoced, grails plugin projects re-set this to "org/grails/plugins"
    ARTIFACT_GROUP_ID="au/org/ala"

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

	GRAILS_APP_NAME=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties | grep '^\s*app.name' | sed -e 's/^\s*app\.name=//g' | tr -d "\r"`

	# OK this repo HAS application.properties BUT we failed to find/extract app.version from it; so let's check if this is a grails plugin
	if [ "$ARTIFACT_VERSION_NUMBER" == "" ]; then
	    # first build the grails plugin file name: "ala-web-theme" => "AlaWebThemeGrailsPlugin.groovy"
	    GRAILS_PLUGIN_NAME=`(name=""; IFS='-'; for word in $GRAILS_APP_NAME; do name+=$(tr '[:lower:]' '[:upper:]' <<< ${word:0:1})${word:1}; done; echo "${name}GrailsPlugin.groovy")`

	    grails_plugin=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/$GRAILS_PLUGIN_NAME`

	    if [ "$grails_plugin" -eq "200" ]; then
		ARTIFACT_VERSION_NUMBER=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/$GRAILS_PLUGIN_NAME | grep '^\s*def\s*version' | sed -e 's/^.*= *"//g' | sed -e 's/".*$//g'`

		ARTIFACT_GROUP_ID="org/grails/plugins"
	    fi
	fi

    elif [ "$pom_xml" -eq "200" ]; then
	# TODO: this is an ugly hack; assuming that <parent> element (if present) in pom.xml is included BEFORE anything else; in this case we want to extract
	# //project/version NOT //project/parent/version; if we found </parent> we are assuming the artifact version is the next <version> bellow;
	# This should really be done properly with some XML/XPath aware tool.

	start_from_line=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | grep -n "</parent>" | sed "s/:.*$//g"`
	if [ "$start_from_line" == "" ]; then
	    # if we did not find </parent> element, we are starting from the top/beggining of the file, line 1
	    start_from_line=1
	fi

	ARTIFACT_VERSION_NUMBER=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | sed -n "${start_from_line},$ p" |  grep -m 1 '^\s*<version>' | sed -e 's/^.*<version>//g' -e 's/<\/.*$//g' | tr -d "\r"`

	ARTIFACT_GROUP_ID=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | sed -n "${start_from_line},$ p" |  grep -m 1 '^\s*<groupId>' | sed -e 's/^.*<groupId>//g' -e 's/<\/.*$//g' | tr -d "\r" | sed -e 's/\./\//g'`
    fi

    ARTIFACT_VERSION_NUMBER_PATH="N/A"
    ARTIFACT_MISSING_EMOJI=""

    if [ "$ARTIFACT_VERSION_NUMBER" != "" ]; then

	# default to "releases"; and reset to "snapshots" if the jar/war is a -SNAPSHOT
	SNAPSHOT_OR_RELEASE="releases"

	if [[ $ARTIFACT_VERSION_NUMBER == *SNAPSHOT* ]]; then
	    SNAPSHOT_OR_RELEASE="snapshots"
	fi

	# default is artifact (war name) is the same as the repo name
	ARTIFACT_ID=$repo

	# TMP HACK-AROUND: try to lookup the artifact name in a (repository to war name) lookup
	#                  table, if a match is found use it instead of the "default" repo name
	if [ -e "repo2war-name.lookup" ]; then
	    lookup_name=`grep '$repo\s' repo2war-name.lookup | sed -e "s/$repo.*://g"`
	    if [ "$lookup_name" != "" ]; then
		ARTIFACT_ID=$lookup_name
	    fi
	fi

	ARTIFACT_VERSION_NUMBER_PATH="$MAVEN_REPO_URL/$SNAPSHOT_OR_RELEASE/$ARTIFACT_GROUP_ID/$ARTIFACT_ID/$ARTIFACT_VERSION_NUMBER"

	# verify if the generated path/URL to the artifact actually does really exist, if not add a WARNING emoji/icon
	artifact_path=`curl -s -o /dev/null -w "%{http_code}" $ARTIFACT_VERSION_NUMBER_PATH`

	if [ "$artifact_path" -ge "400" ]; then
	    ARTIFACT_MISSING_EMOJI=":frog:"
	fi
    fi

    ARTIFACT_VERSION_NUMBER_MD="[$ARTIFACT_VERSION_NUMBER]($ARTIFACT_VERSION_NUMBER_PATH) $ARTIFACT_MISSING_EMOJI"

    echo "|[$repo](https://github.com/$GITHUB_USER_ORG/$repo)|$ARTIFACT_VERSION_NUMBER_MD|$TRAVIS_BADGE|$GRAILSVERSION|" >> $SUMMARY

done

# dump the repo2war-name.lookup lookup table used to generate the summary
echo "" >> $SUMMARY
echo "|repo name |war name |" >> $SUMMARY
echo "|:---------|:--------|" >> $SUMMARY

while read line; do
    repo_name=`echo $line | sed -e "s/ .*$//g"`
    war_name=`echo $line | sed -e "s/^.*://g"`
    echo "|$repo_name|$war_name|" >> $SUMMARY

done < repo2war-name.lookup

echo "" >> $SUMMARY
echo "[add/remove/edit mapping table](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/edit/master/bin/repo2war-name.lookup)" >> $SUMMARY
echo "" >> $SUMMARY

cat $SUMMARY
