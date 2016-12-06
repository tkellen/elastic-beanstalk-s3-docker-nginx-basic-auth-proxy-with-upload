##
# Generate an IAM policy granting full access to the IPs of all elastic
# beanstalk instances. For local testing, manually add the public IP of
# your development machine.
#

#!/bin/bash
set -e

function ips {
  for env in "$(eb list)"; do
    echo "$env"                 | # print the env name
    sed -e 's/^\* //'           | # remove leading "* ", if any
    xargs -L1 eb status         | # get status of the env
    sed -n -e 's/^.*CNAME: //p' | # extract cname of the env
    xargs -L1 dig -x {} +short    # get ip of the env
  done
}

cat << POLICY
{
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::bocoup-test/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "$(ips | xargs | sed -e 's/ /","/g')"
          ]
        }
      }
    }
  ]
}
POLICY
