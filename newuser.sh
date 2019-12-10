#!/bin/sh
fullname=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the users First & Last name or select Cancel." default answer "First Last"' -e 'text returned of result' 2>/dev/null)

username=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the username or select Cancel." default answer "first.last"' -e 'text returned of result' 2>/dev/null)

#Create user account
sudo /usr/sbin/sysadminctl -addUser $username -fullName "$fullname" -password - -admin
sudo /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n $username
# Enable Firevault
sudo fdesetup enable
# Transfer secureToken
sudo sysadminctl interactive -secureTokenOn $username -password -
echo 'success'
