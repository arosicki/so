#!/bin/bash

while getopts D OPT; do
    case $OPT in
    D)
        DELETE=1
        ;;
    *)
        echo "Usage: $0 [-D] DIR"
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

DIR=$1

declare -A HASHES
declare -A DUPLICATES

FILES=$(find "$DIR" -type f)

for FILE in $FILES; do
    HASH=$(md5sum "$FILE" | cut -d ' ' -f 1)

    if [[ -z ${HASHES[$HASH]} ]]; then
        HASHES[$HASH]="$FILE"
        continue
    fi

    echo "Duplicate found: $FILE"
    echo "Original: ${HASHES[$HASH]}"

    if [ -z "$DELETE" ]; then
        echo
        continue
    fi

    echo "Delete? Duplicate/Original/Both/None [d/o/b/n]: "
    read ANSWER

    while [[ $ANSWER =~ "[dobnDOBN]{1}" ]]; do
        echo "Invalid option."
        echo "Delete? Duplicate/Original/Both/None [d/o/b/n]: "
        read ANSWER
    done

    case $ANSWER in
    [dD])
        rm "$FILE"
        ;;
    [oO])
        rm "${HASHES[$HASH]}"
        HASHES[$HASH]="$FILE"
        ;;
    [bB])
        rm "$FILE"
        rm "${HASHES[$HASH]}"
        unset "HASHES[$HASH]"
        ;;
    [nN]) ;;
    esac
done
