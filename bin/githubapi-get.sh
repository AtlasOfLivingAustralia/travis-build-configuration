#!/bin/bash

set -e

if [ ${#@} -lt 2 ]; then
    echo "usage: $0 [your github token] [REST expression]"
    exit 1;
fi

GITHUB_TOKEN=$1
GITHUB_API_REST=$2

# TODO: we have to allow for passing new/custom Accept header-s form the cmd line,
#       and/or setup a lookup table of accept headers from the known headers?
#GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
#GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.sersi-preview+json"
GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.drax-preview+json"

temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1

# single page result-s (no pagination), have no Link: section, the grep result is empty
last_page=`curl -s -I "https://api.github.com${GITHUB_API_REST}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'`

# does this result use pagination?
if [ -z "$last_page" ]; then
    # no - this result has only one page
    curl -s "https://api.github.com${GITHUB_API_REST}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" >> $TMPFILE
    cat $TMPFILE

else
    # yes - this result is on multiple pages
    for p in `seq 1 $last_page`; do
	curl -s "https://api.github.com${GITHUB_API_REST}?page=$p" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" | sed -e 's/^\[$//g' -e 's/^\]$/,/g' >> $TMPFILE
    done

    # return the multipage JSON result-s as a JSON array
    line_counter=`wc -l $TMPFILE | sed -e 's/[/a-zA-Z].*$//g'`

    echo "["
    head -n $(($line_counter - 1)) $TMPFILE
    echo "]"

fi

