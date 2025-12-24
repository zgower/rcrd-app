#! /usr/bin/env bash
_SCRIPT_DIR=$(dirname -- $(readlink -f -- "$0"))
echo "Setup Support Station"
echo "Add public RSA key to remote Support Station"
read -p "Enter the hostname of the new Support Station (support-station-x.local): " SSHOSTNAME
ssh-copy-id administrator@"$SSHOSTNAME"
echo ""
echo "Setup Encoding for Administrator user"
SSHOSTNAME=$(ssh administrator@"$SSHOSTNAME" "hostname")
[ -d "$_SCIRPT_DIR/supportstation" ] && echo "supportstation dir exists" || mkdir "$_SCRIPT_DIR/supportstation"
$_SCRIPT_DIR/tools/encode.sh "$_SCRIPT_DIR/supportstation" "$SSHOSTNAME" 1
[ ! -f "$_SCRIPT_DIR/ss.list" ] && touch "$_SCRIPT_DIR/ss.list"
echo "$SSHOSTNAME" >> "$_SCRIPT_DIR/ss.list"
