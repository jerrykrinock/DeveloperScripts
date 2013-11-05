#! /bin/sh

# This uninstalls the hidden references to AuthorizedTaskHelperTool installed when the demo runs.  It's necessary to run this as part of your "clean" cycle testing to ensure that an old version is not run.

companyID=com.sheepsystems.BookMacster

echo Running script $0
echo      Real User ID is $UID
echo Effective User ID is $EUID

launchctl unload -w /Library/LaunchDaemons/$companyID.plist
rm /Library/LaunchDaemons/$companyID.plist
rm /Library/PrivilegedHelperTools/$companyID
rm /var/run/$companyID.socket

