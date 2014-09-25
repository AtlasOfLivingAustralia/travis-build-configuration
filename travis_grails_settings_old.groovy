grails.project.dependency.distribution = {
  remoteRepository(id:"ala-repo-snapshot", url:"http://ala-wonder.it.csiro.au/nexus/content/repositories/snapshots") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }

  remoteRepository(id:"ala-repo-release",  url:"http://ala-wonder.it.csiro.au/nexus/content/repositories/releases") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }
}
