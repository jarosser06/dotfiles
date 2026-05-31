### Shortcut commands


function proc-on-port() {
    local port
    port=$1

    if [[ -z $port ]]; then
        lsof -iTCP -sTCP:LISTEN

    else
        lsof -i :${port} -sTCP:LISTEN
    fi
}
