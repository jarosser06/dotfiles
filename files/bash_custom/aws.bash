
##### S3 Shortcuts #####
alias s3-ls-buckets="aws s3 ls | cut -d ' ' -f3"

function s3-ls-bucket() {
  local bucket
  bucket=$1
  if [[ -z $bucket ]]; then
    echo "Missing argument bucket name"
    return 1
  fi

  aws s3 ls --recursive $bucket
}

##### Account Shortcuts #####
function active_aws_account() {
  which jq &> /dev/null
  if [[ ${?} -ne 0 ]]; then
    return 1
  fi

  local acct
  acct=$(aws sts get-caller-identity | jq .Account | sed 's/"//g')
  if [[ ${?} -eq 0 ]]; then
    echo ${acct}
  fi

  return 0
}

PS_ACTIVE_AWS_ENABLED=0
function __aws_active_acct_ps() {
  if [[ ${PS_ACTIVE_AWS_ENABLED} -ne 1 ]]; then
    return 0
  fi
  echo " [AWS:$(active_aws_account)]"
}

##### CloudFormation Shortcuts #####
alias cf-ls-stacks="aws cloudformation describe-stacks | jq '.Stacks[] | .StackName + \" - \" + .StackStatus' | sed -e 's/^\"//' -e 's/\"$//'"
