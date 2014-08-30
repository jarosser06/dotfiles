_boxer()
{
  _script_commands="update install reconfigure"

  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${_script_commands}" -- ${cur}) )

  return 0
}

complete -o nospace -F _boxer boxer
