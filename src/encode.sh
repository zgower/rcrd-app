#! /usr/bin/env bash
[ -z $1 ] && DIR=$(pwd) || DIR=${1%/};
read -s -p "Enter Password: " PASSWORD; echo "";
if [ -n "$2" ]; then
	KEY="$2"
else
	read -p "Enter Key (leave blank for random): " KEY
fi
[ -z ${KEY} ] && KEY=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)
touch $DIR/$KEY.enc
HASH=$(echo $PASSWORD | openssl aes-256-cbc -a -salt -pass pass:$KEY -pbkdf2); echo $HASH > $DIR/$KEY.enc
if [ -n "$3" ]; then
	if [ "$3" -eq "1" ]; then
		echo "Hash generated"
	fi
else
	echo "Your hash: $HASH"
	echo "Your key : $KEY"
fi
