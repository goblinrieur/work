#!/usr/bin/env bash
# script revision 0.2 - 2021-3-3

####################################################################################
# this displays a help menu
####################################################################################
function usage()
{
    echo
    echo "$0 -h         displays this help"
    echo "$0 --help     can also be used"
    echo "$0            runs the job with default values"
    echo "$0 /somepath  runs the job with specified path"
    echo
    exit 0
}

####################################################################################
# before starting anything check & build directory for logs
####################################################################################
function make_logdir()
{
    # change this path depending on you own infrastructure & file tree
    export logpath=/home/francois/GITLAB/logs
    if [ ! -e $logpath ] ; then
        mkdir -p $logpath
        if [ $? -ne 0 ] ; then
            echo creating $logpath error 
            echo
            return 1
        fi
    else
        # set files & test they are writable
        for i in $logpath/$0.$(date +%Y%m%d).{log,err}
        do
            date "+%Y-%m-%d   %H:%M" > $i 
            if [ $? -ne 0 ] ; then
                echo error while creating empty $i 
                echo
                return 1
            fi
        done
    fi
}

####################################################################################
# if a parameter is given it might be a replacement of homepath value
####################################################################################
function check_parameter()
{
    # update all branches of IT tools git local repo
    # does the same whatever it is hosted on git-lab or GitHub currently
    # adapt to your own directories structures : 
    export workpath="/home/francois/git/IT"
    export homepath="/home/francois/GITLAB/[dD]*"
    export otherspath="/home/francois/GITLAB/others/*"
    case $1 in 
        -[hH] | --[hH][eE][lL][pP] ) 
            usage
            return 1
        ;;
        "" )
            export workpath="/home/francois/git/IT"
            export homepath="/home/francois/GITLAB/[dD]*"
            export otherspath="/home/francois/GITLAB/others/*"
            return 0
        ;;
        *)
            if [ ! -d $1 ] ; then 
                # but if it is not a directory just reject action 
                echo directory given as first parameter : \"$1\" does not exist
                echo
                return 1
            else
                # inform user he choose only one path
                echo treat only $1 directory
                # update only branches git local repo behind $1 parameter
                export homepath="$1"    # overwrite it to use parameter instead
                export workpath=""      # then do not use workpath 
                export otherspath=""    # then do not use otherspath 
                return 0
            fi
        ;;
    esac
    return 0
}

####################################################################################
# compare each git repos to local repos
####################################################################################
function gitem_all()
{
    for path in $homepath $otherspath $workpath
    do
        if [ -d $path ] ; then 
            ( 
                (
                    # on each subpath do 
                    for i in $(find $path/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
                    do
                        cd $path/$i
                        if [ -d .git ] ; then
                            # if it is really a git repo then work on it 
                            echo ----$i----start
                            echo check branch
                            git branch --remotes | grep --invert-match '\->' | while read remote 
                                do 
                                    echo track branch
                                    # be careful bellow it is one line cut in 2 to avoid useless info messages
                                    git branch --track "${remote#origin/}" "$remote" 
                                done
                            echo fetch
                            git fetch --all
                            echo pull
                            git pull --all
                            echo ----$i----stop
                            echo
                        else
                            echo ----ignore-not-a-local-git-workdir----
                            echo
                        fi
                    done
                # be careful bellow it is one line cut in 3 for better readings
                ) | tee --append $logpath/$0.$(date +%Y%m%d).log \
            ) 3>&1 1>&2 2>&3 | grep --ignore-case --invert-match ' already exists.' | \
            tee --append $logpath/$0.$(date +%Y%m%d).err
        fi
        echo ----------done-all-of-$path----------
        echo
    done
    return 0
}

####################################################################################
# simple exit function managing the created logfiles
####################################################################################
function exitit()
{
    # just to step a final line
    # from here this is only display & space management
    echo
    echo "for details you can look at : "
    echo "$logpath/$0.$(date +%Y%m%d).err and $logpath/$0.$(date +%Y%m%d).log"
    echo
    echo purge log path from older files and compressing recent ones.
    find $logpath/ -ctime +10 -exec rm {} \; &
    find $logpath/ ! -name "*.gz" -ctime +1 -exec gzip {} \; &
    echo -----END-----
    echo
}

####################################################################################
# global script
####################################################################################
function main() 
{
    check_parameter "$@"    || return 1 	# manage script on path given as a parameter or using defaults 
    make_logdir             || return 1 	# displays error message on logdir management
    gitem_all               || return 1 	# real git work is done here
    exitit                  && return 0 	# message is useful only on exit 0
}

####################################################################################
# run it with command line parameter 
####################################################################################
main "$@"
exit 
