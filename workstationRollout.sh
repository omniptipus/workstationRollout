#!/bin/bash

########################################################################
########################################################################
########################################################################

###############################
#                             #
#    workstationRollout.sh    #
#                             #
###############################

#Version: 1.0.0
#Written by: Trevor Sysock
#Initially Created: 2021-09-22
#Modified on: 2021-11-19

########################################################################
########################################################################
########################################################################

##Purpose of this script:
##Setup a new mac for my purposes
##


#----------------------------
exit_script_helper ()
#----------------------------
{

#This is a function, showing information about the script and how to run it.

echo "
Syntax: 
./workstationRollout.sh -s -a -u
./workstationRollout.sh -sau

s= Set system settings
a= Install applications via HomeBrew
u= Set user settings for the user account running the script

***DO NOT RUN THIS SCRIPT AS ROOT***
If you choose System Settings or Application Install, you must have sudo rights.
If you use sudo, this script will exit with an error.

"
exit 99

}


##Additional features hopefully added in a future version
##
##


########################################################################
########################################################################
########################################################################

#######################################
#                                     #
#          USER CONFIGURATION         #
#                                     #
#######################################

# enable global debugging of script
## set to "on" to echo additional comments to screen
## set to "off" or simply comment out for production

ECHO_DEBUG=on


##List of apps to install view Brew. Any app or formula with a # preceding it will be skipped.
##To find additional applications, from a computer with Homebrew installed use the following:
##brew search --cask string
##This will list any brew formulae which contain the word "string"
##For more info on a formula, use:
##brew info --cask string

BREWCASKS=(
    
    ##Browsers
    firefox
    google-chrome
    brave-browser
    
    ##Utility Apps
    easyfind
    cyberduck
    vlc
    omnidisksweeper
    the-unarchiver
    angry-ip-scanner
    alfred
    coconutbattery
    fluid
    suspicious-package
    pppc-utility
    geektool
    
    ##Security
    authy
    1password
    
    ##Communications Apps
    skype
    zoom
    microsoft-teams
    
    ##Productivity
    adobe-acrobat-reader
    microsoft-office
    audacity
    busycal
    busycontacts
    
    ##Testing Only
    failure-canary-asdfjkl #Invalid app install - Include this for testing failure notifications in the script.
    
)

GATEKEEPER_BYPASS=(

#This will add an extended attribute to any .app listed (full path required) so users don't get Gatekeeper prompted on that app.
#Be sure to escape spaces
#The function which calls this checks if the .app exists, so there's no harm in extra entries here.

	/Applications/Cyberduck.app
	/Applications/Firefox.app
	/Applications/Google\ Chrome.app
	/Applications/Cyberduck.app
	/Applications/EasyFind.app
	/Applications/BBEdit.app
	/Applications/VLC.app
	/Applications/FileZilla.app
	/Applications/Cocktail.app
	/Applications/OmniDiskSweeper.app
	/Applications/The\ Unarchiver.app
	/Applications/Slack.app
	/Applications/CrashPlan.app
	/Applications/Skype.app
	/Applications/Adobe\ Acrobat\ Reader\ DC.app
	
	
)



DOCK_APPS=(

/System/Applications/Safari.app
/Applications/Google\ Chrome.app
/Applications/Firefox.app
/System/Applications/Mail.app
/System/Applications/Calendar.app
/Applications/Microsoft\ Outlook.app
/Applications/Microsoft\ Word.app
/Applications/Microsoft\ Excel.app
/System/Applications/System\ Preferences.app
/System/Applications/Utilities/Terminal.app
/System/Applications/Utilities/Console.app
/System/Applications/Utilities/Disk\ Utility.app
/System/Library/CoreServices/Applications/Screen\ Sharing.app
/Applications/EasyFind.app
)


#######################################
#                                     #
#       END OF USER CONFIGURATION     #
#                                     #
#######################################


##Syntax conventions in effect:
# i am a comment i.e. comments are prefixed wih a number sign (#) and \
#will not print/run
#I_AM_A_VARIABLE = multi word variables are all caps with underscores
#function_i_am_a_function = function names are prefixed with the word \
#"function" and are all lowercase with underscores
#i-am-a-filename.txt = filenames are all lowercase and dashed

###########################
# Define Common Functions #
###########################

#----------------------------
ECHO_DEBUG ()
#----------------------------
{

# goal of function:
# this function checks for errors to aid in debugging
# will echo passed parameters only if ECHO_DEBUG is set to "on" in header of script
# yes, ECHO_DEBUG breaks our syntax conventions in favor of readability when debugging.
[ "$ECHO_DEBUG" = "on" ] &&  $@

}  # end of function ECHO_DEBUG

ECHO_DEBUG echo "DEBUG: PID equals $$"





###########################
# Define Common Variables #
###########################

#Date Variables
DATE_NOW=$(TZ=America/Los_Angeles date +"%Y-%m-%d_%T")
DATE_DAY=$(TZ=America/Los_Angeles date +"%Y-%m-%d")


#Script Name Variable
SCRIPT_NAME=$(basename $0)
PID=$$

####################
# Script Functions #
####################


#----------------------------
function_blah ()
#----------------------------
{
#I am a function. Put things here
#Remember to add syntax clues

echo "function_blah"

}

#----------------------------
function_date_now ()
#----------------------------
{
#Set the "Now" date

DATE_NOW=$(TZ=America/Los_Angeles date +"%Y-%m-%d_%T")

}

#----------------------------
function_date_day ()
#----------------------------
{

#Date Variables
DATE_DAY=$(TZ=America/Los_Angeles date +"%Y-%m-%d")

}


#----------------------------
function_title ()
#----------------------------
{
#Banner title

echo ""
echo "**   "$1"   **"
echo ""

}

#----------------------------
function_fail ()
#----------------------------

{
echo "

FAILURE CONDITION DETECTED
                                                           
"
}

#----------------------------
function_success ()
#----------------------------

{

echo "

SUCCESS

"

}

####################
# Script Variables #
####################


#Error Codes
E_IS_ROOT="98"
E_NOT_ROOT="97"
NO_DISK_ACCESS="96"
BREW_INSTALL_FAILED="95"
BREW_UPDATE_FAILED="94"

##Process arguments from command line

SET_SYSTEM_SETTINGS=0
INSTALL_APPLICATIONS=0
SET_USER_SETTINGS=0

while getopts "sau?h" ARGS ; do
	case "${ARGS}" in
		s) SET_SYSTEM_SETTINGS=1 ;;
		a) INSTALL_APPLICATIONS=1 ;;
		u) SET_USER_SETTINGS=1 ;;
		h|?) exit_script_helper ;;
	esac
done

	
ECHO_DEBUG echo "SET_SYSTEM_SETTINGS has value $SET_SYSTEM_SETTINGS"
ECHO_DEBUG echo "INSTALL_APPLICATIONS has value $INSTALL_APPLICATIONS"
ECHO_DEBUG echo "SET_USER_SETTINGS has value $SET_USER_SETTINGS"




##########################
#   SCRIPT BEGINS HERE   #
##########################
ECHO_DEBUG echo "DEBUG: Script begins here... "

function_title "Testing for Terminal.app Full Disk Access"

touch ~/Library/Mail/__rolloutTest.txt > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Terminal has disk access. Moving on."
	rm ~/Library/Mail/__rolloutTest.txt
else
	function_fail
	echo "Terminal does not have full disk access."
	echo "You must grant Terminal full disk access in Sys Preferences, Security and Privacy, Privacy pane"
	echo ""
	#Open Sys Prefs to pane 
	function_title "Opening Sys Prefs for you and exiting."
	open /System/Library/PreferencePanes/Security.prefPane
	open /Applications/Utilities
	exit $NO_DISK_ACCESS
fi




#Check if this script has been tested on the current major OS version
SUPPORTED_OS="12"


MACOS_MAJOR_VERSION=$(sw_vers -productVersion | cut -d '.' -f 1)

echo "This script is tested and supported on macOS "$SUPPORTED_OS". This computer is running macOS "$MACOS_MAJOR_VERSION"."

if [[ $MACOS_MAJOR_VERSION == *"$SUPPORTED_OS"* ]]; then 
	echo "Operating system is supported. Moving on."
else
	echo "Operating system is NOT SUPPORTED."
	echo "You may still run this script, however there may be untested features or unexpected errors."
	echo -n "Do you want to run this script regardless of the OS mismatch? [yes or no]: "
		read yno
			case $yno in

        	[yY] | [yY][Ee][Ss] )
                echo "Continuing to run script on unsupported operating system."
                ;;

        	[nN] | [n|N][O|o] )
                echo "User chose to exit the script. No changes have been made.";
                exit 1
                ;;
        	*) echo "Invalid input. Please answer yes or no. Exiting"
        		exit 1
           		 ;;
			esac

fi

#Check if script was executed as root. If yes, exit the script with instructions.
if [ "$(id -u)" = "0" ]; then
	echo "This script CANNOT be run as root. Try again without sudo."
	exit $E_IS_ROOT
fi

#Test if we have any valid input
ECHO_DEBUG echo "OPTIND has value "$OPTIND""


if [ $OPTIND = 1 ] ; then
	function_title "No arguments given."
	exit_script_helper
fi

#If user chose System Settings or Applications, check for sudo rights

function_title "Checking for Root Privileges"
echo "If you choose option -s or -a you must be an administrator on this machine."
sudo whoami > /dev/null

if [ $? = 1 ]; then
	echo "You don't have sudo/root privileges. You can only choose -s or -a option if you have sudo privileges."
	exit $E_NOT_ROOT
fi	



#Verify options user has chosen, and prompt for confirmation.
function_title "Verifying Options"
echo""
echo""

echo "You have chosen to set the following options: "

if [ "$SET_SYSTEM_SETTINGS" = 1 ];  then  echo "**System settings (computer/disk/localhost name, etc.)"; fi
if [ "$INSTALL_APPLICATIONS" = 1 ];  then echo "**Installing Applications via HomeBrew"; fi
if [ "$SET_USER_SETTINGS" = 1 ];  then echo "**Configure user settings (dock, finder, etc.) for user running the script"; fi
echo ""

echo -n "Would you like to proceed with the above actions? [yes or no]: "
	read yno
			case $yno in

        	[yY] | [yY][Ee][Ss] )
                echo "Continuing with workstation rollout."
                ;;

        	[nN] | [nN][Oo] )
                echo "User chose to exit the script. No changes have been made.";
                exit 1
                ;;
        	*) echo "Invalid input. Please answer yes or no. Exiting"
        		exit 1
           		 ;;
			esac



#If system settings option is set, do the things

FAILED_SYSTEM_SETTINGS=()

if [ $SET_SYSTEM_SETTINGS = "1" ]; then
	function_title "Type the desired computer name and press return. Be Sure to not include any spaces or weird characters."
	read -p "Computer Name: " COMP_NAME
	echo "Setting Computer Name to $COMP_NAME"
	sudo scutil --set ComputerName $COMP_NAME
	#Testing successful command
	if [ $? -eq 0 ]
		then
  			echo "Computer Name set properly"
		else
  			echo "WARNING: FAILED TO SET COMPUTER NAME"
  			FAILED_SYSTEM_SETTINGS+=('COMPUTER_NAME')
	fi
	
	echo "Setting Host Name to "$COMP_NAME".shared"
	sudo scutil --set HostName "$COMP_NAME".shared
	#Testing successful command
	if [ $? -eq 0 ]
		then
  			echo "Host Name set properly"
		else
  			echo "WARNING: FAILED TO SET HOST NAME"
  			FAILED_SYSTEM_SETTINGS+=('HOST_NAME')
	fi

	echo "Setting Local Host Name to "$COMP_NAME".local"
	sudo scutil --set LocalHostName $COMP_NAME
	#Testing successful command
	if [ $? -eq 0 ]
		then
  			echo "Local Host Name set properly"
		else
  			echo "WARNING: FAILED TO SET LOCAL HOST NAME"
  			FAILED_SYSTEM_SETTINGS+=('LOCAL_HOST_NAME')
	fi
	
	#Setting hard drive name
	#In BigSur, the APFS volume stays named Macintosh HD even after this display name is changed"
	#This should always rename, even if the user visible disk name is not "Macintosh HD"
	diskutil mount 'Macintosh HD'
	if [ $? -ne 0 ]; then
		echo ""
		echo "**********************"
		echo "WARNING: Problem renaming drive. Cannot mount Macintosh HD"
		echo "WARNING: Possible reason for error: Drive already renamed."
		echo "**********************"
		echo ""
		FAILED_SYSTEM_SETTINGS+=('POSSIBLE_PRIMARY_VOLUME_NAME_FAIL')

	else
		CHECK_MAC_HD=$(mount | awk '/Volumes\/Macintosh HD/ { print $1 }')
		if [ -z $CHECK_MAC_HD ] ; then
			echo "Cannot find a drive named Macintosh HD. Skipping Rename."
		else
			echo "Renaming $CHECK_MAC_HD to $COMP_NAME"
			diskutil rename $CHECK_MAC_HD $COMP_NAME
			if [ $? -eq 0 ]; then
					echo "Primary volume named successfully. Restarting Finder."
					#This is necessary to get the name to appear on the desktop
					killall Finder
			else
					echo "WARNING: FAILED TO SET PRIMARY VOLUME NAME"
					FAILED_SYSTEM_SETTINGS+=('PRIMARY_VOLUME_NAME')
			fi
		fi
	fi
	
	function_title "Setting System Preferences"
	#Set battery sleep and power settings
	sudo pmset -b disksleep 10 sleep 15 displaysleep 5
	
	#Set charger sleep and power settings
	sudo pmset -c disksleep 0 sleep 0 displaysleep 15
	
	#Require all System Preference Panes to require admin password
		
	sudo security authorizationdb read system.preferences > /tmp/system.preferences.plist
	sudo /usr/libexec/PlistBuddy -c "Set :shared false" /tmp/system.preferences.plist
	sudo security authorizationdb write system.preferences < /tmp/system.preferences.plist
	#"Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
	sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
	
	HIDDEN_LINK_TARGET_DIR="/Applications/Utilities/"

	MAKE_HIDDEN_LINKS=(

	"/System/Library/CoreServices/Applications/Archive Utility.app"
	"/System/Library/CoreServices/Applications/About This Mac.app"
	"/System/Library/CoreServices/Applications/Directory Utility.app"
	"/System/Library/CoreServices/Applications/Screen Sharing.app"
	"/System/Library/CoreServices/Applications/Storage Management.app"
	"/System/Library/CoreServices/Applications/Network Utility.app"
	"/System/Library/CoreServices/Applications/Wireless Diagnostics.app"
	"/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app"
	"/Applications/TeamViewerQS.app"


	)

	function_title "Creating useful links in "$HIDDEN_LINK_TARGET_DIR""


	for i in "${MAKE_HIDDEN_LINKS[@]}" ; do 
		BASE_NAME=$(basename "$i")
		FULL_TARGET_PATH="$HIDDEN_LINK_TARGET_DIR""$BASE_NAME"
		if [ -d "$FULL_TARGET_PATH" ] ; then
			echo ""$BASE_NAME" already exists. Skipping."
		else
			ECHO_DEBUG echo "Creating link for: "$i""
			sudo ln -s "$i" "$FULL_TARGET_PATH"
		fi
	done

	
function_title "System Settings are complete."



#Ending System Settings Conditional	
fi

if [ $INSTALL_APPLICATIONS = "1" ]; then

#List the applications to be installed and confirm.
	echo "The following applications will be installed."
	echo ""
	for APP_LISTING in ${BREWCASKS[@]}; do
		echo "$APP_LISTING"
	done
	
	echo ""
	echo -n "Do you want to continue installing the above applications? [yes or no]: "
		read yno
			case $yno in

        	[yY] | [yY][Ee][Ss] )
                echo "Continuing to install selected apps."
                ;;

        	[nN] | [n|N][O|o] )
                echo "User chose to exit the script. No changes have been made.";
                exit 1
                ;;
        	*) echo "Invalid input. Please answer yes or no. Exiting"
        		exit 1
           		 ;;
			esac

	
	function_title "Setting up Brew"
	if test ! $(which brew); then
		echo "Brew is not found. Installing now."
		echo ""
		echo "Please enter the user password when prompted. You will also need to approve XCode installation. After that, you can step away. This could take a while."
    	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    	if [ $? -eq 0 ]
			then
  				function_title "Brew installed successfully"
			else
  				function_title "Brew install failed. Aborting script, Error code 50"
  				exit $BREW_INSTALL_FAILED
		fi
    else
    	echo "Brew is already installed. Updating and upgrading"
    	brew update
    	brew upgrade
    	if [ $? -eq 0 ]
			then
  				function_title "Brew Updated and Upgraded successfully"
			else
  				function_title "Brew Update or Upgrade failed. Aborting script, Error code 51"
  				exit $BREW_UPDATE_FAILED
		fi
	fi
	
	##Fix "Command not found: brew" by adding to zsh aliases
	#Found here: https://tech-cookbook.com/2021/10/25/how-to-setup-homebrew-brew-install-on-macos-12-monterey/
	export PATH="/opt/homebrew/bin:$PATH"
	echo 'export PATH="/opt/homebrew/bin:$PATH"' >> $HOME/.zshrc
	
	#Turn off "brew analytics" for no tracking
	brew analytics off
	
	function_title "Installing standard applications via Brew."
	#Force a password entry now so you may not have to do it later
	sudo whoami > /dev/null
	#install prereq
	brew install cask
	#install all apps listed in variable $BREWCASKS
	SUCCESSFUL_INSTALL=()
	FAILED_INSTALL=()
	for CURRENT_BREW_INSTALL in ${BREWCASKS[@]}; do
		sudo -v
		brew install --cask $CURRENT_BREW_INSTALL
		if [ $? != 0 ]; then
			echo "WARNING: "$CURRENT_BREW_INSTALL" failed to install properly"
			FAILED_INSTALL=(${FAILED_INSTALL[@]} $CURRENT_BREW_INSTALL)
		else
			echo "Successfully installed: $CURRENT_BREW_INSTALL"
			SUCCESSFUL_INSTALL=(${SUCCESSFUL_INSTALL[@]} $CURRENT_BREW_INSTALL)
		fi
	done
	
	#Cleanup brew files
	echo "Cleaning up Brew files"
	brew cleanup

	#Delete contents of Brew cache folder	
	rm -r ~/Library/Caches/Homebrew/downloads/*

#Ending Application Install Conditional
fi

#Configure User Account Settings

if [ $SET_USER_SETTINGS = "1" ]; then

	#Set Finder settings
	function_title "Setting Finder Preferences"
	# Expand the following File Info panes:
	#  “General”, “Open with”, and “Sharing & Permissions”
	defaults write com.apple.finder FXInfoPanesExpanded -dict \
		General -string "YES" \
		OpenWith -string "YES" \
		Privileges -string "YES"
	# Finder: show status bar
	defaults write com.apple.finder ShowStatusBar -string "YES"
	# Finder: show path bar
	defaults write com.apple.finder ShowPathbar -string "YES"
	# the following Finder Preferences enables the specified drives to be shown on the Desktop
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -string "YES"
	defaults write com.apple.finder ShowHardDrivesOnDesktop -string "YES"
	defaults write com.apple.finder ShowMountedServersOnDesktop -string "YES"
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -string "YES"
	# Finder windows will open to the users home folder
	defaults write com.apple.finder NewWindowTarget PfHm
	# Show filename extensions by default
	defaults write NSGlobalDomain AppleShowAllExtensions -string "YES"
	#Expand the save panel by default
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -string "YES"
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -string "YES"
	#Expand the Print panel by default
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -string "YES"
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -string "YES"
	# Prevent Time Machine from prompting to use new hard drives as backup volume
	##This command does not give errors, but has not been tested in macOS 11.4+
	defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -string "YES"
	# Show all processes in Activity Monitor
	defaults write com.apple.ActivityMonitor ShowCategory -int 0
	#  Do not launch iTunes when iPhone/iPad is connected
	##This command does not give errors, but has not been tested in macOS 11.4+
	defaults write com.apple.iTunes StoreActivationMode -integer 1
	#Set menubar clock to show date and am/pm
	defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM hh:mm a"
	
	#Always show Bluetooth, Wifi, Sound, and Battery with % in the menu bar (not just control center)
	defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Bluetooth -int 18                    
	defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist WiFi -int 18     
	defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Battery -int 18
	defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
	defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Sound -int 18
	
	#Remove iCloud as Default Save Location
	##This command does not give errors, but may not be working in macOS 11.4+
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -string "NO"
	
	killall Finder
	killall SystemUIServer

	#Set Dock Items
	function_title "Setting Dock Preferences"
	#Delete all dock items
	defaults write com.apple.dock persistent-apps -array
	#Add dock items from variable
	for i in "${DOCK_APPS[@]}"; do
		#Check if the .app exists
		if [ -d "$i" ]; then
			#Add new dock item for each application in the declared array
			defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$i</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
		fi
	
	done
	killall Dock

	#Set user level system preferences
	function_title "Setting User level System Preferences"
	
	#Set tab for all menus (keyboard shortcuts)_
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	#Always show scrollbars
	defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
	#Disable photos.app from launching automatically
	##This command does not give errors, but may not be working in macOS 11.4+
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
	
	#Set browser settings
	#Don't open "safe" files after downloading
	defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
	# Enable “Do Not Track”
	defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
	# Show full URL in menu bar
	defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

#End User Settings conditional
fi


#Final report

echo ""
echo "

*******************************
*                             *
*            REPORT           *
*                             *
*******************************

"

if (( ${#FAILED_SYSTEM_SETTINGS[@]} != 0 )) ; then
	echo ""
	echo ""
	echo "***************************************************************************"
	function_title "WARNING - SYSTEM SETINGS ERRORS OCCURRED"
	echo "***************************************************************************"
	echo ""
	echo "The following failures occurred when setting System Settings:"
	for f in ${FAILED_SYSTEM_SETTINGS[@]}; do
		echo "$f"
	done
else
	ECHO_DEBUG echo "No system settings failures detected."
fi

function_title "Application Installation Report"

echo "The following applications were installed successfully:"

if (( ${#SUCCESSFUL_INSTALL[@]} != 0 )) ; then
	for i in ${SUCCESSFUL_INSTALL[@]}; do
		echo $i
	done
fi

echo ""

if (( ${#FAILED_INSTALL[@]} != 0 )) ; then
	echo "The following applications failed to install properly:"
	for f in ${FAILED_INSTALL[@]}; do
		echo "$f"
	done
else
	ECHO_DEBUG echo "No application installation failures detected."
fi



ECHO_DEBUG echo "DEBUG: Script ends here... "
#####################
#   END OF SCRIPT   #
#####################
