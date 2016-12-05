# elastic beanstalk s3 docker nginx basic auth proxy
> secure a bucket behind basic authentication without thinking about infra

*This assumes you have an [AWS] account and associated credentials with access
to manage elastic beanstalk applications.*

### Setup
First, fork and clone this repo. Then, install the [Elastic Beanstalk CLI],
adding a `eb-cli` profile to your AWS credentials to `~/.aws/config` like so:
```
[profile eb-cli]
aws_access_key_id = AKIAIMZWLTOOSTF6JN4A
aws_secret_access_key = NszqaFD+YDZrrIKzlL7dI2F3z4bF9pZUetQsItln
```

Next, edit `nginx.conf` to reference the bucket you're trying to secure.
```
set $bucketHost 'MYBUCKET.s3-website-us-east-1.amazonaws.com';
```

Next, set up your credentials file, `.htpasswd`. If you don't know how to
generate usernames and passwords, [use this website](http://www.htaccesstools.com/htpasswd-generator/).

### Test Locally (optional)
If you have [Docker] installed, you can now test your application thusly:
```
docker build -t proxy .
docker run -p 8080:80 proxy
```

Browse to [http://localhost:8080]() and enter your credentials. _If you didn't
change them, the username and password will be **test**._

### Initialize a new Elastic Beanstalk Application:
It's time to put your Dockerized proxy on the internet! Next, run `eb init` and
answer the prompts to create a new application. Here is a sample output:

```
~/code/elastic-beanstalk-docker-nginx-s3-proxy
❯ eb init

Select a default region
1) us-east-1 : US East (N. Virginia)
2) us-west-1 : US West (N. California)
3) us-west-2 : US West (Oregon)
4) eu-west-1 : EU (Ireland)
5) eu-central-1 : EU (Frankfurt)
6) ap-south-1 : Asia Pacific (Mumbai)
7) ap-southeast-1 : Asia Pacific (Singapore)
8) ap-southeast-2 : Asia Pacific (Sydney)
9) ap-northeast-1 : Asia Pacific (Tokyo)
10) ap-northeast-2 : Asia Pacific (Seoul)
11) sa-east-1 : South America (Sao Paulo)
12) cn-north-1 : China (Beijing)
13) us-east-2 : US East (Ohio)
(default is 3): 1

Enter Application Name
(default is "elastic-beanstalk-docker-nginx-s3-proxy"): my-nginx-proxy

It appears you are using Docker. Is this correct?
(y/n): y

Select a platform version.
1) Docker 1.11.2
2) Docker 1.9.1
3) Docker 1.7.1
4) Docker 1.6.2
(default is 1): 1
Note:
 Elastic Beanstalk now supports AWS CodeCommit; a fully-managed source control service. To learn more, see Docs: https://aws.amazon.com/codecommit/
Do you wish to continue with CodeCommit? (y/n) (default is n): n
Do you want to set up SSH for your instances?
(y/n): n
```

### Create an environment to run your application
You may run several versions of this application for various purposes (for
example, serving different buckets for development or production).

Start by creating a dev environment using `eb create`. Note that creating a
new environment can take a bit of time!

Here is a sample output:
```
~/code/elastic-beanstalk-docker-nginx-s3-proxy
❯ eb create
Enter Environment Name
(default is my-nginx-proxy-dev):
Enter DNS CNAME prefix
(default is my-nginx-proxy-dev):

Select a load balancer type
1) classic
2) application
(default is 1): 2
WARNING: You have uncommitted changes.
Creating application version archive "app-a88e-161205_120521".
Uploading my-nginx-proxy/app-a88e-161205_120521.zip to S3. This may take a while.
Upload Complete.
Application my-nginx-proxy has been created.
Environment details for: my-nginx-proxy-dev
  Application name: my-nginx-proxy
  Region: us-east-1
  Deployed Version: app-a88e-161205_120521
  Environment ID: e-4b7mqaea4w
  Platform: 64bit Amazon Linux 2016.09 v2.2.0 running Docker 1.11.2
  Tier: WebServer-Standard
  CNAME: my-nginx-proxy-dev.us-east-1.elasticbeanstalk.com
  Updated: 2016-12-05 17:05:28.292000+00:00
Printing Status:
INFO: createEnvironment is starting.
INFO: Using elasticbeanstalk-us-east-1-682416359150 as Amazon S3 storage bucket for environment data.
INFO: Environment health has transitioned to Pending. Initialization in progress (running for 16 seconds). There are no instances.
INFO: Created target group named: arn:aws:elasticloadbalancing:us-east-1:682416359150:targetgroup/awseb-AWSEB-UQD3G956E0CO/1a6aa54b9b2c9f0c
INFO: Created security group named: sg-0dfdbd70
INFO: Created security group named: awseb-e-4b7mqaea4w-stack-AWSEBSecurityGroup-AIXW9FCZMRTF
INFO: Created Auto Scaling launch configuration named: awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingLaunchConfiguration-1UH8AE6R7O1KK
INFO: Created Auto Scaling group named: awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingGroup-1E83K50I2JZTV
INFO: Waiting for EC2 instances to launch. This may take a few minutes.
INFO: Created Auto Scaling group policy named: arn:aws:autoscaling:us-east-1:682416359150:scalingPolicy:3a0a01df-bd3d-468f-a67a-07493b6f8e13:autoScalingGroupName/awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingGroup-1E83K50I2JZTV:policyName/awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingScaleDownPolicy-1B1HRWA2CYYTX
INFO: Created Auto Scaling group policy named: arn:aws:autoscaling:us-east-1:682416359150:scalingPolicy:1f6b09dc-67f4-43fa-bf6d-82217f228239:autoScalingGroupName/awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingGroup-1E83K50I2JZTV:policyName/awseb-e-4b7mqaea4w-stack-AWSEBAutoScalingScaleUpPolicy-18YKVWY7RFJGI
INFO: Created CloudWatch alarm named: awseb-e-4b7mqaea4w-stack-AWSEBCloudwatchAlarmHigh-2M0WJ0G6G6I
INFO: Created CloudWatch alarm named: awseb-e-4b7mqaea4w-stack-AWSEBCloudwatchAlarmLow-UGBEPS390ACE
INFO: Created load balancer named: arn:aws:elasticloadbalancing:us-east-1:682416359150:loadbalancer/app/awseb-AWSEB-15Q5TBQJ33JUA/0fc94991528e4ce6
INFO: Created Load Balancer listener named: arn:aws:elasticloadbalancing:us-east-1:682416359150:listener/app/awseb-AWSEB-15Q5TBQJ33JUA/0fc94991528e4ce6/327c205734a7fa12
INFO: Added instance [i-0e38f7c2d8f954197] to your environment.
INFO: Successfully pulled nginx:latest
INFO: Successfully built aws_beanstalk/staging-app
INFO: Docker container 25a304610612 is running aws_beanstalk/current-app.
INFO: Environment health has transitioned from Pending to Ok. Initialization in progress on 1 instance. 0 out of 1 instance completed (running for 4 minutes).
INFO: Successfully launched environment: my-nginx-proxy-dev
```

### Interacting w/ Your Application
The name you give your environment will dictate the DNS entry for visiting your
app. Assuming the same configuration as above, you can now visit your running
proxy here: http://my-nginx-proxy-dev.us-east-1.elasticbeanstalk.com. You'll
likely want to configure a CNAME entry on your domain of choice actual use, but
that is an exercise left to the reader.

### Managing and Deploying Environments
Not yet written. PRs welcome!

[AWS]: http://aws.amazon.com
[Docker]: https://www.docker.com/
[Elastic Beanstalk CLI]: http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html
