#!/bin/sh

# Edit Here
##################################
TimeZone="America/New_York"
ardUser="cscadmin"
proxyURL=""

# System Tools
##################################
ARD='/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart'
ASR='/usr/sbin/asr'
DISKUTIL='/usr/sbin/diskutil'
LAUNCHCTL='/bin/launchctl'
NETWORKSETUP="/usr/sbin/networksetup"
PMSET='/usr/sbin/pmset'
SYSTEMSETUP='/usr/sbin/systemsetup'

wSCUTIL='/usr/sbin/scutil --set'
rSCUTIL='/usr/sbin/scutil --get'

compType=`/usr/sbin/system_profiler SPHardwareDataType | grep 'Model Name:' | awk -F': ' '{print substr($2,1,7)}'`
sNumber=`/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
sHDName=`diskutil info / | grep "Volume Name" | cut -c 30-`
sUUID=`/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -c22-57`

# PList
##################################
rSMBServer='/usr/bin/defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server'
wSMBServer='/usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server'
wLocationd='/usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd'

# Location Services	
##################################
${LAUNCHCTL} unload /System/Library/LaunchDaemons/com.apple.locationd.plist
${wLocationd}.${sUUID} LocationServicesEnabled -int 1
chown -R _locationd:_locationd /var/db/locationd
${LAUNCHCTL} load /System/Library/LaunchDaemons/com.apple.locationd.plist

# HD Name	
##################################
	if [ "${sHDName}" != "Macintosh HD" ] ; then
		${DISKUTIL} renameVolume "${sHDName}" "Macintosh HD"
		exit 1;
	fi

# Hide Recovery HD
##################################
	${DISKUTIL} unmount /dev/disk0s3
	${ASR} adjust --target /dev/disk0s3 --settype Apple_Boot

# System Setup
##################################

# Use this command to specify whether the server restarts automatically after the system freezes.             
	${SYSTEMSETUP} -setrestartfreeze on
	echo ${SYSTEMSETUP} -getrestartfreeze

    ${SYSTEMSETUP} -getallowpowerbuttontosleepcomputer
             Enable or disable whether the power button can sleep the computer.

             Enable or disable whether the power button can sleep the computer.
	
	if [ "${compType}" == "MacBook" ]; then
		${SYSTEMSETUP} -setrestartpowerfailure on
			echo ${SYSTEMSETUP} -getrestartpowerfailure

		${SYSTEMSETUP} -setrestartpowerfailure on
			echo ${SYSTEMSETUP} -getrestartpowerfailure

		${SYSTEMSETUP} -setallowpowerbuttontosleepcomputer on
			echo ${SYSTEMSETUP} -getallowpowerbuttontosleepcomputer
				
	else

	fi




# Networking
##################################
#	-setautoproxyurl networkservice url
#	Set proxy auto-config to url for <networkservice> and enable it.
#	-getautoproxyurl networkservice
#	Displays proxy auto-config (url, enabled) info for <networkservice>.

# Date & Time
##################################
	${SYSTEMSETUP} -settimezone ${TimeZone}
	# set time zone automatically using current location 
		/usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool True

		${SYSTEMSETUP} -setusingnetworktime on 
		${SYSTEMSETUP} -gettimezone
		${SYSTEMSETUP} -getnetworktimeserver

# ARD & SSH
##################################
	${ARD} -activate -configure -access -on -users "${ardUser}" -privs -all  -restart -agent -menu
	${ARD} -configure -allowAccessFor -specifiedUsers	
	${SYSTEMSETUP} -setremotelogin on


# Computer Name
##################################
	if [ "${compType}" == "MacBook" ]; then
		${wSCUTIL} ComputerName "L${sNumber}"
		${wSCUTIL} LocalHostName "L${sNumber}"
		${wSCUTIL} HostName "L${sNumber}"
		${wSMBServer} NetBIOSName "L${sNumber}"		
	else
		${wSCUTIL} ComputerName  "D${sNumber}"
		${wSCUTIL} LocalHostName "D${sNumber}"
		${wSCUTIL} HostName "D${sNumber}"
		${wSMBServer} NetBIOSName "D${sNumber}"
	fi

exit 0
