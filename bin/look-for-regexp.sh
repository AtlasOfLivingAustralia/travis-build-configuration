#!/bin/bash

TIMESTAMP_START=`TZ='Australia/Canberra' date "+%Y-%m-%d %H:%M:%S"`

# we need at least two args: gihub user/organization AND at least one repo name
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 [github user/organization] [regexp] repo0 repo1 repo2 ... repoN"
    exit 1;
fi

GITHUB_USER_ORG=$1
REGEXP=$2

# args 2, 3, 4 ... N are repo names, so skip arg1 required/positional args to adjust $@
shift 2
GITHUB_REPOS="$@"
SUMMARY=`mktemp /tmp/${temp}.XXXXXX` || exit 1

for repo in $GITHUB_REPOS
do
    application_properties=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties`
    if [ "$application_properties" -eq "200" ]; then
	TEST=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/grails-app/conf/BuildConfig.groovy | grep -n $REGEXP`
        if [ "$?" = "0" ]; then
	    GRAILSVERSION=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties | grep '^\s*app.grails.version' | sed -e 's/^\s*app\.grails\.version=//g' | tr -d "\r"`
	    echo "$GITHUB_USER_ORG/$repo (grails:$GRAILSVERSION)" > SUMMARY
	    echo "$TEST"                 >> SUMMARY
	    echo ""                      >> SUMMARY
	    cat SUMMARY
	fi
    fi

    pom_xml=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml`
    if [ "$pom_xml" -eq "200" ]; then
	TEST=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | grep -n $REGEXP`
        if [ "$?" = "0" ]; then
	    echo "$GITHUB_USER_ORG/$repo (pom.xml)" > SUMMARY
	    echo "$TEST"                 >> SUMMARY
	    echo ""                      >> SUMMARY
	    cat SUMMARY
	fi
    fi

done
