#!/usr/bin/perl

=com
Because the "Behaviors" feature in stupid Xcode 4 can't launch an AppleScript
=cut

use File::Basename ;
my $dirname = dirname(__FILE__) ;

`open $dirname/CleanDebugLogs.app`