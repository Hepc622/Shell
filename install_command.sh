#!/bin/bash
# 获取自定义命令shell脚本到 /usr/local/sh/下
# 给与命令脚本可执行的权限
# 在全局命令里创建一个

# 设置环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

# 脚本存放目录 
script_path="/usr/local/sh"

# 自定义全局命令脚本
script_bin="/etc/profile.d/custom-aliases.sh"

# 判断脚本是否存在,存在就创建
if [[ ! -f ${script_bin} ]]; then
    touch ${script_bin}
    chmod 777 ${script_bin}
fi

# 如果不是为目录的话就创建一个目录
if [[ ! -d ${script_path} ]]; then
    mkdir ${script_path}
fi

scripts=""
# 切入到目录
cd ${script_path}
echo "cd to ${script_path}"
# 判断是会否传了参数
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
            if [[ ${line}=~'command=' ]]; then
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

echo "install custom command ${scripts[@]}"

# 循环获取脚本生成命令
for item in ${scripts[@]}; do
    item=${item##\"}
    item=${item%%\"}
    flag=0
    # 判断文件是否存在，如果存在就备份一下
    if [[ -f "${script_path}/${item}" ]]; then
        flag=1
        # 文件存在就备份一下
        today=`date +%Y%m%d`
        mv "${script_path}/${item}" "${script_path}/${item}.${today}.bak"
    fi
    # 下载脚本
    wget "https://raw.githubusercontent.com/Hepc622/Shell/master/command/${item}"
    # 更改权限
    chmod 777 $item 

    # 如果文件存在就不用去动他了
    if [[ ${flag} -eq 0 ]]; then
        # 软连接存放处
        lns="/usr/bin/$item"
        # 建立软连接到/usr/bin/下面
        ln -s ${script_path}"/${item}" "/usr/bin/${item}"

        echo "create a soft link /usr/bin/"${item}
        # 组拼自定义命令
        command="alias ${item}='${lns}'"

        echo "command is ${item}"
        # 查看命令是否已经存在
        exsit=cat ${script_bin} | grep "'${command}'"
        
        if [[ ! -z ${exsit} ]]; then
            echo "The command already exsit"
        else
            # 写入文件中去
            echo ${command} >> ${script_bin}
        fi
    fi
    
done
# 这里需要只配置文件生效一下
source ${script_bin}
# 退出脚本
exit 0
