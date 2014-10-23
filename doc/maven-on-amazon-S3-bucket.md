###deploying into maven repository inside amazon S3 bucket
(in 64 easy steps)

####1. amazon S3 bucket setup
1. log into amazon S3 management console
2. create a new S3 bucket for the maven repo (in my example i created bucket named `mbohun-maven`)
3. click onto the newly created S3 bucket and then click the `Properties`
4. in `Properties` select `Permissions` and click on `Edit bucket policy`
5. setup the bucket policy as follows (replace with your bucket name):

example amazon S3 bucket policy:
```
{
	"Version": "2008-10-17",
	"Id": "Policy1397027253868",
	"Statement": [
		{
			"Sid": "Stmt1397027243665",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:ListBucket",
			"Resource": "arn:aws:s3:::mbohun-maven"
		},
		{
			"Sid": "Stmt1397027177153",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::mbohun-maven/*"
		}
	]
}
```

####2. maven setup
1. add [AWS Maven Vagon](https://github.com/spring-projects/aws-maven) to your `pom.xml` at XPath `/project/build/extensions`
2. add the amazon S3 bucket you created to your `pom.xml` `<distributionManagement>`

example `pom.xml`:

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
2. deployed from [travis-ci.org](https://travis-ci.org/mbohun/ala-cas-client/builds/34688285) into a [maven repo inside amazon S3 bucket](https://mbohun-maven.s3.amazonaws.com)
