## MOST RECENT UPDATE:
the following grails projects do **NOT** use grails maven publisher/release plugin, but use maven directly in order to deploy the build artifact into the maven repository:
- bie-webapp2
- fielddata
- sightings
- specimenbrowser

---

## Intro
The [ALA](https://github.com/AtlasOfLivingAustralia) applications/components can be divided into 3 diff groups/types according to the build system they use:

* `jenkins-mvn`/`maven` - maven project, build with maven, deployed into a maven repo using hudons/jenkins maven plugin
* `grails-mvn`  - grails project, build with grails, deployed into a maven repo using grails maven plugin
* `jenkins-scp` - grails project, build with grails, resulting .war scp into a maven repo using hudson/jenkins scp plugin

|jenkins-mvn/maven  |grails-mvn          |jenkins-scp      |
|:------------------|:-------------------|:----------------|
|ala-cas            |ala-downloads       |ala-expert       |
|ala-cas-client     |ala-hub             |apikey           |
|ala-fieldguide     |ala-soils2sat       |bhl-demo-app :warning: |
|ala-logger         |ala-web-theme       |bie-webapp2      |
|ala-logger-service |alerts              |dashboard        |
|ala-name-matching  |amrin-hub           |ecodata          |
|ala-names-generator|appd-hub            |fieldcapture     |
|analysis-service   |asbp-hub            |fieldcapture-hubs|
|bie-profile        |avh-hub             |fielddata        |
|bie-service        |bhl-ftindex-manage  |ozatlas-proxy    |
|biocache-jms       |biocache-hubs       |regions :warning:   |
|biocache-store     |collectory          |sandbox          |
|layer-ingestion    |fielddata-proxy     |sds-webapp2      |
|layers-service     |generic-hub         |sightings        |
|layers-store       |image-service       |specimenbrowser  |
|sensitive-species  |images-client-plugin|tviewer          |
|spatial-portal     |obis-hub            |userdetails      |
|                   |ozcam-hub           |volunteer-portal |
|                   |specieslist-webapp  |webapi           |
|                   |tepapa-hub          |                 |
NOTE: :warning: uses grails < 2.1 (as in no maven support before grails 2.1)

## What needs to be done?
In order to add support for [travis-ci.org](http://travis-ci.org) we need to adjust the projects/component as follows:

### common steps
This has to be done **for each** ALA project we want to add travis-ci.org support to. The order of these steps is **important** (as in you won't be able to encrypt/generate usernames/passwords for `atlasoflivingaustralia/alerts` **before** you enabled the project `atlasoflivingaustralia/alerts` in travis-ci.org)

1. log into [travis-ci.org](http://travis-ci.org) with your github (`atlasoflivingaustralia` admin/owner) profile, and enable the project/component you want add travis support for, for example `atlasoflivingaustralia/alerts`
2. Install the [travis client](https://github.com/travis-ci/travis.rb), usually with: `sudo gem install travis`; this is required to encrypt env variables, files, etc. We want to encrypt our maven repo username/password for deployment from travis-ci.org into our maven repo-s, example:
```BASH
git clone git@github.com:AtlasOfLivingAustralia/alerts.git alerts.git
cd alerts.git
travis2.0 encrypt -r AtlasOfLivingAustralia/alerts "TRAVIS_DEPLOY_USERNAME=someusername"
Please add the following to your .travis.yml file:

  secure: "DxzC7mcfOxW6xfV7kUi2qc1kSS/7RCqWw+YFqVxWGJsxPiHiGobKf6PlGDqo8KJgCzQR0apqgvr0bKO9CcRbuqfWNuSsRVf6odHcuvktqIiCznMs7tzbCk8xcu0suXBKrz1sgHphtze/Nt2idTFeLtX6rZ+svKs21kxb9yT2Ik="

travis2.0 encrypt -r AtlasOfLivingAustralia/alerts "TRAVIS_DEPLOY_PASSWORD=somepassword"
Please add the following to your .travis.yml file:

  secure: "XIODXD7cct/ruQ/bQ7i/gjhZbUhh8T/y7jZ8xkzQjuwggXm7DQhsWwfpONDjK+R1c2aSTFgBZVR6dSVoo/OIrTZhvmqfcfkYqalNxpqW+YGr/uy723srO0N0RYXJW+3AT2JnoT10SgktyKZMbBvJcGLvSkzr/sfhzDScA5vsoJY="
```
add the encrypted strings to your `.travis.yml` file env: section as described bellow.
The rest of these steps is specific, depending on what type of project (jenkins-mvn, grails-mvn, jenkins-scp).

### jenkins-mvn/maven
These projects/components are "ready to go". All that needs to be done, is the basic/standard support for travis:

1. add/commit/push `travis-maven-settings.xml` file (same file format and purpose like `~/.m2/settings.xml`) TODO: OR wget from a fileserver 
2. add/commit/push `<distributionManagement>` to your `pom.xml` file TODO: IF there is some other way to provide this info our life is going to be easier
3. add/commit/push `.travis` file to the github project repo, see https://github.com/mbohun/ala-cas for a working example

*working examples:*
* https://github.com/mbohun/ala-cas
* https://github.com/mbohun/ala-cas-client

### grails-mvn
These projects are "ready to go".  All that needs to be done, is the basic/standard support for travis:

1. take the "generic" grails `.travis` file (TODO: agree with Dave which is the best template/approach to use)

  1.1 make sure to set the correct `GRAILS_VERSION`, for example: `GRAILS_VERSION=2.3.11` (why we bother with this manually? can't i simply sed it out of `application.properties` file?)

2. make sure your grails `grails.project.groupId = "au.org.ala"`, this can be well hidden either in:
  * `grails-app/conf/Config.groovy`, or
  * `grails-app/conf/BuildConfig.groovy`, or
  * `application.properties`

*working examples:*
* https://github.com/mbohun/ala-hub
* https://github.com/mbohun/ala-downloads
* https://github.com/mbohun/alerts

### jenkins-scp
These projects needs to be 'mavenized' first in order to become the same as `grails-mvn`. grails supports maven since grails version `2.1`.

1. add [grail release plugin](http://grails.org/plugin/release) to `BuildConfig.groovy`
2. and follow `grails-mvn` steps to finish (TODO: naivite - in theory this should be the end, BUT)

*working examples:*
* https://github.com/mbohun/dashboard
* https://github.com/mbohun/volunteer-portal

## Summary table
|module                                                                              |build sys    |jenkins build targets                                          |deployment   |
|----------------------------------------------------------------------------------- |------------ |-------------------------------------------------------------- |------------ |
|[ala-cas](https://github.com/AtlasOfLivingAustralia/ala-cas)                        |Maven 3.2.1  |`clean install -DskipTests=true -e`                            |`jenkins-mvn`|
|[ala-cas-client](https://github.com/AtlasOfLivingAustralia/ala-cas-client)          |Maven 3.2.1  |`clean install -DskipTests=true -e`                            |`jenkins-mvn`|
|[ala-downloads](https://github.com/AtlasOfLivingAustralia/ala-downloads)            |Grails 2.3.8 |`clean-all refresh-dependencies maven-install maven-deploy`    |`grails-mvn` |
|[ala-expert](https://github.com/AtlasOfLivingAustralia/ala-expert)                  |Grails 2.2.2 |`"prod war target/expert.war"`                                 |`jenkins-scp`|
|[ala-fieldguide](https://github.com/AtlasOfLivingAustralia/ala-fieldguide)          |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[ala-hub](https://github.com/AtlasOfLivingAustralia/ala-hub)                        |Grails 2.3.11|`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[ala-logger](https://github.com/AtlasOfLivingAustralia/ala-logger)                  |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[ala-logger-service](https://github.com/AtlasOfLivingAustralia/ala-logger-service)  |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[ala-name-matching](https://github.com/AtlasOfLivingAustralia/ala-name-matching)    |Maven 3.2.1  |`clean install`                                                |`jenkins-mvn`|
|[ala-names-generator](https://github.com/AtlasOfLivingAustralia/ala-names-generator)|Maven 3.2.1  |`clean install`                                                |`jenkins-mvn`|
|[ala-soils2sat](https://github.com/AtlasOfLivingAustralia/ala-soils2sat)            |Grails 2.2.3 | ? |`grails-mvn`?|
|[ala-web-theme](https://github.com/AtlasOfLivingAustralia/ala-web-theme)            |Grails 2.3.11|`clean refresh-dependencies maven-deploy`                      |`grails-mvn` |
|[alerts](https://github.com/AtlasOfLivingAustralia/alerts)                          |Grails 2.3.8 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[amrin-hub](https://github.com/AtlasOfLivingAustralia/amrin-hub)                    |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[analysis-service](https://github.com/AtlasOfLivingAustralia/analysis-service)      |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[apikey](https://github.com/AtlasOfLivingAustralia/apikey)                          |Grails 2.2.0 |`"prod war target/apikey.war" --non-interactive"`          |`jenkins-scp`|
|[appd-hub](https://github.com/AtlasOfLivingAustralia/appd-hub)                      |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[asbp-hub](https://github.com/AtlasOfLivingAustralia/asbp-hub)                      |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[avh-hub](https://github.com/AtlasOfLivingAustralia/avh-hub)                        |Grails 2.3.11|`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[bhl-demo-app](https://github.com/AtlasOfLivingAustralia/bhl-demo-app)              |Grails 2.0.1 | ? |`jenkins-scp`|
|[bhl-ftindex-manage](https://github.com/AtlasOfLivingAustralia/bhl-ftindex-manage)  |Grails 2.2.3 | ? |`grails-mvn`?|
|[bhl-ftindexer](https://github.com/AtlasOfLivingAustralia/bhl-ftindexer)            |Maven 3.2.1  | ? | `maven` |
|[bhl-solr-plugin](https://github.com/AtlasOfLivingAustralia/bhl-solr-plugin)        |Maven 3.2.1  | ? | `maven` |
|[bie-profile](https://github.com/AtlasOfLivingAustralia/bie-profile)                |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[bie-service](https://github.com/AtlasOfLivingAustralia/bie-service)                |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[bie-webapp2](https://github.com/AtlasOfLivingAustralia/bie-webapp2)                |Grails 2.3.11|`"prod war target/bie-webapp2.war"` ~~BROKEN with grails publisher/release plugin, pom.xml creation fails~~| ~~jenkins-scp~~ `maven`|
|[biocache-hubs](https://github.com/AtlasOfLivingAustralia/biocache-hubs)            |Grails 2.3.8 |`clean refresh-dependencies "prod maven-deploy" "prod maven-install"`|`grails-mvn`|
|[biocache-jms](https://github.com/AtlasOfLivingAustralia/biocache-jms)              |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|  
|[biocache-service](https://github.com/AtlasOfLivingAustralia/biocache-service)      |Maven 3.2.1  |`-e clean deploy`                                              |`maven`      |
|[biocache-store](https://github.com/AtlasOfLivingAustralia/biocache-store)          |Maven 3.2.1  |`clean deploy -e -DskipTests=true` DUPLICATE deploy?           |`maven`,`jenkins-mvn`|
|[collectory](https://github.com/AtlasOfLivingAustralia/collectory)                  |Grails 2.3.8 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[dashboard](https://github.com/AtlasOfLivingAustralia/dashboard)                    |Grails 2.2.4 |`"prod war target/dashboard.war"`                              |`jenkins-scp`|
|[ecodata](https://github.com/AtlasOfLivingAustralia/ecodata)                        |Grails 2.2.1 |`"prod war target/ecodata.war"`                                |`jenkins-scp`|
|[fieldcapture](https://github.com/AtlasOfLivingAustralia/fieldcapture)              |Grails 2.2.1 |`clean "prod war target/fieldcapture.war"`                     |`jenkins-scp`|
|[fieldcapture-hubs](https://github.com/AtlasOfLivingAustralia/fieldcapture-hubs)    |Grails 2.4.3 |`clean refresh-dependencies "prod war target/fieldcapture-hub.war"`       |`jenkins-scp`|
|[fieldcapture-mobile](https://github.com/AtlasOfLivingAustralia/fieldcapture-mobile)|android, ios |`TODO` android/gradle?                                                   |`gradle?`    |
|[fielddata](https://github.com/AtlasOfLivingAustralia/fielddata)                    |Grails 2.1.1 |`"prod war target/fielddata.war"`                        |~~jenkins-scp~~ `maven`|
|[fielddata-android](https://github.com/AtlasOfLivingAustralia/fielddata-android)    |android      |`TODO` android/gradle?                                                   |`gradle`?|
|[fielddata-mobile](https://github.com/AtlasOfLivingAustralia/fielddata-mobile)      |android, ios |`TODO` |?|
|[fielddata-proxy](https://github.com/AtlasOfLivingAustralia/fielddata-proxy)        |Grails 2.2.0 | ? |`grails-mvn`|
|[generic-hub](https://github.com/AtlasOfLivingAustralia/generic-hub)                |Grails 2.3.8 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[image-loader](https://github.com/AtlasOfLivingAustralia/image-loader)              |Maven 3.2.1  | ? |`maven`|
|[image-service](https://github.com/AtlasOfLivingAustralia/image-service)            |Grails 2.3.11| ? |`grails-mvn`?|
|[image-tiling-agent](https://github.com/AtlasOfLivingAustralia/image-tiling-agent)  |Maven 3.2.1  | ? |`maven`|
|[image-utils](https://github.com/AtlasOfLivingAustralia/image-utils)                |Maven 3.2.1  | ? |`maven`|
|[images-client-plugin](https://github.com/AtlasOfLivingAustralia/images-client-plugin)|Grails 2.3.11| ? |`grails-mvn`?|
|[layer-ingestion](https://github.com/AtlasOfLivingAustralia/layer-ingestion)        |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[layers-service](https://github.com/AtlasOfLivingAustralia/layers-service)          |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[layers-store](https://github.com/AtlasOfLivingAustralia/layers-store)              |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[obis-hub](https://github.com/AtlasOfLivingAustralia/obis-hub)                      |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[ozatlas](https://github.com/AtlasOfLivingAustralia/ozatlas)                        |android      | android/phonegap | ? |
|[ozatlas-android](https://github.com/AtlasOfLivingAustralia/ozatlas-android)        |android      | `TODO` | `TODO` |
|[ozatlas-proxy](https://github.com/AtlasOfLivingAustralia/ozatlas-proxy)            |Grails-2.2.4 |`"prod war target/mobileauth.war"`            |`jenkins-scp`|
|[ozcam-hub](https://github.com/AtlasOfLivingAustralia/ozcam-hub)                    |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[regions](https://github.com/AtlasOfLivingAustralia/regions)                        |Grails 1.3.7 |`"prod war target/regions.war"`                                |`jenkins-scp`|
|[sandbox](https://github.com/AtlasOfLivingAustralia/sandbox)                        |Grails 2.2.4 |`"prod war target/datacheck.war"`                              |`jenkins-scp`|
|[sds-webapp2](https://github.com/AtlasOfLivingAustralia/sds-webapp2)                |Grails 2.3.7 |`"prod war  target/sds-webapp2.war"`                           |`jenkins-scp`|
|[sensitive-species](https://github.com/AtlasOfLivingAustralia/sensitive-species)    |Maven 3.2.1  |`clean install -DskipTests=true`                               |`jenkins-mvn`|
|[sightings](https://github.com/AtlasOfLivingAustralia/sightings)                    |Grails 2.1.1 |`"prod war target/sightings.war"`                              |~~jenkins-scp~~ `maven`|
|[spatial-logger](https://github.com/AtlasOfLivingAustralia/spatial-logger)          |Maven 3.2.1  | ? |`maven`?|
|[spatial-portal](https://github.com/AtlasOfLivingAustralia/spatial-portal)          |Maven 3.2.1  |`clean install`                                                |`jenkins-mvn`|
|[specieslist-webapp](https://github.com/AtlasOfLivingAustralia/specieslist-webapp)  |Grails 2.3.8 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[specimenbrowser](https://github.com/AtlasOfLivingAustralia/specimenbrowser)        |Grails 2.2.2 | ? |~~jenkins-scp~~ `maven`|
|[tepapa-hub](https://github.com/AtlasOfLivingAustralia/tepapa-hub)                  |Grails 2.3.7 |`refresh-dependencies "prod maven-install" "prod maven-deploy"`|`grails-mvn` |
|[tviewer](https://github.com/AtlasOfLivingAustralia/tviewer)                        |Grails 2.1.2 |`"prod war target/tviewer.war"`                                |`jenkins-scp` |
|[userdetails](https://github.com/AtlasOfLivingAustralia/userdetails)                |Grails 2.2.4 |`"prod war target/userdetails.war"`                            |`jenkins-scp` |
|[volunteer-portal](https://github.com/AtlasOfLivingAustralia/volunteer-portal)      |Grails 2.3.11|`"prod war target/volunteer-portal.war"`                       |`jenkins-scp` |
|[webapi](https://github.com/AtlasOfLivingAustralia/webapi)                          |Grails 2.3.8 |`"prod war  target/webapi.war" --non-interactive"`             |`jenkins-scp` |
