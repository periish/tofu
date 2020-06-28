#!/bin/sh -e

# lemonbar script for tofu
# outputs like so
# +---+-+

is_empty () {
    if [ "$(ls -A $1)" ]
        then return 1
    else
        return 0
    fi
}

while sleep 1; do
    printf '%s' "%{c}"
    for dir in "$WM"/ws/*; do
        [ -f "$dir" ] && continue
        if is_empty "$dir"; then
            chr='-'
        else
            chr='+'
        fi

        read -r f < "$WM/ws/current"
        [ "$f" = "${dir##*/}" ] && chr="%{F#fe7290}${chr}%{F-}"
        printf '%s' "$chr"
    done
    printf '\n'
done | lemonbar \
        -f "cozette" \
        -B "#fbfbfb" \
        -F "#3b3b3b" \
        -I "#90a8e9" \
        -i 1 \
        -d \
        -g 90x20+1820+5

