#!/bin/sh

appName=BookMacster
cd ~
scriptsDirectory=$PWD/Documents/Programming/Scripts/XCodeUserMenu/$appName

# echo Your Path is: $0

echo Will run scripts from:
echo $scriptsDirectory
echo

$scriptsDirectory/RemoveHomeAppSupport.sh
echo
$scriptsDirectory/RemoveLicense.sh
echo
$scriptsDirectory/RemoveHomePrefs.sh
echo
$scriptsDirectory/RemovePrivilegedTool.sh
