#!/bin/sh

# via cron auf einem linux DSB:
# */1 * * * * /root/bin/dsb-shutdown.sh

URL="http://192.168.100.254/dsb/dsb1/status.txt"
TMPFILE="/tmp/status$$.txt"

wget $URL -o /dev/null -O $TMPFILE
[ ! $? ] && exit

SHUTDOWN=`head -1 $TMPFILE`
rm -f $TMPFILE

if [ "$SHUTDOWN" = "SHUTDOWN=1" ]; then
  logger "$0 powering off..."
  poweroff
fi
