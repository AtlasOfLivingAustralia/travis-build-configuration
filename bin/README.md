These are some helper scripts to automate/speedup some of the tedious and error prone tasks.

####githubapi-get-all-repos.sh
This BASH script uses [cURL](http://curl.haxx.se) to call the [github REST API](https://developer.github.com/v3) in order to retrieve all github repository names for a given github user or github organization. I wrote this script originally only as a note/demo about how to correctly paginate github REST API results (return values).
I have been using this script a lot, mostly to get fast an upto-date list of all of our https://github.com/AtlasOfLivingAustralia github projects, when I want/need to run some `for each` type of scenario. 

Example usage:
```
bash-3.2$ ./githubapi-get-all-repos.sh
usage: ./githubapi-get-all-repos.sh [github username] [your github token]
```
```
bash-3.2$ ./githubapi-get-all-repos.sh AtlasOfLivingAustralia $YOUR_GITHUB_TOKEN
ala-cas
ala-cas-client
ala-downloads
ala-expert
ala-hub
...
specieslist-webapp
specimenbrowser
taxon-overflow
tepapa-hub
travis-build-configuration
tviewer
userdetails
volunteer-portal
webapi
```

####github-add-travis.sh
This BASH script automatically adds [travis-ci.org](https://travis-ci.org) support to a given list of github projects. Currently supported projects are:
- grails projects (identified by `application.properties` in the project/repo root
- java/maven projects (identified by `pom.xml` in the project/repo root)
- *we can add more project types as we need them, for example android/iOS projects, gradle, etc.*

This script executes for each given repo the following steps:

1. clones the repo into /tmp
2. checks if the repo already contains `.travis.yml` file; if there is alrady `.travis.yml` file the script will skip it (see bellow for description of the `OVERWRITE_MODE` to trigger alternative behaviour.
3. next the script attempts to identify the "type of project" (grails? or pom.xml?)
4. if the type of project is successfully identified:
  1. the script will copy in a `.travis.yml` template for that type of project
  2. the script will attempt to add required maven-publisher/maven-release pluging to grails projects; or add `<distributionManagement>` to pom.xml based projects (**but only if there is no <distributionManagement> in the pom.xml file already**)
5. next the script uses the travis client to:
  1. enable travis-ci.org for the repo
  2. encrypt and store into the `.travis.yml` all the variables from the variables file (see the example bellow for variables file format)
6. next the script will test if there is already a `README.md` file in the root of the repo, and if not it will create one (contains only the name of the repo)
7. next the script checks if there is already a [travis-ci.org](https://travis-ci.org) build status badge present in the `README.md` file and if not it will add one
8. then the changes are commited and pushed into git/github repo

**OVERWRITE MODE**
`OVERWRITE_MODE` is for situations where you do want to replace/overwrite an existing `.travis.yml` file, for example because you want or need to (bulk) update some env variable, or some other setting for a group of repos/project (a real life example would be to update/change maven repository username and/or password for 10-20 of our projects). 
`OVERWRITE_MODE` is disabled by default; In order to enable it open the `github-add-travis.sh` script and set `OVERWRITE_MODE=1`. Basically the main difference between normal/default mode (`OVERWRITE_MODE=0`) and `OVERWRITE_MODE=1` is that in `OVERWRITE_MODE=1` the script will **NOT** attempt to add maven-publisher/maven-release plugin-s, nor it will attempt to modify `pom.xml`.
In `OVERWRITE_MODE` the `github-add-travis.sh` script behaves as follows:

1. clones the repo into /tmp
2. next the script attempts to identify the "type of project" (grails? or pom.xml?)
3. if the type of project is successfully identified the script will copy in a `.travis.yml` template for that type of project **OVERWRITING** an existing `.travis.yml` if one exists
4. next the script uses the travis client to:
  1. enable travis-ci.org for the repo (this has no effect if the travis-ci.org was already enabled)
  2. encrypt and store into the `.travis.yml` all the variables from the variables file (see the example bellow for variables file format)
5. next the script will test if there is already a `README.md` file in the root of the repo, and if not it will create one (contains only the name of the repo)
6. next the script checks if there is already a [travis-ci.org](https://travis-ci.org) build status badge present in the `README.md` file and if not it will add one
7. then the changes are commited and pushed into git/github repo

Example usage:
```
bash-3.2$ ./github-add-travis.sh
usage: ./github-add-travis.sh [github-token] [github username/organization] [env var file] [repo0] [repo1] [repo2] ... [repoN]
```
the variables file (the 3rd argument `[env var file]`) format is as follows:
```
VARIABLE_ONE_NAME=42
VARIABLE_TWO_NAME=someStringHere
VARIABLE_THREE=http://ala-wonder.it.csiro.au/nexus/content/repositories/releases
...
```

####generate-github-travis-build-summary.sh
This BASH script generates a summary table (in github markdown format); each row is showing a repo/project name and the [travis-ci.org] build status badge for that project.

Example usage:
```
bash-3.2$ ./generate-github-travis-build-summary.sh
usage: ./generate-github-travis-build-summary.sh [github user/organization] repo0 repo1 repo2 ... repoN
```
```
bash-3.2$ ./generate-github-travis-build-summary.sh AtlasOfLivingAustralia ala-cas ala-hub ala-names-generator alerts dashboard fielddata volunteer-portal
|repo|travis build status|
|:---|:------------------|
|[ala-cas](https://github.com/AtlasOfLivingAustralia/ala-cas)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas)|
|[ala-hub](https://github.com/AtlasOfLivingAustralia/ala-hub)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub)|
|[ala-names-generator](https://github.com/AtlasOfLivingAustralia/ala-names-generator)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator)|
|[alerts](https://github.com/AtlasOfLivingAustralia/alerts)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/alerts.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/alerts)|
|[dashboard](https://github.com/AtlasOfLivingAustralia/dashboard)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/dashboard.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/dashboard)|
|[fielddata](https://github.com/AtlasOfLivingAustralia/fielddata)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/fielddata.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/fielddata)|
|[volunteer-portal](https://github.com/AtlasOfLivingAustralia/volunteer-portal)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal)|
```
displayed as:

|repo|travis build status|
|:---|:------------------|
|[ala-cas](https://github.com/AtlasOfLivingAustralia/ala-cas)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas)|
|[ala-hub](https://github.com/AtlasOfLivingAustralia/ala-hub)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub)|
|[ala-names-generator](https://github.com/AtlasOfLivingAustralia/ala-names-generator)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator)|
|[alerts](https://github.com/AtlasOfLivingAustralia/alerts)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/alerts.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/alerts)|
|[dashboard](https://github.com/AtlasOfLivingAustralia/dashboard)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/dashboard.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/dashboard)|
|[fielddata](https://github.com/AtlasOfLivingAustralia/fielddata)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/fielddata.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/fielddata)|
|[volunteer-portal](https://github.com/AtlasOfLivingAustralia/volunteer-portal)|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal)|

####generate-github-travis-build-summary-with-grails.sh
Same as `generate-github-travis-build-summary.sh` above, only this version adds extra columns to display the app (usually war, jar) version number, and the grails version.

Example usage:
```
bash-3.2$ ./generate-github-travis-build-summary-with-grails.sh AtlasOfLivingAustralia ala-cas ala-hub ala-names-generator alerts dashboard fielddata volunteer-portal
```

|repo|version|travis build status|grails|
|:---|:------|:------------------|:-----|
|[ala-cas](https://github.com/AtlasOfLivingAustralia/ala-cas)|1.0-SNAPSHOT|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-cas)|N/A|
|[ala-hub](https://github.com/AtlasOfLivingAustralia/ala-hub)|1.4-SNAPSHOT|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-hub)|2.3.11|
|[ala-names-generator](https://github.com/AtlasOfLivingAustralia/ala-names-generator)|1.0-SNAPSHOT|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/ala-names-generator)|N/A|
|[alerts](https://github.com/AtlasOfLivingAustralia/alerts)|0.1|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/alerts.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/alerts)|2.3.11|
|[dashboard](https://github.com/AtlasOfLivingAustralia/dashboard)|0.1|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/dashboard.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/dashboard)|2.2.4|
|[fielddata](https://github.com/AtlasOfLivingAustralia/fielddata)|0.1|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/fielddata.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/fielddata)|2.1.1|
|[volunteer-portal](https://github.com/AtlasOfLivingAustralia/volunteer-portal)|1.0|[![BuildStatus](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal.svg?branch=master)](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal)|2.3.11|
