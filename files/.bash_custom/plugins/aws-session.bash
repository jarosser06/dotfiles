if [[ $SHELL == *"zsh" ]]; then
  autoload bashcompinit
  bashcompinit
fi

# Clear Env Variables

function clear_aws_env {
  for env in $(env | grep AWS)
  do
    env_name=$(echo ${env} | cut -d '=' -f1)
    unset $env_name
  done
}

# Borrowed from git-completion
if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
  if [[ -z ${ZSH_VERSION:+set} ]]; then
    _get_comp_words_by_ref ()
    {
      local exclude cur_ words_ cword_
      if [ "$1" = "-n" ]; then
        exclude=$2
        shift 2
      fi
      __git_reassemble_comp_words_by_ref "$exclude"
      cur_=${words_[cword_]}
      while [ $# -gt 0 ]; do
        case "$1" in
        cur)
          cur=$cur_
          ;;
        prev)
          prev=${words_[$cword_-1]}
          ;;
        words)
          words=("${words_[@]}")
          ;;
        cword)
          cword=$cword_
          ;;
        esac
        shift
      done
    }
  else
    _get_comp_words_by_ref ()
    {
      while [ $# -gt 0 ]; do
        case "$1" in
        cur)
          cur=${COMP_WORDS[COMP_CWORD]}
          ;;
        prev)
          prev=${COMP_WORDS[COMP_CWORD-1]}
          ;;
        words)
          words=("${COMP_WORDS[@]}")
          ;;
        cword)
          cword=$COMP_CWORD
          ;;
        -n)
          # assume COMP_WORDBREAKS is already set sanely
          shift
          ;;
        esac
        shift
      done
    }
  fi
fi

function aws-tok() {
  acct=$1
  if [[ -z $acct ]]; then
    echo "Missing alias argument"
    return 1
  fi

  eval "$(aws-session auth -A ${acct})"
}

function aws-web() {
  acct=$1
  if [[ -z $acct ]]; then
    echo "Missing alias argument"
    return 1
  fi

  if [[ -z $BROWSER ]]; then
    echo 'Missing required environment variable $BROWSER'
    return 1
  fi

  if [[ $(uname) == 'Darwin' ]]; then
    open -a "$BROWSER" $(aws-session web -A ${acct})
  else
    $BROWSER $(aws-session web -A ${acct})
  fi
}

function tok_active_env() {
  if [[ -z $AWS_SESSION_EXPIRATION ]]; then
    return 1
  fi

  if [[ $AWS_SESSION_EXPIRATION -gt $(date +%s) ]]; then
    echo " [${AWS_ACCOUNT_NAME}]"
  fi
}

__tok_env_bash_autocomplete() {
  local cur opts
  COMPREPLY=()
  _get_comp_words_by_ref cur
  opts=$( aws-session list )

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}

complete -F __tok_env_bash_autocomplete aws-tok
complete -F __tok_env_bash_autocomplete aws-web
