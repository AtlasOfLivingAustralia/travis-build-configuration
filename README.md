This repo contains all the information, configuration, and scripts required/used for building [ALA](https://github.com/AtlasOfLivingAustralia) projects on [travis-ci.org](https://travis-ci.org).

See the [doc/](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/tree/master/doc) subdir for information.  
See the [bin/](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/tree/master/bin) subdir for helper scripts and even more information.

## Step-by-step guide to add travis-ci.org support to a github repo/project 

### Prerequirements
* github token, hereafter refered to as `$GITHUB_TOKEN`
* ruby/gem to install the travis client: `sudo gem install travis`

### Adding travis-ci support
**1.** git clone the project/repository you want to add travis support to, and cd into the clone  
**2.** what type of project is it? Choose the appropriate `.travis.yml` template and copy it into the root of your git repo/project
* [grails application or plugin .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-grails-app-or-plugin_template.yml)
* [pom.xml/mvn project .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-java_template.yml)
* [ansible project .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-ansible_template.yml) and continue to [ansible travis-ci howto](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/tree/master/doc/ansible-playbook-from-travis.md)
* [android project .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-android_template.yml)
* **DON'T USE** These are here only for historic :-) reason the above grails template handles **BOTH** grails application **AND** grals plugin projects
  * ~~[grails application .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-grails_template.yml)~~
  * ~~[grails plugin .travis.yml template](https://github.com/AtlasOfLivingAustralia/travis-build-configuration/blob/master/templates/travis-grails-plugin_template.yml)~~

**3.** add the .travis.yml file to your git repo/project:
```
git add .travis.yml
```
**4.** Use the travis client to login:  
```
travis login --github-token $GITHUB_TOKEN
```
**5.** Enable travis-ci.org support for this github repo/project  
```
travis enable --org --no-interactive
```
**6.** OPTIONAL step, configure/customize some of the travis-ci.org settings:
```
travis settings builds_only_with_travis_yml --enable --no-interactive
travis settings build_pull_requests --disable --no-interactive
```
**7.** ENCRYPT and add to `.travis.yml` **all** the encrypted env vars your git project uses/requires to build/test on travis-ci.org:
```
travis encrypt -a -p "TRAVIS_DEPLOY_USERNAME=<<MAVEN_REPO_USER_NAME>>"
travis encrypt -a -p "TRAVIS_DEPLOY_PASSWORD=<<MAVEN_REPO_PASSWORD>>"
```
note: ```<<MAVEN_REPO_USER_NAME>> &  <<MAVEN_REPO_PASSWORD>>``` are placeholders. Replace them with username and password of nexus repository.

**8.** Add your changes to git
```
git add .travis.yml
```
**9.** Add travis-ci build status badge to your README.md file, and add it to the git (`$repo` is your github repo/project name):
```
echo "### $repo   [![Build Status](https://travis-ci.org/AtlasOfLivingAustralia/$repo.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/$repo)" > README.md

git add README.md
```
**10.** for grails application and grails plugin projects you need to add the release/publisher plugin to your grails project settings:
* for grails < 2.3 add `plugins.maven-publisher=0.8.1` to your `application.properties`, and `git add application.properties` 
* for grails >=2.3 add `build ":release:3.0.1"` to your `grails-app/conf/BuildConfig.groovy`, and `git add grails-app/conf/BuildConfig.groovy`

**11.** finally commit and push your changes to git/github
```
git commit -m "added travis-ci.org support"
git push
```
