#!/bin/bash
##	0		1		2		3		4
## name     IP     login  logout   time-login

getActiveUsers() {
	local w=($(who))
	activeUsersLength=${#w[*]}
	local i=0
	local j=0
	while [ $i -lt $activeUsersLength ]; 
	do
		activeUsers[$j]=${w[$i]}	##Name
		((i=$i + 4))
		((j++))
		activeUsers[$j]=${w[$i]}	##IP
		((i--))
		((j++))
		activeUsers[$j]=${w[$((i-1))]}" "${w[$i]}	##LOGIN
		login=${w[$((i-1))]}" "${w[$i]}	##LOGIN
		((i=$i+2))
		((j++))
		activeUsers[$j]="-"
		((j++))
		getConnectionTime 
		activeUsers[$j]=$connectionTime  ##ConnectionTime
		((j++))
	done
} #getActiveUsers

checkForPreviousUsers(){
	local i=0
	local j=0
	local isPreviousUser=true
	while [ $i -lt $previousUsersLength ]; 
	do
		isPreviousUser=true
		while [ $j -lt $activeUsersLength ];
		do
			if [ ${previousUsers[$i]} = ${activeUsers[$j]} ];
			then
				isPreviousUser=false
				break
			fi
			((j=$j+5))	
		done
		if [ $isPreviousUser = true ];
		then
			allUsers[$allUsersLength]=${previousUsers[$i]}	##setName
            ((i++))
            ((allUsersLength++))
            allUsers[$allUsersLength]=${previousUsers[$i]} ##setIP
            ((i++))
            ((allUsersLength++))
            allUsers[$allUsersLength]=${previousUsers[$i]} ##setLogin
            ((i++))
            ((allUsersLength++))
            
            if [ ${previousUsers[$i]} = - ];
            then
				allUsers[$allUsersLength]=$(date +"%R")
            else 
				allUsers[$allUsersLength]=${previousUsers[$i]}
            fi
            
            ((i++))
            ((allUsersLength++))
            allUsers[$allUsersLength]=${previousUsers[$i]}
            ((i++))
            ((allUsersLength++))
            j=0
        else
			((i=$i+5))
			j=0
		fi
	done 
} #checkForPreviousUser

getConnectionTime() {
	currentTime=$(date +"%s")
	login=$(date --date="$login" +"%s")
	((deltaTime=($currentTime - $login)))
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
	
	connectionTime=$day", "$hour":"$minute":"$deltaTime
} #getConnectionTime

bubbleSort() {
	local i=8
	local j=2
	local temp=0
	while [ $i -lt $((allUsersLength+3)) ];
	do
		while [ $j -lt $((allUsersLength+3-i)) ];
		do
			if [ $(date --date="${allUsers[$j]}" +"%s") -gt $(date --date="${allUsers[$((j+5))]}" +"%s") ];
			then
				temp=${allUsers[$((j-2))]}
				allUsers[$((j-2))]=${allUsers[$((j+3))]}
				allUsers[$((j+3))]=$temp
				
				temp=${allUsers[$((j-1))]}
				allUsers[$((j-1))]=${allUsers[$((j+4))]}
				allUsers[$((j+4))]=$temp
				
				temp=${allUsers[$j]}
				allUsers[$j]=${allUsers[$((j+5))]}
				allUsers[$((j+5))]=$temp
				
				temp=${allUsers[$((j+1))]}
				allUsers[$((j+1))]=${allUsers[$((j+6))]}
				allUsers[$((j+6))]=$temp
				
				temp=${allUsers[$((j+2))]}
				allUsers[$((j+2))]=${allUsers[$((j+7))]}
				allUsers[$((j+7))]=$temp
			fi
			((j=$j+5))
		done
		j=2
		((i=$i+5))
	done 
} #bubbleSort()

usersToString(){
	local i=0
	printf "+%-10s+%-21s+%-5s+%-6s+%-15s+\n" "----------" "---------------------" "-----" "------" "---------------"
	printf "|%-10s|%-21s|%-5s|%-6s|%-15s|\n" "Username" "         IP" "Login" "Logout" "Connection time"
	printf "+%-10s+%-21s+%-5s+%-6s+%-15s+\n" "----------" "---------------------" "-----" "------" "---------------"
	while [ $i -lt $allUsersLength ];
	do
		printf "|\e[0;3%dm%-10s\e[0;0m" $((($i % 6) + 1)) "${allUsers[$i]}"
		printf "|\e[0;3%dm%-21s\e[0;0m" $((($i % 6) + 1)) "${allUsers[$((i+1))]}"
		printf "|\e[0;3%dm%-5s\e[0;0m" $((($i % 6) + 1)) "${allUsers[$((i+2))]#* }"
		printf "|\e[0;3%dm%-6s\e[0;0m" $((($i % 6) + 1)) " ${allUsers[$((i+3))]}"
		printf "|\e[0;3%dm%-15s\e[0;0m|\n" $((($i % 6) + 1)) " ${allUsers[$((i+4))]}"
		
		((i=$i+5))
	done
	printf "+%-10s-%-21s-%-5s-%-6s-%-15s+\n" "----------" "---------------------" "-----" "------" "---------------"
} #activeUsersToString

## main
activeUsers=0
activeUsersLength=0
previousUsers=0
previousUsersLength=0
allUsers=0
allUsersLength=0


while true
do
	getActiveUsers
	
	i=0
	while [ $i -lt $activeUsersLength ]; 
	do
		allUsers[$i]=${activeUsers[$i]}
		((i++))
	done
	allUsersLength=$activeUsersLength
	
	checkForPreviousUsers
	
	bubbleSort
	
	usersToString 
	
	i=0
	while [ $i -lt $allUsersLength ]; 
	do
		previousUsers[$i]=${allUsers[$i]}
		((i++))
	done
	previousUsersLength=$allUsersLength
	sleep 2
	clear
done
