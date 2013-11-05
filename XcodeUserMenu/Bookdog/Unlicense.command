# It is not reliable to modify preferences while apps are running
osascript -e "try" -e "tell application \"Bookdog\" to quit" -e "end try"
osascript -e "try" -e "tell application \"Bookwatchdog\" to quit" -e "end try"

# Now we want to overwrite the relevant keys in the preferences to nonsense values.  The following would overwrite all defaults in the file.  This is not what we want
# defaults write com.sheepsystems.Bookdog '{"licenseeName" = "Nobody"; "serialNumber" = "nothing";}'
# However, the following overwrites only the two relevant keys:
defaults write com.sheepsystems.Bookdog LicenseeName 'Nobody'
defaults write com.sheepsystems.Bookdog SerialNumber 'nothing'

# Unfortunately, the 'defaults' command does not affect the any-user preferences at the system level.  Fortunately, though, LicenseeName and LicenseKey are the only keys that we write at the system level.  So we can simply delete the whole file.  The 'rm' command would fail if elevated permissions are necessary, so instead we tell Finder to do it.  Finder will display the authentication dialog if necessary.
osascript -e "try" -e "tell application \"Finder\" to delete POSIX file \"/Library/Preferences/com.sheepsystems.Bookdog.plist\"" -e "end try"

echo
echo
echo "If Bookdog or Bookwatchdog were running, they have been quit."
echo "The Licensee Name and License Key in both this user's home and at the any-user (system) level have been invalidated."
echo You may close this window now.