#!/bin/sh
#
# metadata_begin
# recipe: VMmanager-KVM
# tags: centos6,centos7
# revision: 2
# description_ru: Установка VMmanager-KVM
# description_en: VMmanager-KVM installation
# metadata_end
#

set -x

LOG_PIPE=/tmp/log.pipe.$$                                                                                                                                                                                                                    
mkfifo ${LOG_PIPE}
LOG_FILE=/root/vmmgr.log
touch ${LOG_FILE}
chmod 600 ${LOG_FILE}

tee < ${LOG_PIPE} ${LOG_FILE} &

exec > ${LOG_PIPE}
exec 2> ${LOG_PIPE}

killjobs() {
	test -n "$(jobs -p)" && kill $(jobs -p) || :
}
trap killjobs INT TERM EXIT

echo
echo "=== Recipe VMmanager-KVM started at $(date) ==="
echo

if [ -f /etc/redhat-release ]; then
	OSNAME=centos
else
	OSNAME=debian
fi

if [ "#${OSNAME}" = "#centos" ]; then

        if [ ! "($HTTPPROXYv4)" = "()" ]; then
                # Стрипаем пробелы, если они есть
                PR=($HTTPPROXYv4)
                PR=$(echo ${PR} | sed "s/''//g" | sed 's/""//g')
                if [ -n "${PR}" ]; then
                        echo "proxy=${PR}" >> /etc/yum.conf
                fi
        fi

        sed -i"ispbak" -r "s/^(mirrorlist=)/#\1/g; s/^#(baseurl=)/\1/g" /etc/yum.repos.d/*.repo

        echo "Installing VMmanager-KVM"
        cd /root

        curl -o install.sh "http://download.ispsystem.com/install.sh"
        sh install.sh --silent --ignore-hostname --release beta vmmanager-kvm

        for file in /etc/yum.repos.d/*.repoispbak; do mv -f $file $(echo $file|sed 's/ispbak//'); done
        sed -r -i "/proxy=/d" /etc/yum.conf
        echo "Installation finished at $(date)"
else
        wget "http://download.ispsystem.com/install.sh"
        sh install.sh --silent --ignore-hostname --release beta vmmanager-kvm
fi
