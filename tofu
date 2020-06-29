#!/bin/sh

# Window manager

log () {
    printf '%s\n' "${0##*/}: $*" | tee "$WM/log"
}

die () {
    log "$*"
    exit 1
}

usage () {
cat << EOF
${0##*/}: window manager
usage: ${0##*/} [-hv]
EOF
}

cleanup() {
    fusermount3 -u "$WM/fs" # unmount x11fs
    "$conf/end" || log "end: couldn't run end hook"
}

wm_init () {
    # The function responsible for initialising the wm.

    :>"$WM/log"
    log "init: start"

	mkdir -p "$WM/fs"

    x11fs "$WM/fs"

    :>"$WM/event"

    "$conf/autostart" || log "init: couldn't run autostart hook"

    mkdir -p "$WM/ws"
    log "init: end"
}

event_parse () {
    log "main: start"

    :>"$WM/event"

    tail -f "$WM/event" \
    | while read -r ev wid; do
		class=''
        while read -r line
            do class=${class#:}:${line}
        done < "$WM/fs/$wid/class"

		read -r title < "$WM/fs/$wid/title"

        [ -x "$conf/hooks/$ev" ] && "$conf/hooks/$ev" "$wid" "$class" "$title"
    done
    log "main: end"
}

mirror_event () {
    # shellcheck disable=2002
    cat "$WM/fs/event" \
    | while read -r line
        do printf '%s\n' "$line" >> "$WM/event"
    done
}

main () {
    case $1 in
        -h|*help) usage && exit 0 ;;
        -v|*version) printf '%s\n' "${0##*/}: v git" && exit 0 ;;
        '') : ;;
        *) usage && die "option $1 not found"
    esac

    conf="${XDG_CONFIG_HOME:-$HOME/.config}"

	trap 'cleanup' KILL INT TERM STOP

    : "${WM:=$HOME/.tofu}"
    export WM

    mkdir -p "$WM" || die "couldn't create wm directory"

    wm_init
    mirror_event &
    event_parse
}

main "$@"
