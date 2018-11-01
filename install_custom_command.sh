#!/bin/bash
# 获取自定义命令shell脚本到 /usr/local/sh/下
# 给与命令脚本可执行的权限
# 在全局命令里创建一个

# 设置环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi

#安装wget命令
if [[ ${OS} == Ubuntu ]];then
  apt-get update  
  apt-get install wget  
fi
if [[ ${OS} == CentOS ]];then
  yum install wget -y
fi
if [[ ${OS} == Debian ]];then
  apt-get update
  apt-get install wget  
fi

# 脚本存放目录 
script_path="/usr/local/sh"

# 自定义全局命令脚本
script_bin="/etc/profile.d/custom-aliases.sh"

# 判断脚本是否存在,存在就创建
if [[ ! -f "$scrpt_bin" ]]; then
    touch $script_bin
fi

# 如果不是为目录的话就创建一个目录
if [[ ! -d "$script_path" ]]; then
    mkdir $script_path
fi

scprits=""
# 切入到目录
cd $script_path
# 判断是会否传了参数
if [[ "$#" -gt 0 ]]; then
    index=0
    for i in "$@"; do
        $scprits[$index]=$i
        $index=$index+1
    done
else
    $scprits=("runjar","rpm_rempve")
fi

# 循环获取脚本生成命令
for item in "$scprits"; do
    # 下载脚本
    wget "https://raw.githubusercontent.com/Hepc622/Shell/master/$item"
    # 更改权限
    chmod 777 $item 
    # 软连接存放处
    lns="/usr/bin/$item"
    # 建立软连接到/usr/bin/下面
    ln -s $script_path"/$item" "/usr/bin/$item"
    # 组拼自定义命令
    command="alias=$lns"
    # 写入文件中去
    echo $command >> $script_bin
done
# 这里需要只配置文件生效一下
source /etc/profile.d
# 退出脚本
exit 0