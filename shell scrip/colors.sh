#!/bin/sh

#########
#Usage:
###########################
#source /root/colors.sh
#green hhhhhhhhhddfsdfdls
#red_blink 123123123
#black_red  werwerw:wq


#######
CBEGIN="\033["
CEND="\033[0m"
###color set
GREEN="32m"
RED="31m"
BLUE="34m"
BLACK="30m"
YELLOW="33m"
WHITE="37m"
PURPLE="35m"
###background
B_GREEN="42;"
B_RED="41;"
B_BLUE="44;"
B_BLACK="40;"
B_YELLOW="43;"
B_WHTLE="47;"
B_PURPLE="45;"
####
Blink="5;"
High_Light="1;"
Under_Line="4;"

green(){
word=$1
/bin/echo -e "$CBEGIN$GREEN $word  $CEND"
}

red(){
word=$1
/bin/echo -e "$CBEGIN$RED $word  $CEND"
}


blue(){
word=$1
/bin/echo -e "$CBEGIN$BLUE $word  $CEND"
}


black(){
word=$1
/bin/echo -e "$CBEGIN$BLACK $word  $CEND"
}


yellow(){
word=$1
/bin/echo -e "$CBEGIN$YELLOW $word  $CEND"
}


white(){
word=$1
/bin/echo -e "$CBEGIN$WHITE $word  $CEND"
}


purple(){
word=$1
/bin/echo -e "$CBEGIN$PURPLE $word  $CEND"
}


white_black(){
word=$1
/bin/echo -e "$CBEGIN$B_LACK$WHITE $word  $CEND"
}


black_red(){
word=$1
/bin/echo -e "$CBEGIN$B_RED$BLACK $word  $CEND"
}


red_blink(){
word=$1
/bin/echo -e "$CBEGIN$Blink$RED $word  $CEND"
}


blue_green(){
word=$1
/bin/echo -e "$CBEGIN$B_GREEN$BLUE $word  $CEND"
}

blue_yellow(){
word=$1
/bin/echo -e "$CBEGIN$B_YELLOW$BLUE $word  $CEND"
}

black_blue(){
word=$1
/bin/echo -e "$CBEGIN$B_BLUE$BLACK $word  $CEND"
}

black_purple(){
word=$1
/bin/echo -e "$CBEGIN$B_PURPLE$BLACK $word  $CEND"
}

blue_white(){
word=$1
/bin/echo -e "$CBEGIN$B_WHITE$BLUE $word  $CEND"
}

red_under_line(){
word=$1
/bin/echo -e "$CBEGIN$Under_Line$RED $word  $CEND"
}


