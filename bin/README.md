These are some helper scripts to automate/speedup some of the tedious and error prone tasks.

####githubapi-get-all-repos.sh
This BASH script uses [cURL](http://curl.haxx.se) to call the [github REST API](https://developer.github.com/v3) in order to retrieve all github repository names for a given github user or github organization. I wrote this script originally only as a note/demo about how to correctly paginate github REST API results (return values).

Example usage:



####github-add-travis.sh
This BASH script automatically adds [travis-ci.org](https://travis-ci.org) support to a given list of github projects. Currently supported projects are:
- grails projects (identified by `application.properties` in the project/repo root
- java/maven projects (identified by `pom.xml` in the project/repo root)
- we can add more project types as we need them, for example android/iOS projects, etc.

Example usage:



####generate-github-travis-build-summary.sh
This BASH script generates a summary table (in github markdown format); each row is showing a repo/project name and the [travis-ci.org] build status badge for that project.

Example usage:


####generate-github-travis-build-summary-with-grails.sh
Same as `generate-github-travis-build-summary.sh` above, only this version adds extra columns to display the app (usually war, jar) version number, and the grails version.

Example usage:
