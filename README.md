##intro

[ALA](https://github.com/AtlasOfLivingAustralia) has as of today (2014-09-25) apx. 40 different grails projects. These projects are using https://travis-ci.org build system. After each grails project was successfully built travis-ci.org uses the grails release (formerly publisher) plugin to deploy the build artifacts into a maven repository.

To keep and access (shared/common) configuration files in this repository allows for easy/convenient configuration changes here in one place instead of going over 40 separate grails projects and making the same change for each of them. A typical example of this is changing/updating the maven repository URLs.
NOTE: If some of our grails projects for some reason can't or do not want to use this shared configuration, they simply maintain their own/specific configuration in the project's github repo.

