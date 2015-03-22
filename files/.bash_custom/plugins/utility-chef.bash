function cookbook() {
  if [ -a $(pwd)/metadata.rb ]; then
    cat metadata.rb | grep ^name | awk '{print $2}' | sed $'s/\'//g'
  fi
}
