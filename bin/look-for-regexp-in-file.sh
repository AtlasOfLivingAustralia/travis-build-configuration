#!/bin/bash

TIMESTAMP_START=`TZ='Australia/Canberra' date "+%Y-%m-%d %H:%M:%S"`

# we need at least two args: gihub user/organization AND at least one repo name
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: $0 [github user/organization] [regexp] [file] repo0 repo1 repo2 ... repoN"
    exit 1;
fi

GITHUB_USER_ORG=$1
REGEXP=$2
FILEPATH=$3
echo "REGEXP:$REGEXP"
echo "FILEPATH:$FILEPATH"

# args 2, 3, 4 ... N are repo names, so skip arg1 required/positional args to adjust $@
shift 3
GITHUB_REPOS="$@"
SUMMARY=`mktemp /tmp/${temp}.XXXXXX` || exit 1

for repo in $GITHUB_REPOS
do
    application_properties=`curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/application.properties`
    if [ "$application_properties" -eq "200" ]; then
	TEST=`curl -s https://raw.githubusercontent.com/$GITHUB_USER_ORG/$repo/master/$FILEPATH | grep -n $REGEXP`
        if [ "$?" = "0" ]; then
	    echo "$GITHUB_USER_ORG/$repo" > SUMMARY
	    echo "$TEST"                 >> SUMMARY
	    echo ""                      >> SUMMARY
	    cat SUMMARY
	fi
    fi
done
