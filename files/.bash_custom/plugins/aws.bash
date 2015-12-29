which aws_completer &> /dev/null

if [ $? == 0 ]; then
  complete -C "$(which aws_completer)" aws
fi
