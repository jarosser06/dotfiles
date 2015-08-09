function cookbook() {
  if [[ -a $(pwd)/metadata.rb ]]; then
    cat metadata.rb | grep ^name | awk '{print $2}' | sed $'s/\'//g'
  fi
}

function activate_chefdk() {
  eval "$(chef shell-init bash)"
}

function purge_cookbooks() {
  cookbooks=$(knife cookbook list | awk '{ print $1 }')

  for cookbook in $cookbooks
  do
    knife cookbook delete $cookbook -a -y
  done
}

function chef_mode() {
  if [[ -f ${HOME}/.chef_mode ]]; then
    cat ${HOME}/.chef_mode
  else
    echo false
  fi
}

function chef_endpoint() {

  if [[ -f ${HOME}/.chef/knife.rb ]]; then
    if [[ -h ${HOME}/.chef/knife.rb ]]; then
      cat $(readlink ${HOME}/.chef/knife.rb) | grep chef_server_url | awk '{ print $2 }' | basename $(cut -d ':' -f2) | tr -d '"'
    else
      cat ${HOME}/.chef/knife.rb | grep chef_server_url | awk '{ print $2 }' | basename $(cut -d ':' -f2) | tr -d '"'
    fi
  fi
}

function _ps_chef_org() {
  if [[ $(chef_mode) == 1 ]]; then
    org=$(chef_endpoint)
    if ! [[ "$org" == "" ]]; then
      echo " [${org}]"
    fi
  fi
}
