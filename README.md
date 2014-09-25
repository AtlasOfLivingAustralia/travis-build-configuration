##intro

[ALA](https://github.com/AtlasOfLivingAustralia) has as of today (2014-09-25) apx. 40 different grails projects. These projects are using https://travis-ci.org build system. After each grails project was successfully built travis-ci.org uses the grails release (formerly publisher) plugin to deploy the build artifacts into a maven repository.

To keep and access (shared/common) configuration files in this repository allows for easy/convenient configuration changes here in one place instead of going over 40 separate grails projects and making the same change for each of them. A typical example of this is changing/updating the maven repository URLs.
NOTE: If some of our grails projects for some reason can't or do not want to use this shared configuration, they simply maintain their own/specific configuration in the project's github repo.

This is how it works:

see the: `wget -q -O ~/.grails/settings.groovy https://raw.githubusercontent.com/AtlasOfLivingAustralia/travis-build-configuration/master/travis_grails_settings_old.groovy` in the .travis.yml bellow used to create the `~/.grails/settings.groovy` file on travis before building and deploying the grails project (actual example is taken from the volunteer-portal) project.

```yaml
language: groovy

jdk:
- oraclejdk7

branches:
  only:
  - master

before_install:
- rm -rf ~/.gvm
- curl -s get.gvmtool.net > ~/install_gvm.sh
- chmod 775 ~/install_gvm.sh
- "~/install_gvm.sh"
- echo "gvm_auto_answer=true" > ~/.gvm/etc/config
- source ~/.gvm/bin/gvm-init.sh
- GRAILS_VERSION=`grep '^app\.grails\.version=' ./application.properties | sed -e 's/^app\.grails\.version=//g'`
- gvm install grails $GRAILS_VERSION || true

before_script:
- mkdir -p ~/.grails; wget -q -O ~/.grails/settings.groovy https://raw.githubusercontent.com/AtlasOfLivingAustralia/travis-build-configuration/master/travis_grails_settings_old.groovy
- MAVEN_REPO="ala-repo-snapshot"; grep '^app\.version=' ./application.properties |
  grep -q "\-SNAPSHOT"; if [ "$?" = "1" ]; then MAVEN_REPO="ala-repo-release"; fi;

script: grails clean && grails upgrade --non-interactive && grails refresh-dependencies
  --non-interactive && grails prod war && grails prod maven-deploy --repository=$MAVEN_REPO

env:
  global:
  - secure: a+SmC0P+i7A8had0Aj3ZBTyQDs1VShLNgMtsplhct75lJSDRBzSgp5XX2kh7xlzmVIXA71m7RAjRsy1kQZgZoO6+vxGT35oE1zYSRYbcgNjD2kt67lceCyE1ncxvmiPpBTvhOs/eZ/dRkzbuU1HD0eEg3tR0bP+O8svBtRZAVqo=
  - secure: i46AlcEOx/CawVf4V9llRcLcFZrOvrFG2vBeIQ2WWuI0o+t3GYYV2Rd+uxEQ7f7OCzShZvRUb1KdhydObKYZGpbocvIAyKN3inw43UTWwXa3O1+F10+PpNdiFVC8QBCnHiTJ7AXti/EYymmepy9VNiONJhPirrom3XrxX3XhBBk=
```
