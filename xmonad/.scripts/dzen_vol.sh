#!/bin/bash
source $(dirname $0)/config.sh
XPOS=3330
WIDTH="15"
LINES="10"

vol=$(echo "$(ossmix vmix0-outvol | awk '{print $10}' | awk -F : '{print $1}')/25 * 100" | bc)
val=()

for i in {1..25..3}; do
	if [ $vol -gt $i ]
	then
		val+=("^bg($white0)^ca(1,ossmix vmix0-outvol $i)      ^ca()")	
	else
		val+=("^bg(#000000)^ca(1,ossmix vmix0-outvol $i)      ^ca()")
	fi
done

(echo "Volume"; echo " +"; echo "${val[7]}"; echo "${val[6]}"; echo "${val[5]}"; echo "${val[4]}"; echo "${val[3]}"; echo "${val[2]}"; echo "${val[1]}"; echo "${val[0]}"; echo " -";sleep 15) | dzen2 -fg $foreground -bg $background -fn $FONT -x $XPOS -y $YPOS -w $WIDTH -l $LINES -e 'onstart=uncollapse,hide;button1=exit;button3=exit'
