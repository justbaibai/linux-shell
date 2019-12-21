#!/bin/sh
#####
#Usage:
#shell_log baibai
############
#
# /var/log/baibai.log
#2019-12-17:09-22-39 : baibai : SUCESS 
####
LOG_DATE=$(date "+%Y-%m-%d:%H-%M-%S")
LOG_DIR=/var/log
LOG_NAME=baibai

shell_log(){
LOG_INFO=$1
echo "$LOG_DATE : $LOG_INFO : SUCESS " >>${LOG_DIR}/${LOG_NAME}.log
}

shell_log baibai
