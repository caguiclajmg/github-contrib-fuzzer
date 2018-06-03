#
# github-contrib-fuzzer.sh
#
# Author:
#       John Mark Gabriel Caguicla <caguicla.jmg@hapticbunnystudios.com>
#
# Copyright (c) 2018 John Mark Gabriel Caguicla
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#!/bin/bash

case $OSTYPE in
    linux-gnu)
        CMD_DATE="date"
        CMD_TR="tr"
        ;;
    darwin*)
        CMD_DATE="gdate"
        if [[ -z "$(command -v $CMD_DATE)" ]]; then
            echo "ERROR: $CMD_DATE not found, please install GNU coreutils"
            exit -1
        fi

        CMD_TR="gtr"
        if [[ -z "$(command -v $CMD_TR)" ]]; then
            echo "ERROR: $CMD_TR not found, please install GNU coreutils"
            exit -1
        fi
        ;;
    *)
        echo "[WARN] Unsupported platform!"
        CMD_DATE="date"
        CMD_TR="tr"
        ;;
esac

DATE_FROM="$($CMD_DATE -I)"
DATE_TO="$($CMD_DATE -I)"
WORKING_DIR="$(pwd)"
TARGET_FILE="dummy.txt"
DRAW_MESSAGE=""
COMMIT_COUNT="rnd"
COMMIT_MIN=1
COMMIT_MAX=10

date_from_pixel () {
    DATE_START=$1
    X=$2
    Y=$3

    if [[ $X -lt 0 ]] || [[ $X -gt 52 ]]; then return -1; fi
    if [[ $Y -lt 0 ]] || [[ $Y -gt 6 ]]; then return -1; fi

    DATE=$($CMD_DATE -I -d "$DATE_START + $(( ($X * 7) + $Y )) day")
    echo "$DATE"

    return 0
}

asc() {
    echo -n $1 | od -An -tuC | xargs
    return 0
}

random_string() {
    COUNT=32
    if [[ -n "$1" ]]; then
        COUNT=$1
    fi

    head /dev/urandom | $CMD_TR -dc A-Za-z0-9 | head -c $COUNT
    echo ""

    return 0
}

terminate() {
    case $1 in
        0)
            echo "INFO: Success"
            ;;
        1)
            echo "Usage: github-contrib-fuzzer git_repository"
            echo "       github-contrib-fuzzer -df date_from  -dt date_to"
            echo "       github-contrib-fuzzer -df date_from -m draw_message"
            ;;
        2)
            echo "ERROR: Invalid 'from' date"
            ;;
        3)
            echo "ERROR: Invalid 'to' date"
            ;;
        4)
            echo "ERROR: Directory does not contain a git repository"
            ;;
        5)
            echo "ERROR: Unknown parameter $2"
            ;;
        *)
            echo "ERROR: Unknown error occured"
            ;;
    esac

    if [[ $1 -eq 0 ]] || [[ $1 -eq 1 ]]; then exit 0; else exit -1; fi
}

ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -df|--date-from)
            DATE_FROM="$(($CMD_DATE -I -d $2) 2> /dev/null)" || terminate 2
            shift
            shift
            ;;
        -dt|--date-to)
            DATE_TO="$(($CMD_DATE -I -d $2) 2> /dev/null)" || terminate 3
            shift
            shift
            ;;
        -f|--target-file)
            TARGET_FILE=$2
            shift
            shift
            ;;
        -m|--draw-message)
            DRAW_MESSAGE=$2
            shift
            shift
            ;;
        --commit-count)
            COMMIT_COUNT=$2
            shift
            shift
            ;;
        --commit-min)
            COMMIT_MIN=$2
            shift
            shift
            ;;
        --commit-max)
            COMMIT_MAX=$2
            shift
            shift
            ;;
        -n|--create-directory)
            DIR_CREATE=true
            shift
            shift
            ;;
        -h|--help)
            terminate 1
            shift
            shift
            ;;
        -*|--*)
            terminate 5 $1
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${ARGS[@]}"

if [[ -z $1 ]]; then terminate 1; fi

WORKING_DIR="$1"

if [[ ! -e $WORKING_DIR ]] && [[ "$DIR_CREATE" = true ]]; then
    mkdir -p "$WORKING_DIR"
    pushd "$WORKING_DIR" > /dev/null
    git init > /dev/null
    popd > /dev/null
fi

pushd "$WORKING_DIR" > /dev/null

if [[ ! "$(git rev-parse --git-dir 2>/dev/null)" ]]; then terminate 4; fi

touch "$TARGET_FILE"

DATES=()
if [[ -n $DRAW_MESSAGE ]]; then
    # TODO: I don't know how to do pixel fonts
    FONTS[$(asc \s)]="5 5 00000000000000000000000000000000000"
    FONTS[$(asc 0)]="5 5 01110100011100110101100111000101110"
    FONTS[$(asc 1)]="5 5 00100011001010000100001000010011111"
    FONTS[$(asc 2)]="5 5 01110100010000100010001000100011111"
    FONTS[$(asc 3)]="5 5 01110100010000100110000011000101110"
    FONTS[$(asc 4)]="5 5 10010100101001011110000100001000010"
    FONTS[$(asc 5)]="5 5 11110100001000011110000100001011110"
    FONTS[$(asc 6)]="5 5 11110100001000011110100101001011110"
    FONTS[$(asc 7)]="5 5 11110000100001000010000100001000010"
    FONTS[$(asc 8)]="5 5 01110100011000101110100011000101110"
    FONTS[$(asc 9)]="5 5 11110100101001011110000100001000010"
    FONTS[$(asc A)]="5 5 01110100011000111111100011000110001"
    FONTS[$(asc B)]="5 5 11110100011000111110100011000111110"
    FONTS[$(asc C)]="5 5 01110100011000010000100001000101110"
    FONTS[$(asc D)]="5 5 11110100011000110001100011000111110"
    FONTS[$(asc E)]="5 5 11111100001000011110100001000011111"
    FONTS[$(asc F)]="5 5 11111100001000011110100001000010000"
    FONTS[$(asc G)]="5 5 01110100011000010111100011000101110"
    FONTS[$(asc H)]="5 5 10001100011000111111100011000110001"
    FONTS[$(asc I)]="5 5 11111001000010000100001000010011111"
    FONTS[$(asc J)]="5 5 00001000010000100001100011000101110"
    FONTS[$(asc K)]="5 5 10001100011011011000101101000110001"
    FONTS[$(asc L)]="5 5 10000100001000010000100001000011111"
    FONTS[$(asc M)]="5 5 11011101011010110101101011010110101"
    FONTS[$(asc N)]="5 5 10001100011100110101100111000110001"
    FONTS[$(asc O)]="5 5 01110100011000110001100011000101110"
    FONTS[$(asc P)]="5 5 11100100101001011100100001000010000"
    FONTS[$(asc Q)]="5 5 01110100011000110001101011001001101"
    FONTS[$(asc R)]="5 5 11110100011000111110101001001010001"
    FONTS[$(asc S)]="5 5 01111100001000001110000010000111110"
    FONTS[$(asc T)]="5 5 11111001000010000100001000010000100"
    FONTS[$(asc U)]="5 5 10001100011000110001100011000101110"
    FONTS[$(asc V)]="5 5 10001100011000110001100010101000100"
    FONTS[$(asc W)]="5 5 10001100011000110001101011101110001"
    FONTS[$(asc Y)]="5 5 10001100011000101010001000010000100"
    FONTS[$(asc Z)]="5 5 11111000010001000100010001000011111"

    for((i=0;i<${#DRAW_MESSAGE};++i)); do
        CHAR="${DRAW_MESSAGE:$i:1}"
        DATA="${FONTS[$(asc $CHAR)]}"

        if [[ -z "$DATA" ]]; then
            echo "WARN: Character $CHAR does not exist in font, replacing with space"
            DATA="${FONTS[$(asc \s)]}"
        fi

        OFFSET=$(( i * 6 ))

        for((j=0;j<=35;++j)); do
            X=$(( OFFSET + (j % 5) ))
            Y=$(( j / 5 ))

            if [[ "${DATA:$j:1}" = "1" ]]; then
                for((k=0;k<10;++k)); do
                    DATES+=("$(date_from_pixel $DATE_FROM $X $Y)")
                done
            fi
        done
    done
else
    DATE=$DATE_FROM
    while [ "$DATE" != "$DATE_TO" ]; do
        if [[ "$COMMIT_COUNT" = "rnd" ]]; then
            COUNT="$(($COMMIT_MIN + $RANDOM % $COMMIT_MAX))"
        else
            COUNT="$COMMIT_COUNT"
        fi

        for ((i=1;i<=$COUNT;++i)); do
            DATES+=($DATE)
        done

        DATE=$($CMD_DATE -I -d "$DATE + 1 day")
    done
fi

for DATE in "${DATES[@]}"; do
    echo "$(random_string)" > $TARGET_FILE

    git add $TARGET_FILE
    git commit -m "$DATE" --date $DATE &> /dev/null
done

if [[ -n "$(git remote -v | grep '(push)')" ]]; then
    git push -u origin master &> /dev/null
else
    echo "WARN: Remote not found, add a remote and push it using 'git push -u origin master'"
fi

popd > /dev/null

terminate 0