#!/bin/bash

fileToArray() {	##Parameter file.txt
	local i=0
	while IFS= read -r -n1 c
	do
		if [ "$c" == "S" ];
		then
			map[$i]="¥"
			pos=$i
		else
			map[$i]="$c"
		fi
		((i++))
	done < "$1"
} ##fileToArray

move() {
	read -rsn1 -t 1 key
	case "$key" in
	$'\x1b')
		read -rsn1 -t 0.01 tmp
		if [[ "$tmp" == "[" ]]; then
			read -rsn1 -t 0.01 tmp
			case "$tmp" in
				"A")
					((nextPos=$pos-$moveUpDown))
					if [ $nextPos -ge 0 ]; then
						validMove $nextPos
					fi
					;; #UP 	
					
				"B") 
					((nextPos=$pos+$moveUpDown))
					if [ $nextPos -le $mapLength ]; then
						validMove $nextPos
					fi
					;; #DOWN 	
					
				"C")
					((nextPos=$pos+1))
					if [ $(( $((nextPos+1)) % $ln )) != 0 ]; then
						validMove $(($pos+1))
					fi
					;; #RIGHT
					
				"D")
					if [ $(( $pos  % $ln )) != 0 ]; then
					 	validMove $(($pos-1))
					fi
					;; #LEFT 
			esac
		fi
		read -rsn5 -t 0.01 key
		;;
	esac
} ##move

validMove() { ##Parameter nextPosition
	if [ "${map[$1]}" != "X" ]; then
		if [ "${map[$1]}" != "O" ]; then
			map[$pos]=" "
			pos=$1
			map[$pos]="¥"
			display
		else
			clear 
			figlet -c "You Win!"
			figlet -c "Time:"
			figlet -c "$time"
			gameFinish="true"
		fi	
		printf "\a"
	fi
} ##validMove

display() {
	clear
	stopwatch
	local i=0
	while [ $i -lt $mapLength ];
	do
		if [ $(($i % $ln)) = 0 ]; then
			printf "\n"
			if [ "${map[$i]}" = "X" ]; then
				printf "\e[0;33m%s\e[0;0m" "${map[$i]}"
			else 
				printf "%s" "${map[$i]}"
			fi
		elif [ "${map[$i]}" = "X" ]; then
			printf "\e[0;33m%s\e[0;0m" "${map[$i]}"
		else
			printf "%s" "${map[$i]}"
		fi
		((i++))
	done
	echo ""
} ##display

stopwatch() {
	currentTime=$(date +"%s")
	((deltaTime=($currentTime - $startTime)))
	((day=($deltaTime / 86400)))
	((deltaTime=$deltaTime - ($day * 86400)))
	if [ $day -lt 10 ];
	then
		day="0"$day
	fi
	((hour=($deltaTime / 3600)))
	((deltaTime=$deltaTime - ($hour * 3600)))
	if [ $hour -lt 10 ];
	then
		hour="0"$hour
	fi
	((minute=($deltaTime / 60)))
	((deltaTime=$deltaTime - ($minute * 60)))
	if [ $minute -lt 10 ];
	then
		minute="0"$minute
	fi
	if [ $deltaTime -lt 10 ];
	then
		deltaTime="0"$deltaTime
	fi
	time="$day, $hour:$minute:$deltaTime"
	echo -e "\t\t\t\t\t$time\n"
} ##stopwatch

createMap() {
	echo "Set file name (JPG ONLY)"
	read jpgFile
	#echo "Set the file name of the generated map (.txt)"
	#read map
	jp2a --chars="XXXXXXXX " -f $jpgFile
} ##createMap

menu() {
	until [ "$c" = "q" ];
	do
		echo "[1] Start game"
		echo "[2] Set a new map"
		#echo "[3] Create a new map (JPG to ASCII)"
		echo "[q] Quit"
		echo "Option:"
		read -sn1 c
		case "$c" in
			"1")
				gameFinish="false"
				fileToArray $fileMap
				startTime=$(date +"%s")
				display
				until [ "$gameFinish" = "true" ];
				do
					move
				done 
				;;
				
			"2")
				echo "Maps.."
				ls
				echo ""
				echo "Type: nameMap.txt"
				read fileMap
				cat $fileMap
				pos=0		##Initialize position
				maxLineLength=$(wc -L $fileMap | egrep -o [0-9]+)
				mapLength=$(wc -c $fileMap | egrep -o [0-9]+)
				ln=$(($maxLineLength+1))
				moveUpDown=$((maxLineLength+1))
				;;
				
			"3")
				#createMap
				;;
		esac
	done
} ##menu


main() {
	cd maps
	fileMap=defaultMap.txt
	pos=0		##Initialize position
	maxLineLength=$(wc -L $fileMap | egrep -o [0-9]+)
	mapLength=$(wc -c $fileMap | egrep -o [0-9]+)
	ln=$(($maxLineLength+1))
	moveUpDown=$((maxLineLength+1))
	clear
	menu
	
} ##main

main
