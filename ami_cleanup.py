"""
A script for automating the cleanup of old amis.
set the environment variable CREATE_AMI_NAME to the
common part of the name, eg "centos jenkins worker"
KEEP_NUMBER is how many AMIs to keep
"""
from __future__ import print_function

import os
import sys

import boto3

EC2 = boto3.client("ec2")
KEEP_NUMBER = os.environ.get("KEEP NUMBER") if os.environ.get("KEEP NUMBER") else 4


def get_amis():
    """
    Gets and sorts the AMIs from the AWS API
    """
    print("looking for images that fit {}".format(os.environ["CREATE_AMI_NAME"]))
    images = EC2.describe_images(
        Owners=["self"],
        Filters=[
            {"Name": "name", "Values": ["{}*".format(os.environ["CREATE_AMI_NAME"])]}
        ]
    )
    sorted_images = sorted(images["Images"], key=lambda x: x["CreationDate"])
    print("There are {} images".format(len(sorted_images)))
    return sorted_images


def deregister(amis):
    """
    Discover how many AMIs to deregister and
    then deregister them
    """
    print("I am configured to keep {} Images".format(KEEP_NUMBER))
    if len(amis) <= KEEP_NUMBER:
        print(
            "Matching images is less than or equal to {}, quitting.".format(KEEP_NUMBER)
        )
    else:
        kill_list = amis[:-KEEP_NUMBER]
        for ami in kill_list:
            print("deregistering {}".format(ami["ImageId"]))
            EC2.deregister_image(ImageId=ami["ImageId"])
        print("confirming number of images now")
        num_amis = len(get_amis())
        if num_amis == KEEP_NUMBER:
            print("Success")
        else:
            print(
                "!! There are {} AMIs in AWS and I expected {}".format(
                    num_amis, KEEP_NUMBER
                    )
                )
            print("!! Please Investigate!!!")
            sys.exit(1)


if __name__ == "__main__":
    if not os.environ["CREATE_AMI_NAME"]:
        # Catch the missing env var or it might include any ami(*)
        print("!! You need to set the environment variable CREATE_AMI_NAME")
        sys.exit(1)
    deregister(get_amis())
