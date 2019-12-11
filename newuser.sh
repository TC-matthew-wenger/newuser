#!/bin/sh

# Dialog box for new user creation
fullname=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the new user first & last name or select Cancel." default answer "First Last"' -e 'text returned of result' 2>/dev/null)
username=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the new user or select Cancel." default answer "first.last"' -e 'text returned of result' 2>/dev/null)

# Create user account
sudo sysadminctl interactive -addUser $username -fullName "$fullname" -password -

# Convert to Mobile account
sudo /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -D -n $username

# Read input and determine if user should be local admin or not
read -p "Make this user a local admin? [Y/N]: " adminUser
if [[ "$adminUser" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    sudo dseditgroup -o edit -a $username -t user admin
else
    sudo dseditgroup -o edit -d $username -t user admin 
fi

# Enable Firevault if necessary and transfer secure token
if fdesetup status | grep 'FileVault is On.' > /dev/null; then
    echo "Firevault is on, skipping!"
else
    echo "Firevault is not on, let's enable it ... "
    sudo fdesetup enable
    sysadminctl -secureTokenOn guiadmin -password - -adminUser guiadmin -adminPassword -
fi

# Hostname change section
