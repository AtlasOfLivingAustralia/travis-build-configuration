##Beware of grails maven publisher/release plugin misleading error messages
Basically the real error/problem/cause (examples of real errors are something like: wrong password or username, an attempt to redeploy into a repository that is configured with redeploy=false, etc) is completely hidden behind layers and layers of crap...

###Examples

####example 00
```
bash-3.2$ grails prod maven-deploy --repository=nectar-nexus-repo-test
 ...
[ala-hub] No external configuration file defined.
[ala-hub] (*) grails.config.locations = []
| Done creating WAR target/ala-hub-1.4-SNAPSHOT.war
| Using configured username and password from grails.project.repos.nectar-nexus-repo-test....
| Error Error deploying artifact: Error deploying artifact 'au.org.ala:ala-hub:war': Error deploying artifact: Failed to transfer file: http://130.56.249.242/nexus/content/repositories/releases/au/org/ala/ala-hub/1.4-SNAPSHOT/ala-hub-1.4-20140918.033423-1.war. Return code is: 400
| Error Have you specified a configured repository to deploy to (--repository argument) or specified distributionManagement in your POM?
```
* reported error: Error deploying artifact ... HTTP return code 400
* real problem: an attempt to deploy a SNAPSHOT into a release repo or vice versa

####example 01
```
| Done creating WAR target/dashboard-0.2-SNAPSHOT.war
POM generated: /Users/hor22n/src/dashboard_mbohun.git/target/pom.xml
Error deploying artifact: Error deploying artifact 'au.org.ala:dashboard:war': Error deploying artifact: Failed to transfer file: http://130.56.249.242/nexus/content/repositories/snapshots/au/org/ala/dashboard/0.2-SNAPSHOT/dashboard-0.2-20140924.050741-1.war. Return code is: 401
Have you specified a configured repository to deploy to (--repository argument) or specified distributionManagement in your POM?
Maven deploy complete.
``` 
* reported error: Error deploying artifact ... HTTP return code 401
* real problem: dashboard is an older grails app (grails 2.2.4), and the grails (publisher/release) maven plugin prior to grails 2.3 (**< 2.3**) requires the `~/.grails/settings.groovy` repo info to be in format:
```groovy
grails.project.dependency.distribution = {
  remoteRepository(id:"nectar-nexus-repo-snapshot", url:"http://130.56.249.242/nexus/content/repositories/snapshots") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }

  remoteRepository(id:"nectar-nexus-repo-release",  url:"http://130.56.249.242/nexus/content/repositories/releases") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }
}
```
(instead of the newer format used by grails 2.3 and higher (**>=2.3**)):
```groovy
grails.project.repos.'nectar-nexus-repo-snapshot'.url = "http://130.56.249.242/nexus/content/repositories/snapshots/"
grails.project.repos.'nectar-nexus-repo-snapshot'.username = System.getenv("TRAVIS_DEPLOY_USERNAME")
grails.project.repos.'nectar-nexus-repo-snapshot'.password = System.getenv("TRAVIS_DEPLOY_PASSWORD")

grails.project.repos.'nectar-nexus-repo-release'.url = "http://130.56.249.242/nexus/content/repositories/releases/"
grails.project.repos.'nectar-nexus-repo-release'.username = System.getenv("TRAVIS_DEPLOY_USERNAME")
grails.project.repos.'nectar-nexus-repo-release'.password = System.getenv("TRAVIS_DEPLOY_PASSWORD")
```
NOTE: maven release plugin with grails **2.4** and higher (**>=2.4**) accepts and works with **BOTH** (old **AND** new) `~/.grails/settings.groovy` file formats.

####example-02
HTTP error 500 (Internal Server Error) reported when sonatype nexus run out of disk space

####example-03
HTTP 400 in response to attempt to deploy/upload into the maven repo an already existing **release** version of an artefact (war/jar/zip, etc.) In this example the build is trying to upload (overwrite) existing war file `phylolink-0.2.war`
```
| Compiling 5 GSP files for package [alaAuth]..
| Building WAR file
| Building WAR file.
| Building WAR file..
| Building WAR file...
| Building WAR file....
| Building WAR file.....
| Done creating WAR target/phylolink-0.2.war
| Generating POM file...
| Generating POM file....
| Generating POM file.....
| Downloading: commons-lang/commons-lang/2.4/commons-lang-2.4.jar
| Downloading: commons-beanutils/commons-beanutils/1.8.0/commons-beanutils-1.8.0.jar
| POM generated: /home/travis/build/AtlasOfLivingAustralia/phylolink/target/pom.xml
| Using configured username and password from grails.project.repos.ala-repo-release
| Using configured username and password from grails.project.repos.ala-repo-release.
| Using configured username and password from grails.project.repos.ala-repo-release..
| Using configured username and password from grails.project.repos.ala-repo-release...
| Using configured username and password from grails.project.repos.ala-repo-release....
| Error Error deploying artifact: Error deploying artifact 'au.org.ala:phylolink:war': Error deploying artifact: Failed to transfer file: http://nexus.ala.org.au/content/repositories/releases/au/org/ala/phylolink/0.2/phylolink-0.2.war. Return code is: 400
| Error Have you specified a configured repository to deploy to (--repository argument) or specified distributionManagement in your POM?
The command "grails clean && grails refresh-dependencies --non-interactive && grails prod war --non-interactive && grails prod maven-deploy --repository=$MAVEN_REPO --non-interactive" exited with 1.
Done. Your build exited with 1.
```
