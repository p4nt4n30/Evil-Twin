# scripts

This script will help you set up an evil twin access point.

You must have your DHCP server installed and configured. Also you will need a internet connection so that you can pass your targets request to the web.  

Before running this script run:

airmon-ng check kill

airmon-ng

fing the interface you wan to put into monitor mode. example wlan1

the run:

airmon-ng start wlan1

if your are runing kali 2.0 the first prompt of the script will ask you to enter your monitor mode interface from the above refernce i would enter wlan1mon

if you are runing kali 1.0 then enter mon1.

skip step 0 and proceed to step 1.




