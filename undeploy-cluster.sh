#!/bin/bash
AWS_PATH_VAR=0
AWS_KEY_VAR=0

CONFIRM="no"
echo "Are you sure about undeploy the cluster? (yes/no)"
read CONFIRM

if [ $(echo $CONFIRM | tr [:upper:] [:lower:]) = 'yes' ] 
then
  if [[ ${AWS_PATH} ]]
  then  
      export AWS_PATH_VAR=1
      docker run -it --rm -v ${AWS_PATH}:/root/.aws --name deploy-cluster deploy-cluster ./undeploy.sh
  
  elif [[ -n ${AWS_ACCESS_ID} && -n ${AWS_ACCESS_KEY_ID} ]]
  then
      export AWS_KEY_VAR=1
      docker run -it --rm -e AWS_ACCESS_ID=${AWS_ACCESS_ID} -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} --name deploy-cluster deploy-cluster ./undeploy.sh
  else
      echo 'Miss the variables to use AWS keys. Should export "AWS_PATH" with path to aws config (~/.aws) or use AWS_ACCESS_ID/AWS_ACCESS_KEY_ID'
      exit 6
  fi
else
  echo "Request cancel"
  exit 10
fi
