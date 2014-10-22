#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: ./githubapi-get-all-repos.sh [github username] [your github token]"
    exit 1;
fi

GITHUB_USER_ORG=$1
GITHUB_TOKEN=$2

temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1

# single page result-s (no pagination), have no Link: section, the grep result is empty
last_page=`curl -s -I "https://api.github.com/users/$GITHUB_USER_ORG/repos" -H "Authorization: token $GITHUB_TOKEN" | grep '^Link:'`

# does this result use pagination?
if [ -z "$last_page" ]; then
    # no - this result has only one page
    curl -s -i "https://api.github.com/users/$GITHUB_USER_ORG/repos" -H "Authorization: token $GITHUB_TOKEN" | grep '"name":' >> $TMPFILE;

else
    # yes - this result is on multiple pages; extract the last_page number
    last_page=`echo $last_page | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'`

    p=1
    while [ "$p" -le "$last_page" ]; do
	curl -s -i "https://api.github.com/users/$GITHUB_USER_ORG/repos?page=$p" -H "Authorization: token $GITHUB_TOKEN" | grep '"name":' >> $TMPFILE
	p=$(($p + 1))
    done
fi

cat $TMPFILE | sed -e 's/^ *"name": "//g' -e 's/",$//g'
