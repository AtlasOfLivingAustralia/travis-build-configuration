grails.project.repos.'ala-repo-snapshot'.url="https://nexus.ala.org.au/content/repositories/snapshots/"
grails.project.repos.'ala-repo-snapshot'.username=System.getenv("TRAVIS_DEPLOY_USERNAME")
grails.project.repos.'ala-repo-snapshot'.password=System.getenv("TRAVIS_DEPLOY_PASSWORD")

grails.project.repos.'ala-repo-release'.url="https://nexus.ala.org.au/content/repositories/releases/"
grails.project.repos.'ala-repo-release'.username=System.getenv("TRAVIS_DEPLOY_USERNAME")
grails.project.repos.'ala-repo-release'.password=System.getenv("TRAVIS_DEPLOY_PASSWORD")
