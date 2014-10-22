#!/bin/bash

# TODO: run a requirements check? check for wget, curl, travis client, etc?
# travis client is /usr/bin/travis2.0 on my openSUSE13.1 laptop, while the mac os x uses /usr/bin/travis
TRAVIS_CLIENT=/usr/bin/travis2.0
OVERWRITE_MODE=0



# WARNING: github is case insensitive, the travis/tavis client *IS* case sensitive
#          i found out when: 'travis encrypt -r atlasoflivingaustralia/reponame ...' FAILED, while
#          'travis encrypt -r AtlasOfLivingAustralia/reponame ...' works OK
#
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ ! -e "$3" ] || [ -z "$4" ]; then
    echo "usage: ./github-add-travis.sh [github-token] [github username/organization] [env var file] [repo0] [repo1] [repo2] ... [repoN]"
    exit 1;
fi

GITHUB_TOKEN=$1
GITHUB_USER_ORG=$2
VARS_TO_ENCRYPT=`cat $3`

# args 4, 5, 6 ... N are repo names, so skip the first 3 required/positional args to adjust $@
shift 3
GITHUB_REPOS="$@"
echo $GITHUB_REPOS

TMP_DIR=/tmp/github-add-travis
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

# TODO: check logins at the start, do not bother if they failed
$TRAVIS_CLIENT login --github-token $GITHUB_TOKEN

for repo in $GITHUB_REPOS
do
    cd $TMP_DIR
    rm -rf $repo

    git clone git@github.com:$GITHUB_USER_ORG/$repo.git

    cd $repo
    if [ -e ".travis.yml" ]
    then
	echo "$repo alrady has .travis.yml..."
	echo
	if [ "$OVERWRITE_MODE" -eq "1" ]; then
	    echo "OVERWRITE_MODE is ON, replacing/overwriting files..."

	else
	    echo "OVERWRITE_MODE is OFF, skipping..."
	    cd $TMP_DIR
	    rm -rf $repo
	    continue

	fi
    fi

    # TODO: this should be case statement case: grails or java or whatever...

    # TODO: make this check if is this a grails project safer/specific; grep for grails app?
    if [ -e "application.properties" ]
    then
	# download/copy in the grails project .travis template, TODO: add support for a custom .travis.yml template/boilerplate later
	wget -q -O .travis.yml https://raw.githubusercontent.com/AtlasOfLivingAustralia/travis-build-configuration/master/doc/travis-grails_template.yml

	if [ "$OVERWRITE_MODE" -ne "1" ]; then
	    GRAILS_VERSION=`grep '^app\.grails\.version=' ./application.properties | sed -e 's/^app\.grails\.version=//g'`
	    echo "GRAILS_VERSION:$GRAILS_VERSION"

	    # GRAILS_VERSION_NUMBER:             2.3.11       => 2.3              => 23
	    GRAILS_VERSION_NUMBER=`echo $GRAILS_VERSION | sed -e 's/\.[0-9]*$//g' -e 's/\.//g'`
	    echo "GRAILS_VERSION_NUMBER:$GRAILS_VERSION_NUMBER"

	    if [ "$GRAILS_VERSION_NUMBER" -lt "23" ]; then
		echo "GRAILS OLD ( < 2.3)"

		# TODO: grep/check if the plugin is already included in application.properties, if not add it:
		echo "plugins.maven-publisher=0.8.1" >> application.properties
		git add application.properties

	    else
		echo "GRAILS NEW (>= 2.3)"

		cat grails-app/conf/BuildConfig.groovy | sed 's/^    plugins {/    plugins {~        build ":release:3\.0\.1"/; y/~/\n/;' > tmp.groovy
		mv tmp.groovy grails-app/conf/BuildConfig.groovy
		git add grails-app/conf/BuildConfig.groovy

	    fi
	fi
    fi

    if [ -e "pom.xml" ]
    then
	# download/copy in the java (pom.xml based maven project) template
	wget -q -O .travis.yml https://raw.githubusercontent.com/AtlasOfLivingAustralia/travis-build-configuration/master/doc/travis-java_template.yml

	if [ "$OVERWRITE_MODE" -ne "1" ]; then
	    # does the pom.xml already have/contain <distributionManagement> ?; if not then add <distributionManagement>
	    grep '</distributionManagement>' ./pom.xml
	    if [ "$?" = "1" ]
	    then
		# remove the closing </project> tag first ...
		cat pom.xml | sed -e 's/<\/project>//g' > tmp.pom
		mv tmp.pom pom.xml

		# ... and append <distributionManagement> to the end of the pom.xml file
		echo "        <distributionManagement>"                                                                       >> pom.xml
		echo "                <repository>"                                                                           >> pom.xml
		echo "                        <id>ala-repo</id>"                                                              >> pom.xml
		echo "                        <name>Internal Releases</name>"                                                 >> pom.xml
		echo "                        <url>http://ala-wonder.it.csiro.au/nexus/content/repositories/releases/</url>"  >> pom.xml
		echo "                </repository>"                                                                          >> pom.xml
		echo "                <snapshotRepository>"                                                                   >> pom.xml
		echo "                        <id>ala-repo</id>"                                                              >> pom.xml
		echo "                        <name>Internal Releases</name>"                                                 >> pom.xml
		echo "                        <url>http://ala-wonder.it.csiro.au/nexus/content/repositories/snapshots/</url>" >> pom.xml
		echo "                </snapshotRepository>"                                                                  >> pom.xml
		echo "        </distributionManagement>"                                                                      >> pom.xml
		echo "</project>"                                                                                             >> pom.xml

		git add pom.xml
	    fi
	fi
    fi

    # TODO: add support for more project types (android/gradle, etc.)

    # this is a simple guard/check if we were successful in identifying/determing the type of app/project (for now only grails and pom.xml based apps/projects
    # are supported/handled); in other words if at this stage there was no .travis.yml file created, there is not much we could do, as in no need to encrypt
    # env vars, no need to add travis-ci.org build status badge to the README.md file; there are no new/added, nor any modified files, nothing to do, skip.
    if [ ! -e ".travis.yml" ]
    then
	echo "$repo: project type unknown, skipping..."
	echo
	cd $TMP_DIR
	rm -rf $repo
	continue
    fi

    # enable travis-ci.org support for this github project; this is to avoid the need to use manually the travis-ci.org webinterface/GUI flipping
    # the ON/OFF button to enable travis-ci.org; if travis-ci.org is already enabled this call has no effect.
    $TRAVIS_CLIENT enable --org --no-interactive

    # do NOT attempt a trais-ci.org build if there is no .travis.yml file present in the repo
    $TRAVIS_CLIENT settings builds_only_with_travis_yml --enable --no-interactive

    # do NOT build pull requests from travis-ci.org, OR alternatively leave this setting enabled AND use the TRAVIS_PULL_REQUEST env var
    # passed/populated by travis-ci.org; for example if TRAVIS_PULL_REQUEST is set to "true" you can build a pull request BUT skip
    # the deployment from travis-ci.org into your (remote) maven repo.
    #
    $TRAVIS_CLIENT settings build_pull_requests --disable --no-interactive

    # TODO: add support for setting (un-encrypted) env variables: '$TRAVIS_CLIENT env set NAME VALUE',
    #       for example: '$TRAVIS_CLIENT env set ALA_MAVEN_REPO_HOST ala-wonder.it.csiro.au'
    #       HOWEVER when i just tested this it *did* encrpyt the env vars too, so we might simply generate a list of those directly into
    #       .travis.yml env global section at this spot (before running travis encrypt):
    #       env:
    #         global:
    #           - ALA_MAVEN_REPO_HOST=ala-wonder.it.csiro.au
    #           - ALA_MAVEN_REPO_PORT=80

    # encrypt and add env variables to .travis.yml
    for v in $VARS_TO_ENCRYPT
    do
	# encrypt env variables, for example: TRAVIS_DEPLOY_USERNAME, TRAVIS_DEPLOY_PASSWORD, etc.
	$TRAVIS_CLIENT encrypt -a -p -r $GITHUB_USER_ORG/$repo "$v"
    done

    git add .travis.yml

    # if README.md does NOT exist (yet) create one
    if [ ! -e "README.md" ]
    then
	touch README.md
    fi

    # does the README.md file already contain travis-ci.org build status badge?
    grep "https://travis-ci\.org/$GITHUB_USER_ORG/$repo\.svg" ./README.md
    if [ "$?" -eq "1" ]
    then
	# NOTE: given this is not a fully automated process, we do not handle bracnhes, etc. the README.md may need to be adjusted manually
	echo "### $repo   [![Build Status](https://travis-ci.org/$GITHUB_USER_ORG/$repo.svg?branch=master)](https://travis-ci.org/$GITHUB_USER_ORG/$repo)" >> ./HEADER.md
	cat README.md >> HEADER.md
	mv HEADER.md README.md
	git add README.md
    fi

    git commit -m "GENERATED: adding travis-ci.org support (OVERWRITE_MODE=$OVERWRITE_MODE)"

    # push/publish all the changes we made
    git push

    # cleanup the working dir; current size of all AtlasOfLivingAustralia github repos clone is 1.8G
    cd $TMP_DIR
    rm -rf $repo
    echo

done
