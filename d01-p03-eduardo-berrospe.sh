#!/bin/bash

getServices() {
	activeServices=($(sudo service --status-all | grep '\[ + \]'))
	inactiveServices=($(sudo service --status-all | grep '\[ - \]'))

	if [ ${#activeServices[@]} -gt ${#inactiveServices[@]} ]; 
	then
		min=${#inactiveServices[@]}
		max=${#activeServices[@]}
		activeServicesMax=true
	else
		min=${#activeServices[@]}
		max=${#inactiveServices[@]}
		activeServicesMax=false
	fi
	((min=$min))
	((max=$max))
	
	i=0
	id=1
	j=3
	while [ $i -lt $min ];
	do
		row[$((i++))]=$id
		row[$((i++))]=${activeServices[$j]}
		row[$((i++))]=$((id++))
		row[$((i++))]=${inactiveServices[$j]}
		((j=$j+4))
	done 
	
	if [ $activeServicesMax = true ];
	then
		while [ $i -lt $max ];
		do
			row[$((i++))]=$id
			row[$((i++))]=${activeServices[$j]}
			row[$((i++))]=$((id++))
			row[$((i++))]=" "
			((j=$j+4))
		done 
	else
		while [ $i -lt $max ];
		do
			row[$((i++))]=$id
			row[$((i++))]=" "
			row[$((i++))]=$id
			row[$((i++))]=${inactiveServices[$j]}
			((j=$j+4))
		done
	fi
} #getServices

printServices() {
	printf "\e[0;37m[%3s][%-24s]\e[0;0m" ID "     Active service" 
	printf "\e[0;37m[%3s][%-24s]\n\e[0;0m" ID "   Inactive service" 
	((printInstructionFlag=$max/2-20))
	k=0
	while [ $k -lt $max ];
	do
		if [ $k -gt $printInstructionFlag -a $k -lt $((printInstructionFlag+40)) ];
		then
			printf "[%3s][%-24s]" ${row[$((k++))]} ${row[$((k++))]} ##Active services
			printf "\e[0;31m[%3s][%-24s]\e[0;0m" ${row[$((k++))]} ${row[$((k++))]} ##Inactive services
			printf "\e[0;37m\t\t\t%s\n\e[0;0m" "${instruction[$((indexInstruction++))]}"
		else
			printf "[%3s][%-24s]" ${row[$((k++))]} ${row[$((k++))]} ##Active services
			printf "\e[0;31m[%3s][%-24s]\n\e[0;0m" ${row[$((k++))]} ${row[$((k++))]} ##Inactive services
		fi
	done
} ##printServices

actionUser() {
	printf "Input: "
	read inputUser 
	start=$(echo "$inputUser" | egrep -oi 'start [0-9]+')
	stop=$(echo "$inputUser" | egrep -oi 'stop [0-9]+')
	idService=$(echo "$inputUser" | egrep -oi '[0-9]+')
	if [ "$inputUser" = "$start" ];
	then
		idService=$((2+idService+(3*($idService-1))))
		sudo service ${row[$idService]} start
	elif [ "$inputUser" == "$stop" ];
	then
		idService=$((idService+(3*($idService-1))))
		sudo service ${row[$idService]} stop
	elif [ "$inputUser" = "q" ];
	then
		echo "Good bye. (:"
	else
		printf "Type a valid option\n"
		actionUser
	fi
} #actionUser

##main
instruction[0]="To start a service type:"
instruction[1]="start <ID>"
instruction[2]=""
instruction[3]="To stop a service type:"
instruction[4]="stop <ID>"
instruction[5]=""
instruction[6]="To quit: q" 

while [ "$inputUser" != "q" ];
do
	indexInstruction=0
	getServices
	printServices
	actionUser
	sleep 5
done








