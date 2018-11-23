#!/bin/bash

# set environment
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# install base development environment
# install iptables
# install java
# install redis
# install tomcat
# install mysql
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
    wget "https://raw.githubusercontent.com/Hepc622/Shell/config/master/config.yml"
    if [[ -f 'config.yml' ]]; then
        # read config file
        cat config.yml | while read line
        do
            # Is contains environment
            if [[ ${line}~='environment' ]]; then
                # deal 
                IFS=':' 
                arr=(${line})
                IFS=","
                scripts=(${arr[1]})
            fi
        done
    else
        echo "get config file faild"
        exit 0
    fi
fi

# Execcut every one script
for script in ${scripts[@]}; do
    # Try to take the script
    wget "https://raw.githubusercontent.com/Hepc622/Shell/master/development/${script}"
    # Check the script exist
    if [[ -f ${script} ]]; then
        # Try to change the script permission
        chmod +x ${script}
        # print the execut script
        echo "start install ${script}"
        # Try to execut the script
        ./${script}
        # Clear the executed script
        rm -rf ${script}
    else
        echo "The ${script} not exsit"        
    fi
done
# exit the script
exit 0