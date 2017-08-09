grails.project.dependency.distribution = {
  remoteRepository(id:"ala-repo-snapshot", url:"https://nexus.ala.org.au/content/repositories/snapshots") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }

  remoteRepository(id:"ala-repo-release",  url:"https://nexus.ala.org.au/content/repositories/releases") {
    authentication username: System.getenv("TRAVIS_DEPLOY_USERNAME"), password: System.getenv("TRAVIS_DEPLOY_PASSWORD")
  }
}
