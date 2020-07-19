#!/bin/sh

# workspace management

log () {
    printf '%s\n' "tofc: ws: $*"
}

die () {
    log "$*"
    exit 1
}

usage () {
cat << EOF
tofc ws: workspace expansion pack for tofu

usage: tofc ws <->[opt]
    send    sends a window to a workspace
    init    create workspaces
    switch  switch what workspace is shown
    query   show shell parseable info
    hookc   a CREATE hook to attach windows
    hookd   a DESTROY hook to clean up windows
EOF
}

switch_ws () {
    [ -d "$WM/ws/$1" ] || die "workspace $1 not found"
    read -r current < "$WM/ws/current"

    for win in "$WM/ws/$current"/*; do
        tofc unmap "${win##*/}"
    done
    #printf '%s\n' "false" >> "$WM/ws/$current"/*/mapped

    for win in "$WM/ws/$1"/*; do
        tofc map "${win##*/}"
    done
    #printf '%s\n' "true" >> "$WM/ws/$1"/*/mapped

    printf '%s\n' "$1" > "$WM/ws/current"
}

remove_win () {
    rm "$WM"/ws/*/"$1"
}

add_win () {
    read -r current < "$WM/ws/current"
    ln -sfT "$WM/fs/$wid" "$WM/ws/$current/$wid"
    tofc map "$wid"
}

send_win () {
    # tofc ws send $ws $wid
    remove_win "$wid"
    ln -sfT "$WM/fs/$wid" "$WM/ws/$1/$wid"
    read -r current < "$WM/ws/current"
    if [ -e "$WM/ws/$current/$wid" ]
        then tofc map "$wid"
    else
        tofc unmap "$wid"
    fi
}

init_ws () {
    for ws; do
        if [ -d "$WM/ws/$ws" ]; then
            rm "$WM/ws/$ws"/*
            mkdir -p "$WM/ws/$ws"
        else
            mkdir -p "$WM/ws/$ws"
        fi
    done
}

query_ws () {
    for dir in "$WM"/ws/*; do
        i=0
        [ -d "$dir" ] && \
            for win in $dir/*; do
                [ "$win" = "$dir/*" ] && continue
                : $(( i = i + 1 ))
            done
            printf '%s\n' "${dir##*/}: $i"
    done
}

clean_wins () {
    for file in "$WM"/ws/*; do
        [ -d "$file" ] && for win in "$file"/*; do
            rm "$win"
        done
    done
}

main () {
    opt="$1"
    shift 1
    case $opt in
        *init)   init_ws    "$@" ;;
        *send)   send_win   "$@" ;;
        *switch) switch_ws  "$@" ;;
        *query)  query_ws   "$@" ;;
        *hookc)  add_win    "$@" ;;
        *hookd)  remove_win "$@" ;;
        *clean)  clean_wins "$@" ;;
        *usage|*help)  usage     ;;
        *) usage && die "not found" ;;
    esac
}

main "$@"
