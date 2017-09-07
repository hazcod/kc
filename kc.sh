#!/usr/bin/env bash

#set -x

keychain="pass"

function unlockKeychain {
	security unlock-keychain "${keychain}.keychain"
}

function getEntries {
	security dump-keychain -d "${keychain}.keychain" | grep srvr | cut -d '=' -f 2 | awk '{print substr($0, 2, length($0) - 2)}'	
}

function findEntry {
	matches=()

	entries=$(getEntries)

	for entry in ${entries[@]}; do

        if [[ $entry == "$1" ]]; then
            matches+=("$entry")
            break
        fi
            
        if [[ $entry == *"$1"* ]]; then
			matches+=("$entry")
		fi
	done

	if (( ${#matches[@]} == 0 )); then
		>&2 echo "No matches found for $1"
		return
	fi

	if (( ${#matches[@]} > 1 )); then
		>&2 echo "Multiple matches:"
		for match in ${matches[@]}; do
			>&2 echo "- $match"
		done
		return
	fi

	echo "${matches[0]}"
}

function getPassword {
	entry=$(findEntry "$1")

	if [ -z "${entry//}" ]; then
		return
	fi

	security find-internet-password -w -s "$entry"
}

if [ -z "$1" ]; then
	echo "Usage: $0 <website>"
	exit 1
fi

unlockKeychain || exit 1
getPassword "$1"
