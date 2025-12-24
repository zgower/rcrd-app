# rcrd-app
Small bash script to automate the deletion of files from the downloads folder of configured workstations
---
- Project created to assist with a work project. 
- addss.sh and delss.sh are used to create workstations that rcrd.sh will use. 
- This script assumes that a pre-shared key has been created on the central server that runs it. 
---
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
    -v      (--version)         : Displays current version and exit


