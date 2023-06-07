#!/bin/bash

CHOICE_FILE=$(mktemp /tmp/XXXXXXXX)
ACCOUNT_FILE=$(mktemp /tmp/XXXXXXXX)
PASSWORD_FILE=$(mktemp /tmp/XXXXXXXX)

PASSWORD_STORE=$1

if [ -z "$PASSWORD_STORE" ]; then
    PASSWORD_STORE="./passwords.txt"
    if [ ! -f "$PASSWORD_STORE" ]; then
        touch "$PASSWORD_STORE"
    fi

elif [ ! -f "$PASSWORD_STORE" ]; then
    touch "$PASSWORD_STORE"
fi

trap "rm -f $CHOICE_FILE $ACCOUNT_FILE $PASSWORD_FILE" EXIT

display_menu() {
    dialog --backtitle "Password Manager" --title "Main Menu" \
        --menu "Choose an option:" 12 50 4 \
        1 "Store a password" \
        2 "Retrieve a password" \
        3 "Exit" 2>$CHOICE_FILE
}

store_password() {
    dialog --backtitle "Password Manager" --title "Store a Password" \
        --inputbox "Enter the account name:" 8 40 2>$ACCOUNT_FILE

    dialog --backtitle "Password Manager" --title "Store a Password" \
        --insecure --passwordbox "Enter the password:" 8 40 2>$PASSWORD_FILE

    account=$(cat $ACCOUNT_FILE)
    password=$(cat $PASSWORD_FILE)
    echo "$account:$password" >>$PASSWORD_STORE

    dialog --backtitle "Password Manager" --title "Success" \
        --msgbox "Password stored successfully!" 8 40
}

retrieve_password() {
    dialog --backtitle "Password Manager" --title "Retrieve a Password" \
        --inputbox "Enter the account name:" 8 40 2>$ACCOUNT_FILE

    account=$(cat $ACCOUNT_FILE)
    password=$(grep "^$account:" $PASSWORD_STORE | cut -d: -f2)

    if [ -z "$password" ]; then
        dialog --backtitle "Password Manager" --title "Error" \
            --msgbox "Password not found!" 8 40
    else
        zenity --info --title="Password Manager" --text="Account: $account\nPassword: $password"
    fi
}

while true; do
    display_menu
    CHOICE=$(cat $CHOICE_FILE)
    case "$CHOICE" in
    1)
        store_password
        ;;
    2)
        retrieve_password
        ;;
    *)
        exit
        ;;
    esac
done
