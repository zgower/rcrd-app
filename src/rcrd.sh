#! /usr/bin/env bash
#============
#Title: Ribbon Compliance Removes Downloads (rcrd)
#Author: Zachary Gower
#Date: 2025-06-11
rcrdVersion=1.5.2
#============

SUPPORT_STATIONS=()
_MDEPTH="1"
_MTIME="-1"
_DEL=0
_TIMEOUT=20
_RUSER="administrator"
_SCRIPT_DIR=$(dirname -- $(readlink -f -- "$0"))
_DECODE="ssdecode.sh"
_RSA="$HOME/.ssh/id_rsa"
_DECODE_DIR="$_SCRIPT_DIR/$_DECODE"
logStd(){
    OIFS="$IFS"
    IFS=$'\n'
    for entry in $1; do
        echo "rcrd $entry ==="
        logger "rcrd $entry ==="
    done
    IFS="$OIFS"
}
loadSupportStations(){
    if [ -f "$2/$1" ]; then
        SUPPORT_STATIONS=()
        while read -r line; do
            SUPPORT_STATIONS+=("$line")
        done < $2/$1
    else
        exit 2
    fi
}
checkSupportStations(){
    if [ -f "$2/$1" ]; then
        SUPPORT_STATIONS=()
        while read -r line; do
            if [ "${line,,}" = "${3,,}" ]; then
                SUPPORT_STATIONS+=("$line")
            fi
        done < $2/$1
    else
        exit 2
    fi
    if [ ${#SUPPORT_STATIONS[@]} -eq 0 ]; then
        logStd "Not a configured Support Station; $3"
        exit 4
    fi
}
makeCMD(){
    cmd="if [ -f 'Documents/$2' ]; then "
    cmd+="./Documents/$2 $1 | sudo -S su - > /dev/null 2>&1; "
    cmd+="for dir in /Users/*; do "
    cmd+='if [ -d "$dir" ]; then '
    cmd+='if [ -d "$dir/Downloads" ]; then '
    cmd+='echo -n "Entries found for $dir: "; '
    cmd+='sudo bash -c "/usr/bin/find $dir/Downloads '
    cmd+="-mindepth $3 -mtime $4 "
    cmd+='! -name \".*\" -depth -print" | wc -l; '
    cmd+='sudo bash -c "/usr/bin/find $dir/Downloads '
    cmd+="-mindepth $3 -mtime $4 "
    cmd+='! -name \".*\" '
    [ $5 -eq 0 ] && cmd+='-depth -print"; ' || cmd+='-delete"; '
    [ $5 -gt 0 ] && cmd+='echo "Entries Removed"; '
    cmd+="fi; fi; done; rm ~/Documents/$2; fi; exit;"
    echo "$cmd"
}
uploadDecode(){
    logStd "Upload Start"
    [ -f "$2" ] && scp -o ConnectTimeout="$4" "$2" "$1":Documents/$3 || exit 3
    logStd "Upload Done"
}
stationCMD(){
    logStd "Connecting to remote host"
    output=$(ssh -n -i "$5" -o ConnectTimeout="$4" "$1" "$(makeCMD "$2" "$3" "$6" "$7" "$8")")
    logStd "$output"
}
main(){
    for ss in "${SUPPORT_STATIONS[@]}"; do
        station="$_RUSER@$ss"
        logStd "Working on $ss"
        if [ -f "$_SCRIPT_DIR/supportstation/"$ss".enc" ]; then
            read -r hash < $_SCRIPT_DIR/supportstation/"$ss".enc
            uploadDecode "$station" "$_DECODE_DIR" "$_DECODE" "$_TIMEOUT"
            stationCMD "$station" "$hash" "$_DECODE" "$_TIMEOUT" "$_RSA" "$_MDEPTH" "$_MTIME" "$_DEL"
        else
            logStd "No encryption file for $ss; Exiting"
        fi
        logStd "Work completed on $ss"
    done
}
rcrdhelp(){
    echo "Ribbon Compliance Removes Download (rcrd) parameters
        usage:  rcrd [-ss hostname] [-mdepth 1] [-mtime -1] [-to 20] [-del] [-h] [-v]

        -ss     (--supportstation)  : Sets a specific support station. Must have been preconfigured; default is to build list
        -mdepth (--min-depth)       : Sets minimum level of directories for search; default is 1
        -mtime  (--min-time)        : Sets minimum amount of file age for search; default is -1 
                                        -1 - file would be less than one day
                                        +1 - file would be greater than one day
                                         2 - file would be exactly two days of age
        -to     (--timeout)         : Sets timeout time, in seconds, for ssh connections; default is 20
        -del    (--delete)          : Sets rcrd to delete files; default is to not delete
        -h      (--help)            : Displays this help and exit
        -v      (--version)         : Displays current version and exit"
}
while [ -n "$1" ]; do
    case $1 in
        --min-depth | --MIN-DEPTH | -mdepth | -MDEPTH)
            shift; [ -n "$1" ] && _MDEPTH="$1"; shift;
        ;;
        --min-time | --MIN-TIME | -mtime | -MTIME)
            shift; [ -n "$1" ] && _MTIME="$1"; shift;
        ;;
        --delete | --DELETE | -del | -DEL)
            _DEL=1; shift; 
        ;;
        --timeout | --TIMEOUT | -to | -TO)
            shift; [ -n "$1" ] && _TIMEOUT="$1"; shift;
        ;;
        --help | --HELP | -h | -H)
            rcrdhelp; exit 1
        ;;
        --version | --VERSION | -v | -V)
            logStd $rcrdVersion; exit 1
        ;;
        --supportstation | --SUPPORTSTATION | -ss | -SS)
            shift; [ -n "$1" ] && checkSupportStations "ss.list" "$_SCRIPT_DIR" "$1"; shift;
        ;;
        *)
        shift;
    esac
done
logStd "Starting $(date)"
[ ${#SUPPORT_STATIONS[@]} -eq 0 ] && loadSupportStations "ss.list" "$_SCRIPT_DIR"
main
logStd "Complete $(date)"
