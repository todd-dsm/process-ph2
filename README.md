# process-ph2
The evolution of a process: phase 2.

In Phase 1 an app was developed and sealed into a container. Phase 2 is about making a home for that container in the form of a Amazon AMI. 

Some automation was converted from phase1 to support the environment that will be build in this phase. This will ensure build consistency.

## Some Setup
Before starting, edit the `vars-build` file in this directory and change the value of `AWS_REGION` from `us-west-2` to whatever region AWS assigned to _you_. 

Also, the work that comes later cannot be validated until there is [access to the VPC]:

* FROM: the point of origin: your current gateway
* TO: the destination: _your_ AWS account

We may as well get it out of the way now. _NOTE:_ 

* This is only necessary if the gateway address is DHCP (keeps changing) or 
* You are on the road, staying in hotels for example. 
* The script only needs to be run once per IP address change. 
* If the gateway address hasn't changed the script will simply report that the correct settings are already in place. 

Access can be [gained easily] by running this script:

`scripts/aws-tools/access-aws-securitygroup.sh`

Now that the requisite access is in place the AMI can be built.
***
## Build the AMI
Building an AMI means describing it in a JSON file that Packer can consume. In this case that file is `debian-8.6-ami.json`. It needs to be built from an existing AMI so, we'll use the one [Debian] offers in the AWS Marketplace. Since finding the latest AMI `ImageId` requires the manual steps of selecting the **Manual Launch** (tab) and indexing the  `ImageId` in your region the exorcise becomes tedious. We'll get the automation to do it for us.

### Process Description
The `build-ami.sh` script takes 1 argument - the packer file: `debian-8.6-ami.json`

Next, `build-ami.sh` calls `scripts/aws-tools/find-latest-amis.sh` to [find the latest] Debian Jessie AMI `ImageId` which is then sent to Packer as a variable; for example: `latestImageId=ami-12345678`. _NOTE: this script does factor for `AWS_REGION` specified in_ `vars-build`.

**WARNING: this step can take 8-12 minutes.**

After the script has been started it's time to go make a sandwich, do some laundry, whatever. It takes some time to build, which varies based on available Internet connection bandwidth and workstation horsepower. 

To build an AMI simply run this script:

`./build-ami.sh debian-8.6-ami.json 2>&1 | tee /tmp/packer-debian-build.out`


### Post-Build
When you're ready, review the output in `/tmp/packer-debian-build.out`. These are the build details.

Now that you have a tailored AMI. You are ready to [start Terraforming].

[access to the VPC]:http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#adding-security-group-rule
[gained easily]:https://github.com/todd-dsm/aws-tools/wiki/access-aws-securitygroup
[Debian]:https://aws.amazon.com/marketplace/pp/B00WUNJIEE?qid=1487285341617
[find the latest]:https://github.com/todd-dsm/aws-tools/wiki/find-latest-ami
[start Terraforming]:https://github.com/todd-dsm/process-ph3

