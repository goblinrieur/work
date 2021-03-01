#/usr/bin/env bash

# before starting anything check & build directory for logs
export logpath=/home/francois/GITLAB/logs
if [ ! -e $logpath ] ; then
    mkdir -p $logpath
    if [ $? -ne 0 ] ; then
        echo creating $logpath error 
        exit 1
    fi
else
    # set files & test they are writable
    for i in $logpath/$0.$(date +%Y%m%d).{log,err}
    do
        date "+%Y-%m-%d   %H:%M" > $i 
        if [ $? -ne 0 ] ; then
            echo error while creating empty $i 
            exit 1
        fi
    done
fi


# if a parameter is given it might be a replacement of homepath value
if [ $# -gt 0 ] ; then
    if [ ! -d $1 ] ; then 
        # but if it is not a directory just reject action 
        echo directory given as first parameter is not existing
        exit 1
    else
        # inform user he choose only one path
        echo treat only $1 directory
    fi
    # update only branches git local repo behind $1 parameter
    export homepath="$1"
    echo $homepath
else
    # update all branches of IT tools git local repo
    # does the same whatever it is hosted on gitlab or github currently
    # adapt to your own directories structures : 
    export workpath="/home/francois/git/IT"
    export homepath="/home/francois/GITLAB/[dD]*"
    export otherspath="/home/francois/GITLAB/others/*"
fi

# if logpath is existing loop around found paths to work over each one
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

# from here this is only display & space management
echo
echo "for details you can look at : "
echo "$logpath/$0.$(date +%Y%m%d).err and $logpath/$0.$(date +%Y%m%d).log"
echo
echo purge log path from older files and compressing recent ones.
find $logpath/ -ctime +10 -exec rm {} \; &
find $logpath/ ! -name "*.gz" -ctime +1 -exec gzip {} \; &

# just to step a final line
echo -----END-----
echo
exit 0
