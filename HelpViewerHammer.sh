#!/bin/sh
# This script has been updated for Snow Leopard.

# Kill any running instances of helpd

/bin/ps -ax | awk '(/\/helpd/)  { if ($5 != "awk") print "kill " $1 }'  | /bin/sh

# The above statement will kill all processes which have "/helpd " in their pathname.  First, it calls ps, which creates a stream of lines containing all processes and their names.  The -a option says to display others' processes as well as your own, so this will work if you put it in the root crontab or in the admin crontab, this will shut down others' processes.  The -x option says to display info about processes without controlling terminals, such as apps running under Mac OS X.  The result is piped to awk, which looks for all processes containing the string "/helpd".  The $5 extracts the fifth field (whatever is between the fourth whitespace and the fifth whitespace).    So the print kill statement is not executed if the fifth field is "awk".  The line listing the awk process will be, for example:
#   23492 ttys003    0:00.00 awk (/\/helpd/)
#Therefore, this keeps the process from killing itself.  (Probably it would be OK if it killed itself, since it should be the last one in the list, but obviously it is not good programming practice for a process to kill itself).   The $1 extracts the first field from each line, which is the process ID number, and prepends the word "kill" on it, so that the output awk is a stream which looks like
#   kill 1001
#   kill 1004
#   kill 1006
#   etc.
# where the numbers 1001 etc. are the process numbers to be killed.  Finally, this is piped to a shell, which kills all of these processes. 

# Reset Caches

rm -Rf ~/Library/Caches/com.apple.helpui
rm -Rf ~/Library/Caches/com.apple.helpd
rm -Rf ~/Library/Preferences/com.apple.help*.plist

# Switch on PrintURLInFooter

defaults write com.apple.helpviewer PrintURLInFooter YES

# The following line, switching on HelpViewerDebugging, is no longer supported in Snow Leopard.  If Apple ever reprises this feature, it would log Help Viewer errors.  For now, it is commented out
# defaults write com.apple.helpviewer HelpViewerDebugging -bool YES

echo Any running instances of the daemon helpd have been killed, Apple Help caches have been reset, and PrintURLInFooter has been turned on.  This will NOT cause Help Viewer windows to be closed.  However, clicking a link in a Help Viewer window will cause a new instance of helpd to launch.
