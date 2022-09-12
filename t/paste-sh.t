#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u

if [ -z "${URL_SH_X_TESTING-}" ]
then
    echo '1..0 # SKIP X testing requires user consent. Set URL_SH_X_TESTING to go for it.'
    exit 0
fi
if [ -z "${DISPLAY-}" ]
then
    echo 'X testing requires '\$'DISPLAY to be set. Maybe run the test under xvfb-run(1)?' >&2
    exit 255
fi
for cmd in xterm tmux xdotool xclip
do
    if ! command -v "$cmd" > /dev/null
    then
        echo "$cmd is not installed" >&2
        exit 255
    fi
done

if [ -z "${0%%*/*}" ]
then
    cd "${0%/*}"
fi
url=$(grep -E '^https?:' ../README)
url=${url%%$'\n'*}
test_name=${0##*/}
test_name=${test_name%.t}
shell=${test_name##*-}
echo "# shell = $shell"
tmpdir=$(mktemp -d -t url.sh.test.XXXXXX)
touch "$tmpdir/.zshrc"
export ZDOTDIR="$tmpdir"
PATH="$PATH:$PWD/ucowsay"
declare -i i=0
echo 1..3
for q in '' '"' "'"
do
    i+=1
    tmux_socket="$tmpdir/tmux.$i.socket"
    run_tmux()
    {
        tmux -f /dev/null -S "$tmux_socket" "$@"
    }
    xterm -e tmux -f /dev/null -S "$tmux_socket" new-session "$shell" &
    pid=$!
    for ((j=0; j<20; j++))
    do
        [ -S "$tmux_socket" ] && break
        xdotool sleep 0.1
    done
    stat "$tmux_socket" > /dev/null
    wid=$(xdotool search --limit=1 --pid="$pid" --name tmux)
    geom=$(xdotool getwindowgeometry --shell "$wid")
    eval "$geom"
    code="true $q$url$q"
    xclip -l 1 -i <<< "$code"
    xdotool \
        windowfocus --sync "$wid" \
        mousemove --sync $((RANDOM%16)) $((RANDOM%16)) \
        mousemove --sync --window "$wid" $((WIDTH/2)) $((HEIGHT/2)) \
        click 2 \
        type $'\n'
    xdotool sleep 0.1
    out=$(run_tmux capture-pane -p -E 12)
    # shellcheck disable=SC2001
    sed -e 's/^/# T> /' <<< "$out"
    run_tmux kill-window
    wait
    short_url="${url%%';'*}…"
    short_code="true $q$short_url$q"
    msg="ok $i «$short_code» code execution"
    case $out in
        *'< pwned >'*);;
        *) msg="not $msg";;
    esac
    [ "$shell" = zsh ] && msg="$msg # TODO https://github.com/jwilk/url.sh/issues/2"
    echo "$msg"
done
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh
