which aws_completer &> /dev/null

if [ $? == 0 ]; then
  complete -C "$(which aws_completer)" aws
fi

CF_CREATE_STATES="CREATE_IN_PROGRESS CREATE_FAILED CREATE_COMPLETE"
CF_ROLLBACK_STATES="ROLLBACK_IN_PROGRESS ROLLBACK_FAILED ROLLBACK_COMPLETE"
CF_DELETE_STATES="DELETE_IN_PROGRESS DELETE_FAILED DELETE_COMPLETE"
CF_UPDATE_STATES="UPDATE_IN_PROGRESS UPDATE_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_COMPLETE"
CF_ROLLBACK_STATES="UPDATE_ROLLBACK_IN_PROGRESS UPDATE_ROLLBACK_FAILED UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS UPDATE_ROLLBACK_COMPLETE"

function _cf_status_filters() {
  filters=""
  for status in $@
  do
    filters+=" --stack-status-filter ${status} "
  done
  echo $filters
}

function ls-stacks() {
  aws cloudformation describe-stacks | jq '.Stacks[] | .StackName + " - " + .StackStatus' | sed -e 's/^"//' -e 's/"$//'
}

function ls-bucket() {
  local bucket
  bucket=$1
  if [[ -z $bucket ]]; then
    echo "Must provide bucket name"
    return 1
  fi

  aws s3 ls --recursive $bucket
}

function ls-buckets() {
  aws s3 ls | cut -d ' ' -f3
}
alias lsb=ls-buckets
