#!/bin/bash

while getopts rnl:m: OPT; do
    case $OPT in
    l)
        LIMIT=$OPTARG
        ;;
    r)
        REVERSE=1
        ;;
    n)
        INCLUDE_NUMBERS=1
        ;;
    m)
        MIN_OCCURANCES=$OPTARG
        ;;
    *)
        echo "Usage: $0 [-r] [-n] [-m MIN_OCCURANCES] [-l LIMIT] FILE"
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

FILE=$1

if [ ! -f "$FILE" ]; then
    echo "File $FILE does not exist."
    exit 1
fi

if [ -z "$LIMIT" ]; then
    LIMIT=10
elif [ "$LIMIT" -le 0 ]; then
    echo "Limit must be positive number."
    exit 1
fi

RAW_WORDS=$(grep -oE '\w+' "$FILE")

if [ -z "$INCLUDE_NUMBERS" ]; then
    WORDS=$(echo "$RAW_WORDS" | sed 's/[^[:alpha:]]//g' | sed '/^$/d')
else
    WORDS=$(echo "$RAW_WORDS" | sed 's/[^[:alnum:]]//g')
fi

LOWERCASE_WORDS=$(echo "$WORDS" | tr '[:upper:]' '[:lower:]')

SORTED_WORDS=$(echo "$LOWERCASE_WORDS" | sort)

WORDS_COUNT=$(echo "$SORTED_WORDS" | uniq -c)

if [ -n "$MIN_OCCURANCES" ]; then
    WORDS_COUNT=$(echo "$WORDS_COUNT" | awk "\$1 >= $MIN_OCCURANCES {print \$0}")
fi

if [ -n "$REVERSE" ]; then
    SORTED_WORDS_COUNT=$(echo "$WORDS_COUNT" | sort -n)
else
    SORTED_WORDS_COUNT=$(echo "$WORDS_COUNT" | sort -nr)
fi

echo "$SORTED_WORDS_COUNT" | head -n $LIMIT
