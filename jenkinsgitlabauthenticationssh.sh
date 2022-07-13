  #!/bin/bash
  
  GITLAB_URL="https://gitlab.com/api/v4/user/keys"
  JENKINS_URL="18.212.227.97:8080"
  BOT_USERNAME="admin"
  BOT_USER_TOKEN="119b506c532115f6f272d9b3b5ddb4e031"
  SSH_TITLE="BOT_NEW_KEY"
  DATE_AFTER_90_DAYS=$(date +'%m/%d/%Y' -d "+90 days")
  GITLAB_TOKEN="glpat-iJLkxQBrjwG1ftQWQ_6s"

  if [ -f ./sshkey/id_rsa ]; then
      echo "DELETING OLD KEYS"
      rm -f ./sshkey/id_rsa
      rm -f ./sshkey/id_rsa.pub
      echo "Genrating NEW SSH KEYS in ./sshkey/id_rsa "
      ssh-keygen -b 2048 -t rsa -f ./sshkey/id_rsa -q -N ""
      echo ""
      echo "SSH KEYS GENRATED"
      ls -al
  else
      mkdir ./sshkey
      echo "Genrating SSH KEYS in ./sshkey/id_rsa "
      ssh-keygen -b 2048 -t rsa -f ./sshkey/id_rsa -q -N ""
      echo ""
      echo "SSH KEYS GENRATED"
      ls -al
  fi


  if [ -f ./sshkey/id_rsa ]; then
      echo "SSH key exists."
      echo "Uploading public key to gitlab"
      curl -X POST -F "private_token=${GITLAB_TOKEN}" \
          -F "title=${SSH_TITLE}" -F "key=$(cat ./sshkey/id_rsa.pub)" -F "expires_at=${DATE_AFTER_90_DAYS}" ${GITLAB_URL}
      echo ""
      echo "Keys are uploaded to gitlab: ${GITLAB_URL}"
  else
      echo "Unable to find SSH Keys  //  something went wrong exiting"
      exit 1
  fi
  
  
  ==========================================================================================
  
  
  In this example, 2 steps have been used in jenkins execute bash step. Jenkins is running with the help of docker image jenkins/jenkins:latest
  
  #!/bin/bash

GITLAB_URL="https://gitlab.com/api/v4/user/keys"
JENKINS_URL="18.212.227.97:8080"
BOT_USERNAME="admin"
BOT_USER_TOKEN="119b506c532115f6f272d9b3b5ddb4e031"
SSH_TITLE="BOT_NEW_KEY"
DATE_AFTER_90_DAYS=$(date +'%m/%d/%Y' -d "+90 days")
GITLAB_TOKEN="glpat-iJLkxQBrjwG1ftQWQ_6s"


echo "creating creds file"

SSH_PRIVATE_KEY="$(cat ./sshkey/id_rsa)"

echo "http://${BOT_USERNAME}:${BOT_USER_TOKEN}@${JENKINS_URL}/credentials/store/system/domain/_/createCredentials"

CRUMB=$(curl -s 'http://${BOT_USERNAME}:${BOT_USER_TOKEN}@${JENKINS_URL}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
  
curl -H $CRUMB -X POST "http://${BOT_USERNAME}:${BOT_USER_TOKEN}@${JENKINS_URL}/credentials/store/system/domain/_/createCredentials" --data-urlencode 'json={
  "": "0",
  "credentials": {
    "scope": "GLOBAL",
    "id": "'test-jenkins-id'",
    "username": "'test-username'",
    "password": "",
    "privateKeySource": {
      "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
      "privateKey": "$SSH_PRIVATE_KEY",
    },
    "description": "ssh_keys_Creds",
    "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
  }
}'
