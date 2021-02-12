#/usr/bin/env bash

# see LICENSE file for permission on using it 

# update all branches of IT tools git local repo
# does the same whatever it is hosted on gitlab or github currently
function init () {
    export error=0 
    export logpath=/home/francois/GITLAB/logs
    export workpath=/home/francois/git/IT
    export homepath=/home/francois/GITLAB
    export otherspath=/home/francois/GITLAB/others
}

# clear variable at end of script is more or less useless but ... 
function cleanram () {
    unset error
    unset logpath
    unset workpath
    unset homepath
    unset otherspath
    unset path
    unset subdir
}

# before starting anything check & build directory for logs
function resetlogs () { 
    if [ ! -e $logpath ] ; then
        mkdir -p $logpath
        if [ $? -ne 0 ] ; then
            echo creating $logpath error 
            echo
            (( error++ ))
        else
            echo $logpath already exists
        fi
    else
        # set files & test they are writable
        echo post date in head of new log filess 
        for i in $logpath/$0.$(date +%Y%m%d).{log,err}
        do
            date "+%Y-%m-%d   %H:%M" > $i # ensure file is empty but a header can be written
            if [ $? -ne 0 ] ; then
                echo error while creating empty $i 
                echo
                (( error++ ))
            fi
        done
    fi
    return $error
}

# if logpath is existing loop around found sub paths : they should be git repos.
# verify if so & then fetch/pull if tracking & fetch are ready.
function loopover () {
    for path in $homepath/[dD]*/ $otherspath/[a-z]*/ $workpath/[amuw]*
    do
        if [ -d $path ] ; then 
            ( 
                (
                    # on each subpath do 
                    for subdir in $(find $path/ -maxdepth 3 -mindepth 1 -type d -name ".git" -printf '%f\n')
                    do
                        echo ----$path/$subdir/../----start
                        if [ -d .git ] ; then
                            cd $path/$subdir
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
                            echo ----$subdir----stop
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
}

function compressoldlogs () {
    # from here this is only display & space management
    echo
    echo "for details you can look at : "
    echo "$logpath/$0.$(date +%Y%m%d).err and $logpath/$0.$(date +%Y%m%d).log"
    echo
    echo purge log path from older files and compressing recent ones.
    find $logpath/ -ctime +10 -exec rm {} \; 
    if [ $? -ne 0 ] ; then 
        (( error++ ))
    fi
    find $logpath/ ! -name "*.gz" -ctime +1 -exec gzip {} \; 
    if [ $? -ne 0 ] ; then 
        (( error++ ))
    fi
    return $error
}

function main() {
    # just to step a final line
    echo -----------------$0-START---------------
        init
        resetlogs
        loopover
        compressoldlogs 
        cleanram
    echo -----------------$0-END-----------------
    echo
    return $error
}

main
exit $error
