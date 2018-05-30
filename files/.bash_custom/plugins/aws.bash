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

##### CloudFormation Shortcuts #####
alias cf-ls-stacks="aws cloudformation describe-stacks | jq '.Stacks[] | .StackName + \" - \" + .StackStatus' | sed -e 's/^\"//' -e 's/\"$//'"
