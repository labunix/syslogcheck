#!/bin/bash
# Last Update:	2012/12/15
# Author:	labunix@gmail.com
# Depends:	Package Name(Command Name)
#		sharutils(uuencode/uudecode)
#		gzip(gzip)
#		bsd-mailx(mail)

if [ `id -u` -ne "0" ];then
  echo "Sorry,Not Permit User!" >&2
  exit 1
fi

UNIXTIMENOW=`date '+%s'`
CHECKLOG=${UNIXTIMENOW}.log
ATTACHED=`date --date "1 days ago" '+%Y%m%d_syslogcheck.gz'`

# Working Directory
test -d /tmp && cd /tmp

touch ${CHECKLOG}
if [ ! -f ${CHECKLOG} ];then
  echo $?
  exit 1
fi

find /var/log -type f -mtime -1 ! -name "auth.log" -print | \
  grep -i "error\|warn\|crit\|fail" `xargs` | \
  grep -v pcspkr | \
  sed s/": "/"&\n\t"/g > ${CHECKLOG}

if [ -s ${CHECKLOG} ];then
  gzip ${CHECKLOG}
  gzip -t ${CHECKLOG}.gz && rm -f ${CHECKLOG}
  uuencode ${CHECKLOG}.gz ${ATTACHED} | mail -s "Yesterday $0 Report" root@`hostname -f`
fi

unset UNIXTIMENOW
unset CHECKLOG
unset ATTACHED
exit 0

