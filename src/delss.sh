#! /usr/bin/env bash
_SCRIPT_DIR=$(dirname -- $(readlink -f -- "$0"))
read -p "Enter Hostname to remove (support-station-x.local): " SSHOSTNAME
grep -iv "$SSHOSTNAME" "$_SCRIPT_DIR/ss.list" > "$_SCRIPT_DIR/ss.list.tmp"
sleep 1
mv "$_SCIRPT_DIR/ss.list.tmp" "$_SCRIPT_DIR/ss.list"
find "$_SCRIPT_DIR/supportstation" -iname "$SSHOSTNAME.enc" -delete
