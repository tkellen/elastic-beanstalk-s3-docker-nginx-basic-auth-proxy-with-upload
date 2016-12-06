# elastic-beanstalk-s3-docker-nginx-basic-auth-proxy-with-upload
> secure a bucket behind basic authentication without thinking about infra

*This assumes you have an [AWS] account, associated credentials with access
to manage elastic beanstalk applications.*

### Setup
First, fork and clone this repo. Then, install the [Elastic Beanstalk CLI],
adding a `eb-cli` profile to your AWS credentials to `~/.aws/config` like so:
```
[profile eb-cli]
aws_access_key_id = AKIAIMZWLTOOSTF6JN4A
aws_secret_access_key = NszqaFD+YDZrrIKzlL7dI2F3z4bF9pZUetQsItln
```

Next, edit `nginx.conf` to reference the bucket you're trying to proxy.
```
set $bucket 'my-bucket-name';
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
It's time to put your Dockerized proxy on the internet!
Next, run `eb init my-application-name` and answer the prompts to create a new
application.

Here is a sample output:
```
~/code/elastic-beanstalk-s3-docker-nginx-basic-auth-proxy-with-upload
❯ eb init nginx-s3-proxy

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
Application nginx-s3-proxy has been created.

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

Start by creating a dev environment using `eb create --single`.

*Note: specifying `--single` is important for this simplified workflow, it
prevents a load balancer from being used, which in turn makes generating a
ip-based bucket policy (discussed later in this document) very easy.*

Here is a sample output:
```
~/code/elastic-beanstalk-s3-docker-nginx-basic-auth-proxy-with-upload
❯ eb create --single
Enter Environment Name
(default is nginx-s3-proxy-dev):
Enter DNS CNAME prefix
(default is nginx-s3-proxy-dev):
Creating application version archive "app-b250-161206_053805".
Uploading nginx-s3-proxy/app-b250-161206_053805.zip to S3. This may take a while.
Upload Complete.
Environment details for: nginx-s3-proxy-dev
  Application name: nginx-s3-proxy
  Region: us-east-1
  Deployed Version: app-b250-161206_053805
  Environment ID: e-kffemm5vcp
  Platform: 64bit Amazon Linux 2016.09 v2.2.0 running Docker 1.11.2
  Tier: WebServer-Standard
  CNAME: nginx-s3-proxy-dev.us-east-1.elasticbeanstalk.com
  Updated: 2016-12-06 10:38:10.375000+00:00
Printing Status:
INFO: createEnvironment is starting.
INFO: Using elasticbeanstalk-us-east-1-682416359150 as Amazon S3 storage bucket for environment data.
INFO: Created security group named: awseb-e-kffemm5vcp-stack-AWSEBSecurityGroup-ZD3EYR0PSO9G
INFO: Created EIP: 34.193.217.87
INFO: Environment health has transitioned to Pending. Initialization in progress (running for 8 seconds). There are no instances.
INFO: Waiting for EC2 instances to launch. This may take a few minutes.
INFO: Added instance [i-01781b1d09c2aa1b6] to your environment.
INFO: Successfully pulled nginx:latest
INFO: Successfully built aws_beanstalk/staging-app
INFO: Docker container 069a7c03322f is running aws_beanstalk/current-app.
INFO: Environment health has transitioned from Pending to Ok. Initialization completed 5 seconds ago and took 4 minutes.
INFO: Successfully launched environment: nginx-s3-proxy-dev
```

### Interacting w/ Your Application
You can now visit your proxy by running `eb open`.

### Granting Upload Access to S3 Bucket (or read access to private buckets)
If your bucket is private, the easiest way to give your application access is
to apply a bucket policy that grants full access by IP. A utility is included
in this repository to generate the correct policy. Running `./policy.sh` will
output a bucket policy you can apply manually in S3.

#### Allowing Uploads
If you have applied the bucket policy mentioned above, it is now possible to
upload files directly to your bucket via the proxy. To test this, run the
following:
```
curl -T path/to/file.ext http://username:password@host/uploads/file.ext
```

*The included nginx config only allows uploading to URIs that begin with
`~/uploads`*

### Managing and Deploying Environments
Not yet written. PRs welcome!

[AWS]: http://aws.amazon.com
[Docker]: https://www.docker.com/
[Elastic Beanstalk CLI]: http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html
