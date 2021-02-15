# ami-bakery-jenkins

![Test](https://github.com/keefbaker/ami-bakery-jenkins/workflows/Test/badge.svg)

This is an example of how to create an AMI Bakery that can update the ec2 plugin when completed.

It will also clean up old AMIs that are out of date.

There are two versions here. There's the all in one jenkinsfile which is a build and test with inspec, and then there's the two part version with a downstream job that can run a full job on the AMI as launched through an intermediary configuration.