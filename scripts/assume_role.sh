export DOCKER_IMAGE="quay-int.mckinsey-solutions.com/nvt-platform/mckube-config-applier:${BRANCH}"
docker pull ${DOCKER_IMAGE}
ARN=$(docker run --rm -v $(pwd):/workdir/config ${DOCKER_IMAGE} -config-path config/ -template "arn:aws:iam::{{ .AWSAccount.ID }}:role/{{ .AWSAccount.RoleName }}")
python <<EOF > aws_creds_env.sh
import botocore.session
session = botocore.session.get_session()
client = session.create_client('sts')
response = client.assume_role(
   RoleArn='$ARN',
   RoleSessionName='k8s_jenkins',
   DurationSeconds=14400
)
print "export AWS_ACCESS_KEY_ID=" + response['Credentials']['AccessKeyId']
print "export AWS_SECRET_ACCESS_KEY=" + response['Credentials']['SecretAccessKey']
print "export AWS_SESSION_TOKEN=" + response['Credentials']['SessionToken']
EOF
