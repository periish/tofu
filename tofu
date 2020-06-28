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

wm_init () {
    # The function responsible for initialising the wm.

    :>"$WM/log"
    log "init: start"

	[ -d "$WM/fs" ] && mkdir -p "$WM/fs"

    x11fs "$WM/fs"
    :>"$WM/event"
    if [ -e "$conf/autostart" ]; then
        [ -x "$conf/autostart" ] || chmod +x "$conf/autostart"
        "$conf/autostart"
    else
        log "init: autostart not found, skipping"
    fi

    [ -d "$WM/ws" ] || mkdir "$WM/ws"
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

    if [ -d "$XDG_CONFIG_HOME" ]
        then conf="$XDG_CONFIG_HOME/tofu"
    else
        conf="$HOME/.config/tofu"
    fi
	trap "$conf/end" KILL INT TERM
    [ -z "$WM" ] && WM="$HOME/.tofu"
    mkdir -p "$WM" || die "couldn't create wm directory"

    wm_init
    mirror_event &
    event_parse
}

main "$@"
