#!/bin/bash

if [ ${#@} -lt 2 ]; then
    echo "usage: ./githubapi-get-all-repos.sh [github username] [your github token] --no-forks"
    exit 1;
fi

GITHUB_USER_ORG=$1
GITHUB_TOKEN=$2
NO_FORKS=`if [ "$3" = "--no-forks" ]; then echo "1"; fi`

temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1
TMPFILE_REPOS=`mktemp /tmp/${temp}.XXXXXX` || exit 1
TMPFILE_FORKS=`mktemp /tmp/${temp}.XXXXXX` || exit 1

# TODO: option --no-forks, or even better use popt

function rest_call {
    curl -s -i $1 -H "Authorization: token $GITHUB_TOKEN" > $TMPFILE
    cat $TMPFILE | grep '"name":' >> $TMPFILE_REPOS;
    cat $TMPFILE | grep '"fork":' >> $TMPFILE_FORKS;
}

# single page result-s (no pagination), have no Link: section, the grep result is empty
last_page=`curl -s -I "https://api.github.com/users/$GITHUB_USER_ORG/repos" -H "Authorization: token $GITHUB_TOKEN" | grep '^Link:'`

# does this result use pagination?
if [ -z "$last_page" ]; then
    # no - this result has only one page
    rest_call "https://api.github.com/users/$GITHUB_USER_ORG/repos"
else
    # yes - this result is on multiple pages; extract the last_page number
    last_page=`echo $last_page | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'`

    for p in `seq 1 $last_page`; do
	rest_call "https://api.github.com/users/$GITHUB_USER_ORG/repos?page=$p"
    done
fi

cat $TMPFILE_REPOS | sed -e 's/^ *"name": "//g' -e 's/",$//g' > $TMPFILE

if [ "$NO_FORKS" = "1" ]; then
    all_repos=(`cat $TMPFILE`)

    # for each repo that is NOT a fork, extract/dump repo name
    for index in `grep -n "false" $TMPFILE_FORKS | sed -e 's/:.*$//g'`; do
	echo "${all_repos[$index - 1]}"
    done
else
    cat $TMPFILE
fi
