#!/bin/bash

# set environment
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# install base development environment
# install tomcat
# install vsftpd
# install mycat
# install zookeeper
# install rabbit

scripts=""
# Deal the parameter
# If the parameter length is 0,execut the all script 
if [[ "${#}" -gt 0 ]]; then
    index=0
    for i in "${@}"; do
        scripts[${index}]=${i}
        index=${index}+1
    done
else
    wget "https://raw.githubusercontent.com/Hepc622/Shell/master/config/config.cf"
    if [[ -f 'config.cf' ]]; then
        # read config file
        for line in $(cat config.cf)
        do
            # Is contains environment
            if [[ -n $(echo ${line}|grep '^environment=') ]]; then
                OLD_IFS=${IFS}
                # deal 
                IFS='=' 
                arr=(${line})
                IFS=","
                scripts=(${arr[1]})
                IFS=${OLD_IFS}
            fi
        done
    else
        echo "get config file faild"
        exit 0
    fi
    # clear config.cf file
    rm -f config.cf
fi

# Execcut every one script
for script in ${scripts[@]}; do
    script=${script##\"}
    script=${script%%\"}

    # Try to take the script
    wget "https://raw.githubusercontent.com/Hepc622/Shell/master/development/${script}"
    # Check the script exist
    if [[ -f ${script} ]]; then
        # Try to change the script permission
        chmod +x ${script}
        # print the execut script
        echo "start install ${script}"
        # Try to execut the script
        ./${script} install
        # Clear the executed script
        rm -rf ${script}
    else
        echo "The ${script} not exsit"        
    fi
done
# exit the script
exit 0
