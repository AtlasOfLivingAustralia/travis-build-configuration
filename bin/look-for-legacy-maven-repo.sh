#!/bin/bash

TIMESTAMP_START=`TZ='Australia/Canberra' date "+%Y-%m-%d %H:%M:%S"`

# we need at least two args: gihub user/organization AND at least one repo name
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 [github user/organization] repo0 repo1 repo2 ... repoN"
    exit 1;
fi

GITHUB_USER_ORG=$1

# args 2, 3, 4 ... N are repo names, so skip arg1 required/positional args to adjust $@
shift 1
GITHUB_REPOS="$@"
SUMMARY=`mktemp /tmp/${temp}.XXXXXX` || exit 1

for repo in $GITHUB_REPOS
do
    application_properties=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties`
    if [ "$application_properties" -eq "200" ]; then
	TEST=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/grails-app/conf/BuildConfig.groovy | grep -n "maven\.ala\.org\.au"`
        if [ "$?" = "0" ]; then
	    echo "$GITHUB_USER_ORG/$repo" > SUMMARY
	    echo "$TEST"                 >> SUMMARY
	    echo ""                      >> SUMMARY
	    cat SUMMARY
	fi
    fi

    pom_xml=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml`
    if [ "$pom_xml" -eq "200" ]; then
	TEST=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/pom.xml | grep -n "maven\.ala\.org\.au"`
        if [ "$?" = "0" ]; then
	    echo "$GITHUB_USER_ORG/$repo" > SUMMARY
	    echo "$TEST"                 >> SUMMARY
	    echo ""                      >> SUMMARY
	    cat SUMMARY
	fi
    fi

done
