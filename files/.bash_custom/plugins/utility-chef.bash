function cookbook() {
  if [ -a $(pwd)/metadata.rb ]; then
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

function chef_endpoint() {
  cat $(readlink ~/.chef/knife.rb) | grep chef_server_url | awk '{ print $2 }' | basename $(cut -d ':' -f2) | tr -d '"'
}
