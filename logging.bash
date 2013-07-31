#!/bin/bash
##
## Simple logging mechanism for Bash
##
## Author: Michael Wayne Goodman <goodman.m.w@gmail.com>
##
## License: Public domain; do as you wish
##

exec 3>&2 # logging stream (file descriptor 3) defaults to STDERR
verbosity=2 # default to show warnings
silent_lvl=0
err_lvl=1
wrn_lvl=2
dbg_lvl=3
inf_lvl=4

notify() { log $silent_lvl "NOTE: $1"; } # Always prints
error() { log $err_lvl "ERROR: $1"; }
warn() { log $wrn_lvl "WARNING: $1"; }
debug() { log $dbg_lvl "DEBUG: $1"; }
inf() { log $inf_lvl "INFO: $1"; } # "info" is already a command
log() {
    if [ $verbosity -ge $1 ]; then
        # Expand escaped characters, wrap at 70 chars, indent wrapped lines
        echo -e "$2" | fold -w70 -s | sed '2~1s/^/  /' >&3
    fi
}

### EXAMPLE COMMAND LINE ARGUMENTS ###

usage() {
    echo "Usage:"
    echo "  $0 [OPTIONS]"
    echo "Options:"
    echo "  -h|--help        : display this help message"
    echo "  -d|--debug       : print debug messages"
    echo "  -q|--quiet       : suppress warning messages"
    echo "  -v|--verbosity=N : manually set verbosity level"
    echo "  -l|--log=FILE    : redirect logging to FILE instead of STDERR"
    exit 1
}

longopts="help debug quiet verbosity: log:"
shortopts="hdqv:l:"

set -- `getopt -n$0 -u --longoptions="$longopts" --options="$shortopts" -- "$@"` || usage

while [[ $1 == -* ]]; do
    case "$1" in
       --help|-h) usage; exit 0 ;;
       --debug|-d) verbosity=$dbg_lvl; shift ;;
       --quiet|-q) verbosity=$err_lvl; shift ;;
       --verbosity|-v) verbosity=$2; shift 2 ;;
       --log|-l) exec 3>>$2; shift 2 ;;
       --) shift; break ;;
       *) error "Invalid options: $1"; usage; exit 1 ;;
    esac
done
args="$@"

notify "This logging system uses the standard verbosity level mechanism to choose which messages to print. Command line arguments customize this value, as well as where logging messages should be directed (from the default of STDERR). Long messages will be split at spaces to wrap at a character limit, and wrapped lines are indented. Wrapping and indenting can be modified in the code."

inf "Inspecting argument list: $args"

if [ ! "$args" ]; then
    warn "No arguments given"
else
    for arg in $args; do
        debug "$arg"
    done
fi
