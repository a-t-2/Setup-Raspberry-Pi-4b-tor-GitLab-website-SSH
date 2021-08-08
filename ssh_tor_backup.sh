#!/bin/bash
# Sets up SSH over tor and helps you copy the onion address 
# at which you can ssh into this RPI to your host device/pc. 

get_last_n_lines() {
	number=$1
	abs_path=$2
	
	# get last number lines of file
	last_number_of_lines=$(sudo tail -n $number /etc/tor/torrc)
	
	# Output true or false to pass the equality test result to parent function
	echo $last_number_of_lines
}

get_last_n_line() {
	number=$1
	abs_path=$2
	
	# get last number lines of file
	last_number_of_lines=$(sudo tail -n $number /etc/tor/torrc)
	
	# get first line of last number of lines of file
	last_number_line=$(echo $last_two_lines | sudo head -n 1)
	
	# Output true or false to pass the equality test result to parent function
	echo $last_number_line
}

# Set up robust ssh
# Append hiddenservice for ssh to torrc file
# TODO: check if line already exists
yes | sudo apt install net-tools
yes | sudo apt install tor

echo -e "\n\nPlease wait a minute while we set up ssh access over tor for you, you will be asked how to proceed when we're done."

# append ssh service to torrc
last_two_lines=$(sudo tail -n 2 /etc/tor/torrc)
second_last_line=$(echo $last_two_lines | sudo head -n 1)
last_line=$(sudo tail -n 1 /etc/tor/torrc)
if [ "$second_last_line" != "HiddenServiceDir /var/lib/tor/other_hidden_service/" ]; then
	if [ "$last_line" != "HiddenServicePort 22" ]; then
		echo 'HiddenServiceDir /var/lib/tor/other_hidden_service/' | sudo tee -a /etc/tor/torrc
		echo 'HiddenServicePort 22' | sudo tee -a /etc/tor/torrc
	fi
fi

# append ssh service to /etc/ssh/sshd_config
last_two_lines=$(sudo tail -n 2 /etc/ssh/sshd_config)
second_last_line=$(echo $last_two_lines | sudo head -n 1)
last_line=$(sudo tail -n 1 /etc/ssh/sshd_config)
if [ "$second_last_line" != "Port 22" ]; then
	if [ "$last_line" != "Port 23" ]; then
		echo 'Port 22' | sudo tee -a /etc/ssh/sshd_config
		echo 'Port 23' | sudo tee -a /etc/ssh/sshd_config
		service sshd restart
	fi
fi

# Verify tor application is started
delay_counter=0
while [ "${grepped_activated_tor:0:3}" != "tcp" ]; do
	# start tor service
	sudo systemctl restart tor
	sudo killall tor
	nohup sudo tor &
	# TODO: read nohup.txt to determine when 100% is in file, indicating tor is bootstrapped
	# TODO: remove the hardcoded 5 second pause
	
	netstat_response=$(netstat -ano)
	grep_listen=$(echo "$netstat_response" | grep LISTEN)
	grepped_activated_tor=$(echo "$netstat_response" | grep 9050)
	#echo "grepped_activated_tor=$grepped_activated_tor" >&2
	
	((delay_counter=delay_counter+1))
	sleep $delay_counter
done

# verify tor connection is established
while [ "$grepped" != "Congratulations." ]; do
	response=$(curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/)
	grepped=$(echo "$response" | tr ' ' '\n' | grep -m 1 Congratulations)
	#echo "grepped=$grepped"
	sleep 10
done

# Ask if user wants to display address to copy it manually, or physically or using non-tor ssh
echo -e "\nNice, you have set up tor connections successfully. Now you can ssh into/control this SUB-device from another CONTROLLER-device anywhere in the world, though its onion address. "
echo "IMPORTANT: this address is like your password, keep it SECRET. "
echo -e "To get it, you have the following options:\n"
echo -e " - (0) Print the onion address to screen now, and manually type it over in your other CONTROLLER-device.\n"
echo " - (1) Copy the file with the onion address to a USB drive that you plugged into this SUB-device. To do this you can use the following commands, assuming you mounted the USB drive with:sudo mount /dev/sda1 /media"
echo "            sudo cp /var/lib/tor/other_hidden_service/hostname /media/hostname.txt"
echo "            sudo umount /dev/sda1"
echo "then unplug your USB drive."
echo -e "Next, put the USB drive in the CONTROLLER-device,  and read/copy the onion address that is in the file hostname.txt in the USB drive.\n"
echo " - (2) You can also get the onion domain  directly SSH into this SUB-device from another CONTROLLER-device if they are on the same network. To do that, open a terminal on your other device and type:"
echo "            ssh $(whoami)@$(echo $(hostname -I) | cut -f1 -d' ')"
echo "or, if that does not work, try:"
echo "            ssh $(whoami)@$(echo $(hostname -I) | cut -d' ' -f2-)"
echo "when prompted for login, type y and/or Enter the password of the Ubuntu account of this SUB-device to login."
echo "After logging in, type (in the ssh terminal of your CONTROLLER-device (that is actually accessing your SUB-device)):"
echo "            sudo cp /var/lib/tor/other_hidden_service/hostname /media/hostname.txt"
echo -e "then copy that <someonionaddress.onion> address.\n"


while true; do
	read -p "Do you want to do option 0(y/n) (watch out for shoulder peeking)?" yn
	case $yn in
	[Yy]* ) 
		sudo cat /var/lib/tor/other_hidden_service/hostname;
		break;;
	[Nn]* ) 
			echo "Ok, you can use option 1 or 2  yourself to get the ssh onion address of this device."; 
			break;;
	* ) echo "Please answer yes or no.";;
	esac
done

while true; do
	read -p "Do you have the onion address of this device(y/n)?" yn
	case $yn in
	[Yy]* ) 
		echo "excellent, to safely and anonymously control this SUB-device from from wherever OVER PORT 23, use the following commands on a MAIN-device:"
		echo "            sudo apt install tor"
		echo "            sudo apt install torify"
		echo "            sudo systemctl restart tor"
		echo "            sudo tor"
		echo "            torify ssh $(whoami)@<your_onion_domain>.onion -p 23"
		break;;
	[Nn]* ) 
		echo "You can use option 1 or 2  yourself to get the ssh onion address of this device.  Please do that.";
		#break;;
		;;
	* ) echo "Please answer yes or no.";;
	esac
done

# IF YOU WANT SSH OVER PORT 23 instead of 22:
# Change gitlab, torrc, and this code.
# Source: https://askubuntu.com/questions/264046/how-to-ssh-on-a-port-other-than-22
# change /etc/ssh/sshd_config line:"#Port 22" to:"Port 23"
# service sshd restart