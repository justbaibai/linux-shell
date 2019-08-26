#!/bin/bash


usage(){

	echo "Usage: $0 [start|stop]"
}

start_tomcat(){

/usr/local/tomcat/bin/startup.sh

}

stop_tomcat(){

TPID=$(ps -ef|grep java|grep -v 'grep'|awk '{print $2}')

kill -9 $TPID
sleep 5;

TSTAT=$(ps -ef|grep java|grep -v 'grep'|awk '{print $2}')
	if [ -z $TSTAT ];then
	  echo "tomcat stop"
	else
	  kill -9 $TSTAT
	fi

}


main(){

case $1 in
	start)
	  start_tomcat;;
	stop)
	  stop_tomcat;;
	*)
	  usage;
esac
}
main $1;
