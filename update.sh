#/usr/bin/env bash
export logpath=/home/francois/GITLAB/logs
export devpath=/home/francois/GITLAB/dev
export diypath=/home/francois/GITLAB/diy
export docpath=/home/francois/GITLAB/doc
export otherpath=/home/francois/GITLAB/other
export workpath=/home/francois/git/IT/
# update all branches of IT tools git local repo
# does the same whatever it is hosted on gitlab or github currently

if [ ! -e $logpath ] ; then
    mkdir -p $logpath
    if [ $? -ne 0 ] ; then
        echo logpath error
        exit 1
    fi
fi

# if logpath is ok loop around found paths to work over each one

for path in $devpath $diypath $docpath $otherpath $workpath
do
    if [ -d $path ] ; then
        (
        for i in $(find $path/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
        do
            cd $i 
            echo ----$i----start
            echo check branch
            git branch --remotes | grep --invert-match '\->' | while read remote 
                do 
                    git branch --track "${remote#origin/}" "$remote" 
                    echo track branch
                done
            git fetch --all
            echo fetch
            git pull --all
            echo pull
            cd ..
            echo back to main dir
            echo ----$i----stop
            echo
        done
        echo done
        echo
        ) 2> $logpath/$0.$(date +%Y%m%d).err | tee $logpath/$0.$(date +%Y%m%d).log
    fi
done
# from here this is only display & space management
echo
echo "for details you can look at : "
echo "$logpath/$0.$(date +%Y%m%d).err and $logpath/$0.$(date +%Y%m%d).log"
echo
echo purge log path from older files 
find $logpath/ -ctime +10 -exec rm {} \; 
echo compressing log path few last days files
find $logpath/ ! -name "*.gz" -ctime +1 -exec gzip {} \; 
echo -----
exit 0
