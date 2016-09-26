#!/usr/bin/env bash

LC_ALL=C
LANG=C
set -o nounset
set -o pipefail
set -o errexit
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
clear

function main()
{
    if [[ ! -d ${DIR_PATH} ]]
    then
        printf "%s\n" "Check your path"
        exit 1
    else
        if [[ $(ls -1 ${DIR_PATH} \
            | awk -F. '!/\// && /./ {print $NF}' \
            | wc -l) -le 2 ]]
        then
            printf "%s\n" "2 files or less with extensions in ${DIR_PATH}"
            exit 0
        fi
    fi

    f_count
}

function f_count()
{
    if [[ ${RCRSV} = "REC" ]]
    then
        LS_OPT="-1FR"
    else
        LS_OPT="-1F"
    fi

    if [[ -n ${EXTENSIONS} ]]
    then
        _DIR_PATH="ls ${LS_OPT} ${DIR_PATH}${EXTENSIONS}"
    else
        _DIR_PATH="ls ${LS_OPT} ${DIR_PATH}"
    fi

    if [[ ${NUM_SORT} = "SORTED" ]]
    then
        _F_CNT_TOT=$(echo ${_DIR_PATH} \
            | . /dev/fd/0 \
            | awk -F. '/./ {print $NF}' \
            | grep -v / \
            | sort \
            | uniq -c \
            | sort -nr)
    else
        _F_CNT_TOT=$(echo ${_DIR_PATH} \
            | . /dev/fd/0 \
            | awk -F. '/./ {print $NF}' \
            | grep -v / \
            | sort \
            | uniq -c )
    fi

    if [[ -z ${_F_CNT_TOT} ]]
    then
        exit 1
    else
        _F_CNT=${_F_CNT_TOT}
    fi

    local _F_CNT_NM=$(echo ${_DIR_PATH} \
        | . /dev/fd/0 \
        | awk -F. '/./ {print $NF}' \
        | grep -v / \
        | sort \
        | uniq \
        | wc -L )

    if [[ ${_F_CNT_NM} -le 9 ]]
    then
        _F_CNT_NAME=9
    else
        _F_CNT_NAME=${_F_CNT_NM}
    fi

    out
}

function out()
{
    # color steps
    local CSTEP1="\033[32m"
    local CSTEP2="\033[33m"
    local CSTEP3="\033[31m"
    local CSTEPc="\033[0m"

    # total number of countable elements
    local VMIN=1
    if [[ $(echo "${_F_CNT}" \
        | awk 'BEGIN {max=0} {if($1>max) max=$1} END {print max}') -eq 1 ]]
    then
        local VMAX="2"
    else
        local VMAX=$(echo "${_F_CNT}" \
            | awk 'BEGIN {max=0} {if($1>max) max=$1} END {print max}')
    fi

    # length of bar
    local _TOT_COLS=$(tput cols)
    let COLA=${_F_CNT_NAME}
    let COLD=${_TOT_COLS}-${COLA}-10
    let CHR=${COLD}+2
    local DMIN=1
    local DMAX=${CHR}

    # generate output
    echo "${_F_CNT}" \
        | awk \
        --assign COLA="$COLA" \
        --assign COLD="$COLD" \
        --assign DMIN="$DMIN" \
        --assign DMAX="$DMAX" \
        --assign VMIN="$VMIN" \
        --assign VMAX="$VMAX" \
        --assign CSTEP1="$CSTEP1" \
        --assign CSTEP2="$CSTEP2" \
        --assign CSTEP3="$CSTEP3" \
        --assign CSTEPc="$CSTEPc" \
        --assign BAR_CHR="$BAR_CHR" \
        'BEGIN {printf("%"COLA"s %5s %2s%"COLD"s\n",\
        "filetype","count","|<","bar chart >|")}
        {
            x=int(DMIN+($1-VMIN)*(DMAX-DMIN)/(VMAX-VMIN));
            printf("%"COLA"s %5s ",$2,$1);
            for(i=1;i<=x;i++)
                {
                    if (i >= 1 && i <= int(DMAX/3))
                        {printf(CSTEP1 BAR_CHR CSTEPc);}
                    else if (i > int(DMAX/3) && i <= int(2*DMAX/3))
                        {printf(CSTEP2 BAR_CHR CSTEPc);}
                    else
                        {printf(CSTEP3 BAR_CHR CSTEPc);}
                };
                print ""
            }'
}

function usage()
{
cat <<EOL

NAME
    ${PROGNAME} - show bar graphs of dir file types

SYNOPSIS
    ${PROGNAME} [OPTION]...

DESCRIPTION
    This script shows a bar graph with the total count
    of files in a dir according to extension.

    -b [character]
            This is to specify what character you want to use to
            draw your bar graphs. If this option is used, place
            the character in quotes (ex: "#").
            Default is "#"

    -d [path]
            This is to specify the path to be used. Need to input
            this for the script to work.

    -e [ext{,ext,ext}]
            This option is to select a single or list of extensions
            to show in the bargraph.
            Usage is either { -e "foo" } for single extension or
            { -e "foo,bar,baz" } for multiple. Always comma separated.

    -h      Show this file (usage).

    -r      Recursive.

    -s      This sorts output according to most files.
            Default is sorted by name.

    -v      Show version.

EOL
exit 0
}

function version()
{
    cat <<EOL
EOL
}

# the actual selector of the script
BAR_CHR="#"
EXTENSIONS=""
NUM_SORT="UNSORTED"
RCRSV=""
while getopts "b:d:e:hrsv" OPT
do
    case "${OPT}" in
        'b')
            BAR_CHR=${OPTARG}
            ;;
        'd')
            if [[ "${OPTARG}" != */ ]]
            then
                readonly DIR_PATH="${OPTARG}/"
            else
                readonly DIR_PATH="${OPTARG}"
            fi
            ;;
        'e')
            if [[ $( echo ${OPTARG} \
                | tr "," "\n" \
                | wc -l) -le 1 ]]
            then
                EXTENSIONS="*.${OPTARG}"
            else
                EXTENSIONS="*.{$(echo ${OPTARG} \
                    | tr -d " " \
                    | tr "," "\n" \
                    | sort \
                    | uniq \
                    | awk -v ORS=, '{print $1}' \
                    | head -c -1)}"
            fi
            ;;
        'h')
            usage
            ;;
        'r')
            RCRSV="REC"
            ;;
        's')
            NUM_SORT="SORTED"
            ;;
        'v')
            version
            ;;
        *)
            usage ;;
    esac
done
[ ${OPTIND} -eq 1 ] && { usage ; }
shift $((OPTIND-1))
main
