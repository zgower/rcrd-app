#! /usr/bin/env bash
if [ -z $1 ]; then
	echo -n "Enter Hash: "; read HASH;
	echo -n "Enter Key : "; read KEY; echo "";
	echo $HASH | openssl aes-256-cbc -d -a -pass pass:$KEY -pbkdf2
else
	echo $1 | openssl aes-256-cbc -d -a -pass pass:$2 -pbkdf
fi
