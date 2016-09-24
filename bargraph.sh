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
        if [[ $(find ${DIR_PATH} -maxdepth 1 -type f -name "*.*" \
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
    if [[ -n ${EXTENSIONS} ]]
    then
        #_DIR_PATH="${DIR_PATH}${EXTENSIONS}"
        eval $(echo _DIR_PATH=${DIR_PATH}${EXTENSIONS})
    else
        _DIR_PATH=${DIR_PATH}
    fi

    #echo "extensions = ${EXTENSIONS}"
    #echo "dir path = ${_DIR_PATH}"

    local _F_CNT_RAW=$(find "${_DIR_PATH}" ${MAX_DEPTH} -type f -printf "%f\n" \
        | awk -F. '/./ {print $NF}' \
        | sort )

    if [[ ${NUM_SORT} = "SORTED" ]]
    then
        _F_CNT_TOT=$(echo "${_F_CNT_RAW}" \
            | uniq -c \
            | sort -k 1,1 -r)
        if [[ $(echo ${_F_CNT_TOT} \
            | awk '{total = total + $1}END{print total}') \
            -le $(echo ${_F_CNT_TOT} \
            | wc -l) ]]
        then
            printf "%s\n" "One file one extension."
            exit 1
        fi
    else
        _F_CNT_TOT=$(echo "${_F_CNT_RAW}" \
            | uniq -c )
        if [[ $(echo ${_F_CNT_TOT} \
            | awk '{total = total + $1}END{print total}') \
            -le $(echo ${_F_CNT_TOT} \
            | wc -l) ]]
        then
            printf "%s\n" "One file one extension."
            exit 1
        fi
    fi

    if [[ -z ${_F_CNT_TOT} ]]
    then
        exit 1
    else
        _F_CNT=${_F_CNT_TOT}
    fi

    local _F_CNT_NM=$(echo "${_F_CNT_RAW}" \
        | uniq \
        | wc -L)

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
    local VMAX=$(echo "${_F_CNT}" \
        | awk 'BEGIN {max=0} {if($1>max) max=$1} END {print max}')

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

    -h      Show this file (usage).

    -m      Max depth to search. With this option set, the script
            will search a folder recursively.
            Default is a depth of "1".

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
MAX_DEPTH="-maxdepth 1"
NUM_SORT="UNSORTED"
while getopts "b:d:e:hmsv" OPT
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
            EXTENSIONS="*.{$(echo ${OPTARG} \
                | tr -d " " \
                | tr "," "\n" \
                | sort \
                | uniq \
                | awk -v ORS=, '{print $1}' \
                | head -c -1)}"
            ;;
        'h')
            usage
            ;;
        'm')
            MAX_DEPTH=""
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
