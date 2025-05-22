#!/bin/bash
######################################################
me=`basename "$0"`;
me_zero_ext=$(echo $me | sed "s/\..*//")
printerr() {
        printf "\n\033[5;41mERROR\033[1;0m $1 \033[m\n" "$2"
}
function check_root() {
        if [ "$(id -u)" != "0" ]; then
                printf "\033[1;91m>>>>> This script must be run as root. bye! \033[m\n"; exit 1
        fi
}
show_menu() {
        printf "\033[1;32;100m------------------ CISCO config file generator -------------------\033[m\n"
        printf "\033[1;0musage: \033[1;32m$me \033[1;37mmodel extension password MAC asterisk_IP\033[m\n"
        printf "\033[1;37mmodel\033[1;0m - now supporting only \033[1;32mCP-8841\033[1;0m or \033[1;32mCP-7821\033[1;0m.\033[m\n"
        printf "\033[1;37mextension\033[1;0m - can be \033[1;32m3\033[1;0m or \033[1;32m4\033[1;0m digits.\033[m\n"
	printf "\033[1;370mMAC\033[1;0m must contains colons ->\033[1;32m :\033[m\n"
        printf "\033[1;0mTo run, the script must have \033[1;37mFIVE\033[1;0m arguments!\033[m\n"
}
valid_ipv4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || { return 1; }
    for i in ${ip//./ }; do
        [[ "${#i}" -gt 1 && "${i:0:1}" == 0 ]] && { return 1; }
        [[ "$i" -gt 255 ]] && { return 1; }
    done
#    echo 'IP address is valid'
}
##################### main #################################
case $# in
	1)
		case $1 in 
			"-h")
				show_menu
				exit
				;;
			*"help"*)
				show_menu
				exit
				;;
			*)
				printerr "This script needs a lot of arguments to run with"
				echo "Use --help(-h) for details"
				exit
				;;
		esac
		;;
	[2-4])
		printerr "This script needs a lot of arguments to run with"
		echo "Use --help(-h) for details"
		exit
		;;
	5)
		case $1 in
			"8841")
				model=$1
				src_file="source8841.cnf.xml"
				;;
			"7821")
				model=$1
				src_file="source7821.cnf.xml"
				;;
			*)
				printerr "Unknown phone model"
				exit
				;;
		esac

		;;
	*)
		printerr "This script needs a lot of arguments to run with"
		echo "Use --help(-h) for details"
		exit
		;;
esac

check_root
if [[ $2 =~ ^[0-9]+$ ]]; then
	digs='^[[:digit:]]{3,4}$'
	if [[ "$2" =~ $digs ]]; then
		extension=$2
	else
		printerr "phone number must be 3 to 4 digits in length"
		exit
	fi
else
	printerr "Wrong extension number"
	exit
fi
password=$3
src_MAC=`echo $4 | tr a-z A-Z`
#TODO check MAC for colons
case $src_MAC in 
	[0-9A-F][0-9A-F]:[0-9A-Z][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F]:[0-9A-F][0-9A-F])
#		echo "Valid MAC"
		colons_MAC=$src_MAC
  		;;
	*) 
                printerr "Wrong MAC number"
                exit
  		;;
esac
MAC=`echo $colons_MAC | sed s/://g`
if ! valid_ipv4 $5 ; then
	printerr "Wrong IP address"
	exit
else
	server=$5
fi

printf "\033[1;37m>>>>> featureLabel \033[1;0mand \033[1;37mphoneLabel\033[1;0m properties are not set\033[m\n"
read -rp "      shall we do it?(y/n) " -n 1
echo   
while true; do
case $REPLY in
	[Yy])
		printf "\033[1;0m>>>>> pls enter a \033[1;37mfeatureLabel\033[m\n"
		read featureLabel
		if [[ $featureLabel == "" ]]; then 
			printf "\033[1;33m>>>>> setting to default <<NOIS>>   \033[m\n"
			featureLabel="NOIS"
		fi
		printf "\033[1;0m>>>>> pls enter a \033[1;37mphoneLabel\033[m\n"
		read phoneLabel
		if [[ $phoneLabel == "" ]]; then 
			printf "\033[1;33m>>>>> setting to empty   \033[m\n"
			phoneLabel=""
		fi
		break
		;;
	[Nn])
		printf "\033[1;33m>>>>> setting featureLabel to default <<NOIS>>   \033[m\n"
		featureLabel="NOIS"
		printf "\033[1;33m>>>>> setting phoneLabel to empty   \033[m\n"
		phoneLabel=""
		break
		;;
	*)
		if [[ $REPLY =~ ^[^A-Za-z]*$ ]]; then
			printf "\n\033[1;33m>>>>> switch keyboard layout to Eng!  \033[m\n"
		else
			printerr "Wrong answer"
		fi
		read -rp "pls enter your choice again(y/n) " -n 1
		;;
esac
done


echo "model is: "$model
echo "extension is: "$extension
echo "password is: "$password
echo "MAC address is: "$MAC
echo "asterisk address is: "$server
echo "featureLabel is: "$featureLabel
echo "phoneLabel is: "$phoneLabel

path=/tftp
#path=.

cp ./$src_file $path/SEP$MAC.cnf.xml

sed -i -e "s/#extension/$extension/g" $path/SEP$MAC.cnf.xml
sed -i -e "s/#password/$password/g" $path/SEP$MAC.cnf.xml
sed -i -e "s/#server/$server/g" $path/SEP$MAC.cnf.xml
sed -i -e "s/#featureLabel/$featureLabel/g" $path/SEP$MAC.cnf.xml
sed -i -e "s/#phoneLabel/$phoneLabel/g" $path/SEP$MAC.cnf.xml

touch $path/ITLSEP$MAC.tlv
touch $path/CTLSEP$MAC.tlv

chown -R tftp:tftp $path/
