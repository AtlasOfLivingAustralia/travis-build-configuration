1. add `aws-wagon` to your `pom.xml` at XPath `/project/build/extensions`
2. add amazon S3 bucket to your `pom.xml` `<distributionManagement>`
3. TODO: copy & paste here amazon S3 bucket configuration

example:

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>au.org.ala</groupId>

    <!-- ... --> 

    <build>
        <extensions>

            <extension>
	        <groupId>org.springframework.build</groupId>
	        <artifactId>aws-maven</artifactId>
	        <version>5.0.0.RELEASE</version>
            </extension>

        </extensions>
    </build>

    <!-- ... -->

    <distributionManagement>
        <repository>
	        <id>aws-release</id>
            <name>AWS Release Repository</name>
            <url>s3://mbohun-maven/release</url>
        </repository>

        <snapshotRepository>
            <id>aws-snapshot</id>
		    <name>AWS Snapshot Repository</name>
            <url>s3://mbohun-maven/snapshot</url>
        </snapshotRepository>
    </distributionManagement>
</project>
```

A fully working example of an [ALA](https://github.com/AtlasOfLivingAustralia) project ([ala-cas-client](https://github.com/mbohun/ala-cas-client)) that is:
1. build on [travis-ci.org](https://travis-ci.org/mbohun/ala-cas-client/builds/34688285)
2. deployed from [travis-ci.org](https://travis-ci.org/mbohun/ala-cas-client/builds/34688285) into a [maven repo inside amazon S3 bucket](ttps://mbohun-maven.s3.amazonaws.com)
